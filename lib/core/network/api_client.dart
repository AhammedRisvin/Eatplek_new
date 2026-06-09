import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloudinary/cloudinary.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/routes.dart';
import '../util/storage.dart';
import 'api_endpoints.dart';

class FittorConnect {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final FittorConnect _instance = FittorConnect._internal();
  factory FittorConnect() => _instance;

  late final FittorClient _client;
  final Map<String, String> _commonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  // ── Refresh token lock ─────────────────────────────────────────────────────
  Completer<bool>? _refreshCompleter;

  FittorConnect._internal() {
    _client = FittorClient(
      defaultTimeout: const Duration(seconds: 30),
      enableLogging: false,
    );

    // ── Structured request/response logger ────────────────────────────────
    _client.addInterceptor(
      CallbackInterceptor(
        onRequest: (request) async {
          final body = request.body;
          String bodyPreview = '';
          if (body != null) {
            try {
              if (body is String && body.isNotEmpty) {
                final decoded = jsonDecode(body);
                final pretty = const JsonEncoder.withIndent(
                  '  ',
                ).convert(decoded);
                bodyPreview =
                    pretty.length > 500
                        ? '${pretty.substring(0, 500)}\n  ... (truncated)'
                        : pretty;
              }
            } catch (_) {
              bodyPreview = body.toString();
            }
          }

          log(
            '┌─ 🔵 ${request.method.name.toUpperCase()} ${request.url}\n'
            '${bodyPreview.isNotEmpty ? '│  Body: $bodyPreview\n' : ''}'
            '└─────────────────────────',
            name: 'FittorConnect',
          );
          return request;
        },
        onResponse: (response) async {
          String bodyPreview = '';
          try {
            final decoded = jsonDecode(utf8.decode(response.bodyBytes));
            final pretty = const JsonEncoder.withIndent('  ').convert(decoded);
            bodyPreview =
                pretty.length > 500
                    ? '${pretty.substring(0, 500)}\n  ... (truncated)'
                    : pretty;
          } catch (_) {
            bodyPreview = response.body;
          }

          log(
            '┌─ 🟢 ${response.statusCode} ${response.statusMessage}\n'
            '│  Body: $bodyPreview\n'
            '└─────────────────────────',
            name: 'FittorConnect',
          );
          return response;
        },
        onError: (error, stack) async {
          log(
            '┌─ 🔴 ERROR\n'
            '│  $error\n'
            '└─────────────────────────',
            name: 'FittorConnect',
            error: error,
            stackTrace: stack,
          );
          return error;
        },
      ),
    );

    // ── Common headers injector ────────────────────────────────────────────
    _client.addInterceptor(
      CallbackInterceptor(
        onRequest: (request) async {
          _commonHeaders.forEach((key, value) {
            request.headers.set(key, value);
          });
          return request;
        },
      ),
    );

    if (Store.userToken.isNotEmpty) {
      setAuthToken();
    }
  }

  // ── Token helpers ──────────────────────────────────────────────────────────

  void updateCommonHeaders(Map<String, String> headers) {
    _commonHeaders.addAll(headers);
  }

  void setAuthToken() {
    updateCommonHeaders({'Authorization': 'Bearer ${Store.userToken}'});
  }

  void clearAuthToken() {
    _commonHeaders.remove('Authorization');
  }

