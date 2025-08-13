import 'package:eatplek_app/core/util/app_color.dart';
import 'package:eatplek_app/core/util/common_widgets.dart';
import 'package:fittor/fittor.dart';
import 'package:flutter/material.dart';

class FriendInvitationCard extends StatelessWidget {
  const FriendInvitationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.wp(100),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.black.withOpacity(0.03)),
        boxShadow: [BoxShadow(color: AppColor.black.withOpacity(0.05), blurRadius: 24, offset: const Offset(0, 0))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              text(text: 'Friend Invitation Sent', size: 16, fontWeight: FontWeight.w600),
              CircleAvatar(
                radius: 10,
                backgroundColor: Color(0XFFFF4C29),
                child: Icon(Icons.close, color: AppColor.white, size: 14),
              ),
            ],
          ),
          20.h,
          Row(
            children: [
              image(
                url: 'https://picsum.photos/250?image=30',
                width: 40,
                height: 40,
                borderRadius: BorderRadius.circular(20),
              ),
              10.w,
              text(text: '+91 8594060340', size: 16, fontWeight: FontWeight.w500),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(color: Color(0XFFFED3B3), borderRadius: BorderRadius.circular(100)),
                child: text(text: 'Pending', size: 14, fontWeight: FontWeight.w500, color: Color(0XFFFF4C29)),
              ),
            ],
          ),
          16.h,
          text(
            text: 'Waiting for Friend to Accept...',
            size: 12,
            fontWeight: FontWeight.w300,
            color: AppColor.black.withOpacity(0.6),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
