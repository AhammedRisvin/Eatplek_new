import 'package:flutter/material.dart';

import 'widget/coupon_bg_custom_paint.dart';

class CouponsView extends StatefulWidget {
  const CouponsView({super.key});

  @override
  State<CouponsView> createState() => _CouponsViewState();
}

class _CouponsViewState extends State<CouponsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Coupons', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: 6, // Adjust based on your data
          itemBuilder: (context, index) {
            return CouponCard(
              discountPercent: '50%',
              title: 'Launch Offer',
              description: 'Lorem ipsum is simply dummy text of the printing and typesetting industry. Lorem',
              code: 'LAUNCH50',
            );
          },
        ),
      ),
    );
  }
}

class CouponCard extends StatelessWidget {
  final String discountPercent;
  final String title;
  final String description;
  final String code;

  const CouponCard({
    super.key,
    required this.discountPercent,
    required this.title,
    required this.description,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomPaint(painter: RPSCustomPainter(), size: const Size(double.infinity, 16)),
      ),
    );
  }
}