  // ── Refresh token flow ─────────────────────────────────────────────────────
  Future<bool> _refreshTokenCall() async {
    log('🔄 Attempting token refresh...', name: 'FittorConnect');

    final storedRefreshToken = Store.refreshToken;
    if (storedRefreshToken.isEmpty) {
      log('❌ No refresh token stored — cannot refresh.', name: 'FittorConnect');
      return false;
    }

    // ── Debug: log both tokens so we can spot any mismatch ────────────────
    log('🔑 Access token (expired): ${Store.userToken}', name: 'FittorConnect');
    log(
      '🔑 Refresh token being sent: $storedRefreshToken',
      name: 'FittorConnect',
    );
    log(
      '🔑 Current _commonHeaders auth: ${_commonHeaders['Authorization']}',
      name: 'FittorConnect',
    );

    try {
      // Temporarily remove the expired access token from common headers
      // so the interceptor doesn't override our refresh token header
      final expiredToken = _commonHeaders.remove('Authorization');
      log(
        '🔄 Removed access token from headers for refresh call',
        name: 'FittorConnect',
      );

      final response = await _client.post(
        _buildUrl(Urls.refreshToken),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $storedRefreshToken',
        },
      );

      // Restore the expired token back (will be replaced after successful refresh)
      if (expiredToken != null) {
        _commonHeaders['Authorization'] = expiredToken;
        log('🔄 Restored access token to headers', name: 'FittorConnect');
      }

      log(
        '🔄 Refresh response status: ${response.statusCode}',
        name: 'FittorConnect',
      );

      if (response.isSuccessful) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        final newAccessToken =
            data['accessToken'] as String? ?? data['token'] as String? ?? '';
        final newRefreshToken = data['refreshToken'] as String? ?? '';

        log(
          '✅ New access token received: $newAccessToken',
          name: 'FittorConnect',
        );

        if (newAccessToken.isEmpty) {
          log(
            '❌ Refresh response missing accessToken field.',
            name: 'FittorConnect',
          );
          return false;
        }

        await Store.saveTokens(
          accessToken: newAccessToken,
          refreshToken:
              newRefreshToken.isNotEmpty ? newRefreshToken : storedRefreshToken,
        );
        setAuthToken();

        log('✅ Token refreshed successfully.', name: 'FittorConnect');
        return true;
      } else {
        log(
          '❌ Refresh request failed with status ${response.statusCode}.',
          name: 'FittorConnect',
        );
        log('❌ Refresh response body: ${response.body}', name: 'FittorConnect');
        return false;
      }
    } catch (e) {
      log('❌ Refresh request threw: $e', name: 'FittorConnect');
      return false;
    }
  }

  Future<void> _forceLogout() async {
    log('🚪 Forcing logout — clearing credentials.', name: 'FittorConnect');
    clearAuthToken();
    await Store.clear();
    Get.offAllNamed(Routes.login);
  }

  Future<bool> _handleUnauthorized() async {
    if (_refreshCompleter != null) {
      log('⏳ Refresh already in progress, waiting...', name: 'FittorConnect');
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();
    try {
      final success = await _refreshTokenCall();
      _refreshCompleter!.complete(success);
      if (!success) await _forceLogout();
      return success;
    } catch (e) {
      _refreshCompleter!.complete(false);
      await _forceLogout();
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  // ── Login required dialog ──────────────────────────────────────────────────

  /// Shows a dialog informing the user they need to log in to use this feature.
  /// Tapping "Login" navigates to the login screen.
  /// Tapping "Cancel" dismisses the dialog and stays on the current screen.
  Future<void> _showLoginRequiredDialog() async {
    final context = Get.overlayContext;
    if (context == null) return;

    if (Get.isDialogOpen == true) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: const Text('Login Required'),
            content: const Text(
              'You need to be logged in to use this feature. Please login to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(Get.overlayContext!).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(Get.overlayContext!).pop();
                  await Store.clear();
                  clearAuthToken();
                  Get.offAllNamed(Routes.login);
                },
                child: const Text('Login'),
              ),
            ],
          ),
    );
  }

  // ── Error normaliser ───────────────────────────────────────────────────────

  String _handleError(dynamic error) {
    if (error is FittorTimeoutException) {
      return 'Connection timed out';
    } else if (error is FittorNetworkException) {
      return 'Network error occurred: ${error.message}';
    } else if (error is FittorHttpException) {
      final statusCode = error.statusCode;
      final errorMessage = error.message;
      switch (statusCode) {
        case 400:
          return errorMessage.isNotEmpty ? errorMessage : 'Bad request';
        case 401:
          return errorMessage.isNotEmpty
              ? errorMessage
              : 'Authentication required';
        case 403:
          return errorMessage.isNotEmpty ? errorMessage : 'Access denied';
        case 404:
          return errorMessage.isNotEmpty ? errorMessage : 'Resource not found';
        case 500:
          return errorMessage.isNotEmpty ? errorMessage : 'Server error';
        default:
          return 'HTTP error occurred: $statusCode';
      }
    } else if (error is FittorException) {
      return error.message;
    } else {
      return 'Unexpected error: $error';
    }
  }

  // ── URL builder ────────────────────────────────────────────────────────────

  String _buildUrl(String endpoint) {
    if (endpoint.startsWith('http')) return endpoint;
    return '${Urls.baseUrl}$endpoint';
  }

  // ── Response parser ────────────────────────────────────────────────────────

  T parseResponse<T>(FittorResponse response) {
    if (T == String) {
      return response.body as T;
    } else if (T == dynamic || T == Map<String, dynamic>) {
      try {
        return jsonDecode(utf8.decode(response.bodyBytes)) as T;
      } catch (_) {
        return response.body as T;
      }
    } else {
      try {
        return jsonDecode(response.body) as T;
      } catch (_) {
        return response.body as T;
      }
    }
  }

  // ── Response handler ──────────────────────────────────────────────────────

  Future<T> _processResponse<T>(
    FittorResponse response, {
    Future<FittorResponse> Function()? retryCallback,
    bool showLoginRequiredDialog = true,
  }) async {
    if (response.isSuccessful) {
      return parseResponse<T>(response);
    }

    Map<String, dynamic>? parsed;
    try {
      parsed =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>?;
    } catch (_) {}

    final message = parsed?['message'] as String? ?? '';
    final messageLower = message.toLowerCase();

    // ── 403 + expired token → silent refresh + retry ──────────────────────
    if (response.statusCode == 403 && messageLower.contains('expired')) {
      if (retryCallback != null) {
        final refreshed = await _handleUnauthorized();
        if (refreshed) {
          final retryResponse = await retryCallback();
          return parseResponse<T>(retryResponse);
        }
      }
      // Refresh failed — force logout
      throw _handleError(
        FittorHttpException(
          message.isNotEmpty ? message : 'Session expired. Please login again.',
          response.statusCode,
          response.statusMessage,
        ),
      );
    }

    // ── 401 + no token → show login required dialog ───────────────────────
    if (response.statusCode == 401) {
      if (showLoginRequiredDialog) {
        await _showLoginRequiredDialog();
      }
      throw _handleError(
        FittorHttpException(
          message.isNotEmpty ? message : 'Login required.',
          response.statusCode,
          response.statusMessage,
        ),
      );
    }
    // ── All other failures ─────────────────────────────────────────────────
    throw _handleError(
      FittorHttpException(
        message.isNotEmpty ? message : 'Request failed',
        response.statusCode,
        response.statusMessage,
      ),
    );
  }

  // ── Public HTTP methods ────────────────────────────────────────────────────

  Future<T> get<T>({
    required String endpoint,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final url = _buildUrl(endpoint);
      final response = await _client.get(
        url,
        queryParameters: queryParameters,
        headers: headers,
      );
      return _processResponse<T>(
        response,
        retryCallback:
            () => _client.get(
              url,
              queryParameters: queryParameters,
              headers: headers,
            ),
      );
    } catch (e) {
      if (e is String) rethrow;
      throw _handleError(e);
    }
  }

  Future<T> post<T>({
    required String endpoint,
    dynamic data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final url = _buildUrl(endpoint);
      final encodedBody = data is Map ? jsonEncode(data) : data;

      final response = await _client
          .post(
            url,
            body: encodedBody,
            queryParameters: queryParameters,
            headers: headers,
          )
          .timeout(timeout ?? const Duration(seconds: 30));

      return _processResponse<T>(
        response,
        retryCallback:
            () => _client
                .post(
                  url,
                  body: encodedBody,
                  queryParameters: queryParameters,
                  headers: headers,
                )
                .timeout(timeout ?? const Duration(seconds: 30)),
        showLoginRequiredDialog: endpoint != Urls.logout,
      );
    } catch (e) {
      if (e is String) rethrow;
      throw _handleError(e);
    }
  }

  Future<T> put<T>({
    required String endpoint,
    dynamic data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final url = _buildUrl(endpoint);
      final encodedBody = data is Map ? jsonEncode(data) : data;

      final response = await _client.put(
        url,
        body: encodedBody,
        queryParameters: queryParameters,
        headers: headers,
      );
      return _processResponse<T>(
        response,
        retryCallback:
            () => _client.put(
              url,
              body: encodedBody,
              queryParameters: queryParameters,
              headers: headers,
            ),
      );
    } catch (e) {
      if (e is String) rethrow;
      throw _handleError(e);
    }
  }

  Future<T> patch<T>({
    required String endpoint,
    dynamic data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final url = _buildUrl(endpoint);
      final encodedBody = data is Map ? jsonEncode(data) : data;

      final response = await _client.patch(
        url,
        body: encodedBody,
        queryParameters: queryParameters,
        headers: headers,
      );
      return _processResponse<T>(
        response,
        retryCallback:
            () => _client.patch(
              url,
              body: encodedBody,
              queryParameters: queryParameters,
              headers: headers,
            ),
      );
    } catch (e) {
      if (e is String) rethrow;
      throw _handleError(e);
    }
  }

  Future<T> delete<T>({
    required String endpoint,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final url = _buildUrl(endpoint);
      final response = await _client.delete(
        url,
        queryParameters: queryParameters,
        headers: headers,
      );
      return _processResponse<T>(
        response,
        retryCallback:
            () => _client.delete(
              url,
              queryParameters: queryParameters,
              headers: headers,
            ),
      );
    } catch (e) {
      if (e is String) rethrow;
      throw _handleError(e);
    }
  }

  // ── File upload ────────────────────────────────────────────────────────────

  Future<T> uploadFile<T>({
    required String endpoint,
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? extraData,
    Map<String, String>? headers,
    Function(double progress)? onProgress,
  }) async {
    try {
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();
      final fileName = file.path.split('/').last;

      final boundary =
          'fittor-boundary-${DateTime.now().millisecondsSinceEpoch}';
      final List<int> body = [];

      body.addAll('--$boundary\r\n'.codeUnits);
      body.addAll(
        'Content-Disposition: form-data; name="$fieldName"; filename="$fileName"\r\n'
            .codeUnits,
      );
      body.addAll('Content-Type: application/octet-stream\r\n\r\n'.codeUnits);
      body.addAll(fileBytes);
      body.addAll('\r\n'.codeUnits);

      if (extraData != null) {
        for (final entry in extraData.entries) {
          body.addAll('--$boundary\r\n'.codeUnits);
          body.addAll(
            'Content-Disposition: form-data; name="${entry.key}"\r\n\r\n'
                .codeUnits,
          );
          body.addAll('${entry.value}\r\n'.codeUnits);
        }
      }
      body.addAll('--$boundary--\r\n'.codeUnits);

      final uploadHeaders = {
        'Content-Type': 'multipart/form-data; boundary=$boundary',
        ...?headers,
      };

      final url = _buildUrl(endpoint);
      final bodyBytes = Uint8List.fromList(body);

      final response = await _client.post(
        url,
        body: bodyBytes,
        headers: uploadHeaders,
      );
      return _processResponse<T>(
        response,
        retryCallback:
            () => _client.post(url, body: bodyBytes, headers: uploadHeaders),
      );
    } catch (e) {
      if (e is String) rethrow;
      throw _handleError(e);
    }
  }

  // ── File download ──────────────────────────────────────────────────────────

  Future<String> downloadFile({
    required String url,
    required String savePath,
    Map<String, String>? headers,
    Function(double progress)? onProgress,
  }) async {
    try {
      final response = await _client.get(url, headers: headers);
      if (response.isSuccessful) {
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        return savePath;
      } else {
        throw FittorHttpException(
          'Download failed',
          response.statusCode,
          response.statusMessage,
        );
      }
    } catch (e) {
      if (e is String) rethrow;
      throw _handleError(e);
    }
  }

  // ── Cloudinary upload ──────────────────────────────────────────────────────

  Future<List<String>> uploadImagesToCloudinary({
    required Map<String, File> files,
    required Function(double progress) progressCallback,
  }) async {
    final List<String> urls = [];
    final completer = Completer<List<String>>();

    MIconsUploader.uploadFiles(files: files, folder: "images").listen(
      (progress) {
        if (progress.url != null) urls.add(progress.url!);
        progressCallback(progress.progress);
      },
      onDone: () => completer.complete(urls),
      onError: (error) => completer.completeError(error),
    );

    return completer.future;
  }

  // dispose() is a no-op — FittorConnect is a Dart-level singleton.
  void dispose() {}
}

