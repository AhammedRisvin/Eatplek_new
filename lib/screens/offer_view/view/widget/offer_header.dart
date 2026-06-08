import 'package:flutter/material.dart';

import '../../../../core/util/common_widgets.dart';

class OfferHeader extends StatelessWidget {
  const OfferHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: _HeaderContent(),
    );
  }
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent();

  @override
  Widget build(BuildContext context) {
    return text(
      text: "Today's Hot Offers",
      size: 26,
      fontWeight: FontWeight.w700,
    );
  }
}
