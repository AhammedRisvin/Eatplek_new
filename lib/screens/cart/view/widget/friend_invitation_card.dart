import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:eatplek_app/core/util/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/cart_controller.dart';
import '../../model/cart_api_model.dart';
import 'add_friend_bottom_sheet.dart';

class FriendInvitationCard extends StatelessWidget {
  final FriendInvitation invitation;
  final bool isCartOwner;

  const FriendInvitationCard({
    super.key,
    required this.invitation,
    required this.isCartOwner,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();
    final phone = invitation.inviteePhone ?? '';
    final status = invitation.status ?? 'pending';
    final imageUrl = invitation.inviteeProfileImage;
    final invitationId = invitation.inviteId;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: responsive.spacing20,
        horizontal: responsive.spacing20,
      ),
      margin: EdgeInsets.only(bottom: responsive.spacing16),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        border: Border.all(color: AppColor.black.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              text(
                text: 'Friend Invitation Sent',
                size: responsive.fontSize16,
                fontWeight: FontWeight.w600,
                color: AppColor.black,
              ),
              // Remove button — only cart owner can remove
              if (isCartOwner)
                GestureDetector(
                  onTap: () => _showRemoveConfirmation(context, responsive),
                  child: CircleAvatar(
                    radius: responsive.spacing10,
                    backgroundColor: const Color(0xFFFF4C29),
                    child: Icon(
                      Icons.close,
                      color: AppColor.white,
                      size: responsive.spacing14,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: responsive.spacing20),

          // ── Friend info row ──────────────────────────────────────────────
          Row(
            children: [
              // Avatar
              _buildAvatar(responsive, imageUrl),
              SizedBox(width: responsive.spacing10),
              // Phone
              Expanded(
                child: text(
                  text: phone.isNotEmpty ? '+91 $phone' : 'Unknown',
                  size: responsive.fontSize16,
                  fontWeight: FontWeight.w500,
                  color: AppColor.black,
                ),
              ),
              // Status badge
              _buildStatusBadge(responsive, status),
            ],
          ),
          SizedBox(height: responsive.spacing16),

          // ── Footer label ─────────────────────────────────────────────────
          text(
            text: _statusLabel(status),
            size: responsive.fontSize12,
            fontWeight: FontWeight.w300,
            color: AppColor.black.withOpacity(0.6),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ResponsiveHelper responsive, String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl,
          width: responsive.spacing40,
          height: responsive.spacing40,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallbackAvatar(responsive),
        ),
      );
    }
    return _fallbackAvatar(responsive);
  }

  Widget _fallbackAvatar(ResponsiveHelper responsive) {
    return CircleAvatar(
      radius: responsive.spacing20,
      backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
      child: Icon(
        Icons.person_rounded,
        size: responsive.spacing20,
        color: Get.theme.primaryColor,
      ),
    );
  }

  Widget _buildStatusBadge(ResponsiveHelper responsive, String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'accepted':
        bgColor = const Color(0xFFD4EDDA);
        textColor = const Color(0xFF28A745);
        label = 'Accepted';
        break;
      case 'rejected':
      case 'ignored':
        bgColor = const Color(0xFFFFE0DB);
        textColor = const Color(0xFFFF4C29);
        label = 'Declined';
        break;
      default:
        bgColor = const Color(0xFFFED3B3);
        textColor = const Color(0xFFFF4C29);
        label = 'Pending';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: responsive.spacing8,
        horizontal: responsive.spacing16,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: text(
        text: label,
        size: responsive.fontSize14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Your friend has joined the cart!';
      case 'rejected':
      case 'ignored':
        return 'Your friend declined the invitation.';
      default:
        return 'Waiting for Friend to Accept...';
    }
  }

  void _showRemoveConfirmation(
    BuildContext context,
    ResponsiveHelper responsive,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        ),
        title: Text(
          'Remove Friend?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: responsive.fontSize18,
            color: AppColor.black,
          ),
        ),
        content: Text(
          'Are you sure you want to remove this friend invitation from your cart?',
          style: TextStyle(
            fontSize: responsive.fontSize14,
            color: AppColor.black.withOpacity(0.55),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(Get.context!).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColor.black.withOpacity(0.5),
                fontWeight: FontWeight.w600,
                fontSize: responsive.fontSize14,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4C29),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.spacing8),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(Get.context!).pop();
              _removeInvite();
            },
            child: Text(
              'Remove',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: responsive.fontSize14,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _removeInvite() {
    try {
      final cartController = Get.find<CartController>();
      cartController.removeInvite(invitation.inviteId ?? '');
    } catch (e) {
      debugPrint('❌ Could not find CartController: $e');
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FRIEND INVITATIONS SECTION
// Shown inside CartView scrollable body, below price summary.
// - 0 invites  → nothing
// - 1 invite   → single FriendInvitationCard inline
// - 2+ invites → "See Invited Friends (N)" tappable row
// ─────────────────────────────────────────────────────────────────────────────

class FriendInvitationsSection extends StatelessWidget {
  final List<FriendInvitation> invitations;
  final bool isCartOwner;

  const FriendInvitationsSection({
    super.key,
    required this.invitations,
    required this.isCartOwner,
  });

  @override
  Widget build(BuildContext context) {
    if (invitations.isEmpty) return const SizedBox.shrink();

    final responsive = ResponsiveHelper();

    if (invitations.length == 1) {
      return Padding(
        padding: EdgeInsets.only(top: responsive.spacing8),
        child: FriendInvitationCard(
          invitation: invitations.first,
          isCartOwner: isCartOwner,
        ),
      );
    }

    // 2+ invites — show compact row that opens bottom sheet
    return GestureDetector(
      onTap:
          () => InvitedFriendsBottomSheet.show(
            invitations: invitations,
            isCartOwner: isCartOwner,
          ),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(
          top: responsive.spacing8,
          bottom: responsive.spacing4,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing16,
          vertical: responsive.spacing14,
        ),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
          border: Border.all(color: AppColor.black.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          children: [
            // Stacked avatars preview
            _buildStackedAvatars(responsive),
            SizedBox(width: responsive.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text(
                    text: 'See Invited Friends',
                    size: responsive.fontSize14,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black,
                  ),
                  SizedBox(height: responsive.spacing2),
                  text(
                    text: '${invitations.length} people invited to this order',
                    size: responsive.fontSize12,
                    fontWeight: FontWeight.w400,
                    color: AppColor.black.withOpacity(0.5),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColor.black.withOpacity(0.4),
              size: responsive.spacing20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStackedAvatars(ResponsiveHelper responsive) {
    const maxShow = 3;
    final toShow = invitations.take(maxShow).toList();
    final avatarSize = responsive.spacing32;

    return SizedBox(
      width: avatarSize + (toShow.length - 1) * (avatarSize * 0.55),
      height: avatarSize,
      child: Stack(
        children:
            toShow.asMap().entries.map((entry) {
              final i = entry.key;
              final inv = entry.value;
              return Positioned(
                left: i * avatarSize * 0.55,
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.white, width: 2),
                  ),
                  child: ClipOval(
                    child:
                        inv.inviteeProfileImage != null &&
                                inv.inviteeProfileImage!.isNotEmpty
                            ? Image.network(
                              inv.inviteeProfileImage!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, _, _) => _fallbackAvatar(responsive),
                            )
                            : _fallbackAvatar(responsive),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _fallbackAvatar(ResponsiveHelper responsive) {
    return CircleAvatar(
      backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
      child: Icon(
        Icons.person_rounded,
        size: responsive.spacing16,
        color: Get.theme.primaryColor,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INVITED FRIENDS BOTTOM SHEET
// Shown when 2+ invites. Scrollable list of FriendInvitationCards.
// Cart owner also gets "Add Friend" button at bottom.
// ─────────────────────────────────────────────────────────────────────────────

class InvitedFriendsBottomSheet extends StatelessWidget {
  final List<FriendInvitation> invitations;
  final bool isCartOwner;

  const InvitedFriendsBottomSheet({
    super.key,
    required this.invitations,
    required this.isCartOwner,
  });

  static void show({
    required List<FriendInvitation> invitations,
    required bool isCartOwner,
  }) {
    Get.bottomSheet(
      InvitedFriendsBottomSheet(
        invitations: invitations,
        isCartOwner: isCartOwner,
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    return GetBuilder<CartController>(
      id: 'friend_invitations',
      builder: (controller) {
        final currentInvitations = controller.friendInvitations;

        return Container(
          width: responsive.screenWidth,
          constraints: BoxConstraints(maxHeight: responsive.screenHeight * 0.8),
          decoration: BoxDecoration(
            color: AppColor.scaffoldColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: responsive.spacing16,
            right: responsive.spacing16,
            top: responsive.spacing10,
            bottom: responsive.bottomPadding + responsive.spacing20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: responsive.spacing120,
                  height: responsive.spacing4,
                  margin: EdgeInsets.only(bottom: responsive.spacing10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(
                      responsive.largeBorderRadius,
                    ),
                  ),
                ),
              ),
              SizedBox(height: responsive.spacing6),

              // Title row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  text(
                    text: 'Invited Friends',
                    size: responsive.fontSize18,
                    fontWeight: FontWeight.w600,
                    color: AppColor.black,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing12,
                      vertical: responsive.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: Get.theme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: text(
                      text: '${currentInvitations.length} invited',
                      size: responsive.fontSize12,
                      fontWeight: FontWeight.w600,
                      color: Get.theme.primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.spacing16),

              // Scrollable list
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children:
                        currentInvitations
                            .map(
                              (inv) => FriendInvitationCard(
                                invitation: inv,
                                isCartOwner: isCartOwner,
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),

              // Add Friend button — only for cart owner
              if (isCartOwner) ...[
                SizedBox(height: responsive.spacing12),
                GestureDetector(
                  onTap: () {
                    Navigator.of(Get.context!).pop();
                    AddFriendToCartBottomSheet.show();
                  },
                  child: Container(
                    width: responsive.screenWidth,
                    height: responsive.buttonHeight,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(responsive.spacing40),
                      border: Border.all(
                        color: Get.theme.primaryColor,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add_alt_1_rounded,
                          size: responsive.spacing20,
                          color: Get.theme.primaryColor,
                        ),
                        SizedBox(width: responsive.spacing8),
                        Text(
                          'Add Another Friend',
                          style: TextStyle(
                            fontSize: responsive.fontSize16,
                            fontWeight: FontWeight.w600,
                            color: Get.theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
