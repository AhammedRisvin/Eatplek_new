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
  late final FittorClient _client;
  final Map<String, String> _commonHeaders = {'Accept': 'application/json', 'Content-Type': 'application/json'};

  FittorConnect() {
    _client = FittorClient(defaultTimeout: const Duration(seconds: 30), enableLogging: true);

    // 🔵 ADD DETAILED LOGGING INTERCEPTOR
    _client.addInterceptor(
      CallbackInterceptor(
        onRequest: (request) async {
          debugPrint("🔵 REQUEST");
          debugPrint("URL: ${request.url}");
          debugPrint("Method: ${request.method}");

          try {
            debugPrint("Body: ${utf8.decode(request.body)}");
          } catch (_) {
            debugPrint("Body: (binary or empty)");
          }

          return request;
        },
        onResponse: (response) async {
          debugPrint("🟢 RESPONSE");
          debugPrint("Status: ${response.statusCode}");

          try {
            debugPrint("Response Body: ${utf8.decode(response.bodyBytes)}");
          } catch (_) {
            debugPrint("Response Body: (binary or unreadable)");
          }

          return response;
        },
        onError: (error, stack) async {
          debugPrint("🔴 ERROR");
          debugPrint("Error: $error");

          return error; // must return
        },
      ),
    );

    // Add normal logging interceptor (disabled but keeping your config)
    _client.addInterceptor(
      LoggingInterceptor(logRequest: false, logResponse: false, logError: false, logTag: 'FittorConnect'),
    );

    // Add retry
    _client.addInterceptor(
      RetryInterceptor(
        maxRetries: 3,
        baseDelay: const Duration(milliseconds: 1000),
        retryOnTimeout: true,
        retryOnConnectionError: true,
      ),
    );

    // Add common headers interceptor
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

  void updateCommonHeaders(Map<String, String> headers) {
    _commonHeaders.addAll(headers);
  }

  void setAuthToken() {
    updateCommonHeaders({'Authorization': 'Bearer ${Store.userToken}'});
  }

  void clearAuthToken() {
    _commonHeaders.remove('Authorization');
  }

  String _handleError(dynamic error) {
    if (error is FittorTimeoutException) {
      return 'Connection timed out';
    } else if (error is FittorNetworkException) {
      return 'Network error occurred: ${error.message}';
    } else if (error is FittorHttpException) {
      final statusCode = error.statusCode;
      String errorMessage = error.message;
      switch (statusCode) {
        case 400:
          return errorMessage.isNotEmpty ? errorMessage : 'Bad request';
        case 401:
          return errorMessage.isNotEmpty ? errorMessage : 'Authentication required';
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

  String _buildUrl(String endpoint) {
    if (endpoint.startsWith('http')) return endpoint;
    return '${Urls.baseUrl}$endpoint';
  }

  Future<T> get<T>({
    required String endpoint,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client.get(_buildUrl(endpoint), queryParameters: queryParameters, headers: headers);

      if (response.isSuccessful) {
        return parseResponse<T>(response);
      } else {
        final resp = parseResponse(response);
        if (resp is Map<String, dynamic>) {
          if (resp.containsKey('message')) {
            if (resp['message'] == 'Token not found') {
              await Store.clear();
              Get.offAllNamed(Routes.login);
            }
            throw FittorHttpException(resp['message'], response.statusCode, response.statusMessage);
          }
        }
        throw FittorHttpException('Request failed', response.statusCode, response.statusMessage);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> post<T>({
    required String endpoint,
    dynamic data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      log('data $data');
      final response = await _client.post(
        _buildUrl(endpoint),
        body: data is Map ? jsonEncode(data) : data,
        queryParameters: queryParameters,
        headers: headers,
      );

      if (response.isSuccessful) {
        return parseResponse<T>(response);
      } else {
        final resp = parseResponse(response);
        if (resp is Map<String, dynamic>) {
          if (resp.containsKey('message')) {
            if (resp['message'] == 'Token not found') {
              await Store.clear();
              Get.offAllNamed(Routes.login);
            }
            throw FittorHttpException(resp['message'], response.statusCode, response.statusMessage);
          }
        }
        throw FittorHttpException('Request failed', response.statusCode, response.statusMessage);
      }
    } catch (e) {
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
      final response = await _client.put(
        _buildUrl(endpoint),
        body: data is Map ? jsonEncode(data) : data,
        queryParameters: queryParameters,
        headers: headers,
      );

      if (response.isSuccessful) {
        return parseResponse<T>(response);
      } else {
        final resp = parseResponse(response);
        if (resp is Map<String, dynamic>) {
          if (resp.containsKey('message')) {
            if (resp['message'] == 'Token not found') {
              await Store.clear();
              Get.offAllNamed(Routes.login);
            }
            throw FittorHttpException(resp['message'], response.statusCode, response.statusMessage);
          }
        }
        throw FittorHttpException('Request failed', response.statusCode, response.statusMessage);
      }
    } catch (e) {
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
      final response = await _client.patch(
        _buildUrl(endpoint),
        body: data is Map ? jsonEncode(data) : data,
        queryParameters: queryParameters,
        headers: headers,
      );

      if (response.isSuccessful) {
        return parseResponse<T>(response);
      } else {
        final resp = parseResponse(response);
        if (resp is Map<String, dynamic>) {
          if (resp.containsKey('message')) {
            if (resp['message'] == 'Token not found') {
              await Store.clear();
              Get.offAllNamed(Routes.login);
            }
            throw FittorHttpException(resp['message'], response.statusCode, response.statusMessage);
          }
        }
        throw FittorHttpException('Request failed', response.statusCode, response.statusMessage);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> delete<T>({
    required String endpoint,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client.delete(_buildUrl(endpoint), queryParameters: queryParameters, headers: headers);

      if (response.isSuccessful) {
        return parseResponse<T>(response);
      } else {
        throw FittorHttpException('Request failed', response.statusCode, response.statusMessage);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

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

      final boundary = 'fittor-boundary-${DateTime.now().millisecondsSinceEpoch}';
      final List<int> body = [];

      body.addAll('--$boundary\r\n'.codeUnits);
      body.addAll('Content-Disposition: form-data; name="$fieldName"; filename="$fileName"\r\n'.codeUnits);
      body.addAll('Content-Type: application/octet-stream\r\n\r\n'.codeUnits);
      body.addAll(fileBytes);
      body.addAll('\r\n'.codeUnits);

      if (extraData != null) {
        for (final entry in extraData.entries) {
          body.addAll('--$boundary\r\n'.codeUnits);
          body.addAll('Content-Disposition: form-data; name="${entry.key}"\r\n\r\n'.codeUnits);
          body.addAll('${entry.value}\r\n'.codeUnits);
        }
      }

      body.addAll('--$boundary--\r\n'.codeUnits);

      final uploadHeaders = {'Content-Type': 'multipart/form-data; boundary=$boundary', ...?headers};

      final response = await _client.post(_buildUrl(endpoint), body: Uint8List.fromList(body), headers: uploadHeaders);

      if (response.isSuccessful) {
        return parseResponse<T>(response);
      } else {
        throw FittorHttpException('Upload failed', response.statusCode, response.statusMessage);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

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
        throw FittorHttpException('Download failed', response.statusCode, response.statusMessage);
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  T parseResponse<T>(FittorResponse response) {
    if (T == String) {
      return response.body as T;
    } else if (T == dynamic || T == Map<String, dynamic>) {
      try {
        return jsonDecode(utf8.decode(response.bodyBytes)) as T;
      } catch (e) {
        return response.body as T;
      }
    } else {
      try {
        return jsonDecode(response.body) as T;
      } catch (e) {
        return response.body as T;
      }
    }
  }

  Future<List<String>> uploadImagesToCloudinary({
    required Map<String, File> files,
    required Function(double progress) progressCallback,
  }) async {
    List<String> urls = [];
    Completer<List<String>> completer = Completer<List<String>>();
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

  void dispose() {
    debugPrint('⚠️ FittorConnect.dispose() called but ignored (singleton)');
  }
}

// UploadProgress + uploader (unchanged)
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
  static Stream<UploadProgress> uploadFiles({required Map<String, File> files, String? folder}) {
    final StreamController<UploadProgress> controller = StreamController.broadcast();
    final cloudinary = Cloudinary.signedConfig(
      apiKey: "856197342338424",
      apiSecret: "TbKAxeMx8jsxTWruUNlZ1Vc1uxU",
      cloudName: "gadpark",
    );

    Map<String, String> uploadedUrls = {};

    Future<void> uploadFile(String fileKey, File file) async {
      String fileName = file.path.split('/').last;
      try {
        final response = await cloudinary.upload(
          file: file.path,
          fileBytes: file.readAsBytesSync(),
          resourceType: CloudinaryResourceType.auto,
          folder: folder ?? 'micons',
          fileName: fileName,
          progressCallback: (count, total) {
            double progress = count / total;
            controller.add(UploadProgress(fileKey: fileKey, fileName: fileName, progress: progress));
          },
        );
        uploadedUrls[fileKey] = response.secureUrl ?? '';
        controller.add(UploadProgress(fileKey: fileKey, fileName: fileName, progress: 1.0, url: response.secureUrl));
      } catch (e) {
        controller.add(UploadProgress(fileKey: fileKey, fileName: fileName, progress: 0.0, error: e.toString()));
      }
    }

    Future.wait(files.entries.map((entry) => uploadFile(entry.key, entry.value))).then((_) {
      controller.add(UploadProgress(fileKey: 'all', fileName: 'all', progress: 1.0, urls: uploadedUrls));
      controller.close();
    });

    return controller.stream;
  }
}
