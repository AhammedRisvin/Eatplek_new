import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/util/app_color.dart';
import '../../../../core/util/common_widgets.dart';
import '../../../../core/util/responsive_helper.dart';

enum ConfirmActionType { logout, deleteAccount }

class ConfirmActionSheet extends StatefulWidget {
  final ConfirmActionType type;
  final Future<void> Function() onConfirm;

  const ConfirmActionSheet({
    super.key,
    required this.type,
    required this.onConfirm,
  });

  /// Convenience launcher — call this instead of showModalBottomSheet directly.
  static void show({
    required ConfirmActionType type,
    required Future<void> Function() onConfirm,
  }) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmActionSheet(type: type, onConfirm: onConfirm),
    );
  }

  @override
  State<ConfirmActionSheet> createState() => _ConfirmActionSheetState();
}

class _ConfirmActionSheetState extends State<ConfirmActionSheet> {
  final TextEditingController _deleteCtrl = TextEditingController();
  bool _isLoading = false;
  bool _deleteConfirmed = false; // only used for deleteAccount type

  bool get _isDeleteType => widget.type == ConfirmActionType.deleteAccount;

  bool get _canConfirm {
    if (_isLoading) return false;
    if (_isDeleteType) return _deleteConfirmed;
    return true; // logout: always enabled
  }

  @override
  void initState() {
    super.initState();
    if (_isDeleteType) {
      _deleteCtrl.addListener(() {
        final matches = _deleteCtrl.text.trim() == 'DELETE';
        if (matches != _deleteConfirmed) {
          setState(() => _deleteConfirmed = matches);
        }
      });
    }
  }

  @override
  void dispose() {
    _deleteCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);
    try {
      await widget.onConfirm();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    // ── Config per action type ──────────────────────────────────────────
    final String title = _isDeleteType ? 'Delete Account' : 'Logout';
    final String subtitle =
        _isDeleteType
            ? 'This action is permanent and cannot be undone. All your data, orders, and preferences will be erased forever.'
            : 'You will be signed out of your account. You can always log back in.';
    final Color accentColor =
        _isDeleteType ? const Color(0xFFE53935) : AppColor.appPrimary;
    final IconData iconData =
        _isDeleteType ? Icons.delete_forever_rounded : Icons.logout_rounded;
    final String buttonLabel = _isDeleteType ? 'Delete My Account' : 'Logout';

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomPad),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          responsive.spacing24,
          responsive.spacing16,
          responsive.spacing24,
          responsive.spacing32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ──────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.black.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: responsive.spacing24),

            // ── Icon badge ───────────────────────────────────────────────
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: accentColor, size: 30),
            ),
            SizedBox(height: responsive.spacing16),

            // ── Title ────────────────────────────────────────────────────
            text(
              text: title,
              size: responsive.fontSize18,
              fontWeight: FontWeight.w700,
              color: _isDeleteType ? const Color(0xFFE53935) : AppColor.black,
            ),
            SizedBox(height: responsive.spacing8),

            // ── Subtitle ─────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.spacing8),
              child: text(
                text: subtitle,
                size: responsive.fontSize13,
                color: AppColor.black.withOpacity(0.5),
                textAlign: TextAlign.center,
                maxLines: 4,
              ),
            ),

            // ── Delete confirmation input (only for deleteAccount) ───────
            if (_isDeleteType) ...[
              SizedBox(height: responsive.spacing20),
              _buildDeleteConfirmField(responsive, accentColor),
            ],

            SizedBox(height: responsive.spacing24),

            // ── Action buttons ───────────────────────────────────────────
            Row(
              children: [
                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () => Navigator.of(Get.context!).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: responsive.spacing14,
                      ),
                      side: BorderSide(color: AppColor.black.withOpacity(0.15)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: text(
                      text: 'Cancel',
                      size: responsive.fontSize14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.black.withOpacity(0.55),
                    ),
                  ),
                ),
                SizedBox(width: responsive.spacing12),

                // Confirm
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canConfirm ? _handleConfirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      disabledBackgroundColor: accentColor.withOpacity(0.35),
                      padding: EdgeInsets.symmetric(
                        vertical: responsive.spacing14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : text(
                              text: buttonLabel,
                              size: responsive.fontSize14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteConfirmField(
    ResponsiveHelper responsive,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 13,
              color: AppColor.black.withOpacity(0.4),
            ),
            SizedBox(width: 5),
            text(
              text: 'Type ',
              size: responsive.fontSize13,
              color: AppColor.black.withOpacity(0.45),
            ),
            text(
              text: 'DELETE',
              size: responsive.fontSize13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE53935),
              letterSpacing: 0.6,
            ),
            text(
              text: ' to confirm',
              size: responsive.fontSize13,
              color: AppColor.black.withOpacity(0.45),
            ),
          ],
        ),
        SizedBox(height: responsive.spacing8),

        // Text field
        TextField(
          controller: _deleteCtrl,
          autofocus: false,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            TextInputFormatter.withFunction(
              (oldValue, newValue) =>
                  newValue.copyWith(text: newValue.text.toUpperCase()),
            ),
          ],
          style: TextStyle(
            fontSize: responsive.fontSize15,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: _deleteConfirmed ? const Color(0xFFE53935) : AppColor.black,
          ),
          decoration: InputDecoration(
            hintText: 'DELETE',
            hintStyle: TextStyle(
              color: AppColor.black.withOpacity(0.2),
              fontSize: responsive.fontSize15,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.spacing16,
              vertical: responsive.spacing14,
            ),
            // Trailing check icon when confirmed
            suffixIcon:
                _deleteConfirmed
                    ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: const Color(0xFFE53935),
                        size: 20,
                      ),
                    )
                    : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.black.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    _deleteConfirmed
                        ? const Color(0xFFE53935).withOpacity(0.4)
                        : AppColor.black.withOpacity(0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:
                    _deleteConfirmed
                        ? const Color(0xFFE53935)
                        : AppColor.appPrimary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
