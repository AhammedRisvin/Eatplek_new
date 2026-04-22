import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../orders/model/orders_api_model.dart';

class OrderDetailsController extends GetxController {
  SingleOrder? order;

  @override
  void onInit() {
    super.onInit();
    // SingleOrder is passed from OrdersList via Get.toNamed arguments
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      order = args['order'] as SingleOrder?;
    }
    update(['order_details']);
  }

  // ── Formatted date ────────────────────────────────────────────────────────
  String getFormattedOrderDateTime() {
    if (order?.createdAt == null) return '—';
    return DateFormat('dd-MM-yyyy , hh:mm a').format(order!.createdAt!);
  }

  // ── Items from cartSnapshot ───────────────────────────────────────────────
  List<Item> getCartItems() => order?.cartSnapshot?.items ?? [];

  // ── Totals ────────────────────────────────────────────────────────────────
  AmountSummary? get totals =>
      order?.cartSnapshot?.totals ?? order?.amountSummary;

  double get grandTotal => (totals?.grandTotal ?? 0).toDouble();
  double get subTotal => (totals?.subTotal ?? 0).toDouble();
  double get taxAmount => (totals?.taxAmount ?? 0).toDouble();
  num get taxPercentage => totals?.taxPercentage ?? 0;
  double get packingCharge => (totals?.packingChargeTotal ?? 0).toDouble();
  double get discountTotal => (totals?.discountTotal ?? 0).toDouble();
  double get couponDiscount => (totals?.couponDiscount ?? 0).toDouble();

  // ── Tracking steps ────────────────────────────────────────────────────────
  List<TrackingStep> get trackingSteps => order?.trackingSteps ?? [];

  // ── Status display ────────────────────────────────────────────────────────
  String get formattedStatus {
    final s = order?.orderStatus ?? '';
    return s
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  bool get isPending => (order?.orderStatus ?? '').toLowerCase() == 'pending';

  bool get canCancel => isPending;

  // ── Phone call (vendor phone not in SingleOrder — no-op guard) ────────────
  Future<void> makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      Get.snackbar('Error', 'Phone number not available');
      return;
    }
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Get.snackbar('Error', 'Could not open phone dialer');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not make phone call');
    }
  }

  // ── SMS ───────────────────────────────────────────────────────────────────
  Future<void> sendSMS(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      Get.snackbar('Error', 'Phone number not available');
      return;
    }
    final uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {
        'body': 'Hello, I have a question about my order ${order?.id ?? ''}',
      },
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Get.snackbar('Error', 'Could not open SMS app');
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not send SMS');
    }
  }

  // ── Cancel order ──────────────────────────────────────────────────────────
  Future<void> cancelOrder() async {
    if (!canCancel) {
      Get.snackbar('Error', 'Order cannot be cancelled at this time');
      return;
    }

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Get.snackbar('Success', 'Order has been cancelled');
    }
  }
}
