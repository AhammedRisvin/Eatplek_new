import 'package:flutter/material.dart';

import '../../../../core/util/responsive_helper.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isVisible;
  final String message;

  const LoadingOverlay({super.key, required this.isVisible, this.message = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper();

    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: responsive.spacing40,
                height: responsive.spacing40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: responsive.spacing16),
              Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: responsive.fontSize16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