// ── Cloudinary uploader ────────────────────────────────────────────────────

class UploadProgress {
  final String fileKey;
  final String fileName;
  final double progress;
  final String? url;
  final Map<String, String>? urls;
  final String? error;

  UploadProgress({
    required this.fileKey,
    required this.fileName,
    required this.progress,
    this.url,
    this.urls,
    this.error,
  });
}

class MIconsUploader {
  static Stream<UploadProgress> uploadFiles({
    required Map<String, File> files,
    String? folder,
  }) {
    final StreamController<UploadProgress> controller =
        StreamController.broadcast();
    final cloudinary = Cloudinary.signedConfig(
      apiKey: "856197342338424",
      apiSecret: "TbKAxeMx8jsxTWruUNlZ1Vc1uxU",
      cloudName: "gadpark",
    );

    final Map<String, String> uploadedUrls = {};

    Future<void> uploadFile(String fileKey, File file) async {
      final fileName = file.path.split('/').last;
      try {
        final response = await cloudinary.upload(
          file: file.path,
          fileBytes: file.readAsBytesSync(),
          resourceType: CloudinaryResourceType.auto,
          folder: folder ?? 'micons',
          fileName: fileName,
          progressCallback: (count, total) {
            controller.add(
              UploadProgress(
                fileKey: fileKey,
                fileName: fileName,
                progress: count / total,
              ),
            );
          },
        );
        uploadedUrls[fileKey] = response.secureUrl ?? '';
        controller.add(
          UploadProgress(
            fileKey: fileKey,
            fileName: fileName,
            progress: 1.0,
            url: response.secureUrl,
          ),
        );
      } catch (e) {
        controller.add(
          UploadProgress(
            fileKey: fileKey,
            fileName: fileName,
            progress: 0.0,
            error: e.toString(),
          ),
        );
      }
    }

    Future.wait(
      files.entries.map((entry) => uploadFile(entry.key, entry.value)),
    ).then((_) {
      controller.add(
        UploadProgress(
          fileKey: 'all',
          fileName: 'all',
          progress: 1.0,
          urls: uploadedUrls,
        ),
      );
      controller.close();
    });

    return controller.stream;
  }
}
