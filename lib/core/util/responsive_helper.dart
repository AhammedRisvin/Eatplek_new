import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ResponsiveHelper - A singleton utility class to handle all responsive calculations
/// Works with GetX and provides responsive values for the entire app
class ResponsiveHelper {
  static final ResponsiveHelper _instance = ResponsiveHelper._internal();

  factory ResponsiveHelper() {
    return _instance;
  }

  ResponsiveHelper._internal();

  // ============ SCREEN DIMENSIONS ============
  double get screenWidth => Get.width;
  double get screenHeight => Get.height;
  double get screenDiagonal => Get.mediaQuery.size.diagonal;

  // ============ SAFE AREA & PADDING ============
  EdgeInsets get safeAreaPadding => Get.mediaQuery.padding;
  double get topPadding => Get.mediaQuery.padding.top;
  double get bottomPadding => Get.mediaQuery.padding.bottom;

  // ============ DEVICE CLASSIFICATION ============
  /// Classify device based on width
  DeviceType get deviceType {
    if (screenWidth < 360) {
      return DeviceType.small; // Small phones (like SE)
    } else if (screenWidth < 420) {
      return DeviceType.medium; // Medium phones (like Pixel 6)
    } else {
      return DeviceType.large; // Large phones (like Plus models)
    }
  }

  // ============ RESPONSIVE SCALING FACTORS ============
  /// Base width used for design (Pixel 6 width = 412dp)
  static const double _baseWidth = 412;
  static const double _baseHeight = 915;

  /// Scale factor based on actual device width
  double get widthScale => screenWidth / _baseWidth;
  double get heightScale => screenHeight / _baseHeight;
  double get textScale =>
      widthScale * 0.95; // Slightly less aggressive for text

  // ============ RESPONSIVE SPACING ============
  /// All spacing values scale based on device width
  double get spacing2 => 2 * widthScale;
  double get spacing3 => 3 * widthScale;
  double get spacing4 => 4 * widthScale;
  double get spacing5 => 5 * widthScale;
  double get spacing6 => 6 * widthScale;
  double get spacing7 => 7 * widthScale;
  double get spacing8 => 8 * widthScale;
  double get spacing9 => 9 * widthScale;
  double get spacing10 => 10 * widthScale;
  double get spacing11 => 11 * widthScale;
  double get spacing12 => 12 * widthScale;
  double get spacing13 => 13 * widthScale;
  double get spacing14 => 14 * widthScale;
  double get spacing15 => 15 * widthScale;
  double get spacing16 => 16 * widthScale;
  double get spacing18 => 18 * widthScale;
  double get spacing20 => 20 * widthScale;
  double get spacing24 => 24 * widthScale;
  double get spacing25 => 25 * widthScale;
  double get spacing28 => 28 * widthScale;
  double get spacing30 => 30 * widthScale;
  double get spacing32 => 32 * widthScale;
  double get spacing35 => 35 * widthScale;
  double get spacing36 => 36 * widthScale;
  double get spacing40 => 40 * widthScale;
  double get spacing48 => 48 * widthScale;
  double get spacing50 => 50 * widthScale;
  double get spacing55 => 55 * widthScale;
  double get spacing60 => 60 * widthScale;
  double get spacing80 => 80 * widthScale;
  double get spacing83 => 83 * widthScale;
  double get spacing100 => 100 * widthScale;
  double get spacing120 => 120 * widthScale;
  double get spacing150 => 150 * widthScale;
  double get spacing160 => 160 * widthScale;
  double get spacing180 => 180 * widthScale;
  double get spacing200 => 200 * widthScale;
  double get spacing201 => 201 * widthScale;
  double get spacing280 => 280 * widthScale;
  double get spacing300 => 300 * widthScale;

  // ============ RESPONSIVE FONT SIZES ============
  /// Font sizes scale based on text scale factor
  double get fontSize8 => 8 * textScale;
  double get fontSize9 => 9 * textScale;
  double get fontSize10 => 10 * textScale;
  double get fontSize11 => 11 * textScale;
  double get fontSize12 => 12 * textScale;
  double get fontSize13 => 13 * textScale;
  double get fontSize14 => 14 * textScale;
  double get fontSize15 => 15 * textScale;
  double get fontSize16 => 16 * textScale;
  double get fontSize18 => 18 * textScale;
  double get fontSize20 => 20 * textScale;
  double get fontSize22 => 22 * textScale;
  double get fontSize24 => 24 * textScale;
  double get fontSize26 => 26 * textScale;
  double get fontSize28 => 28 * textScale;
  double get fontSize32 => 32 * textScale;
  double get fontSize36 => 36 * textScale;

  // ============ RESPONSIVE WIDTHS & HEIGHTS ============
  /// Width percentages of screen
  double widthPercent(double percent) => screenWidth * (percent / 100);
  double heightPercent(double percent) => screenHeight * (percent / 100);

  /// Fixed responsive dimensions
  double get buttonHeight => 55 * widthScale;
  double get buttonSmallHeight => 30 * widthScale;
  double get smallButtonWidth => 80 * widthScale;
  double get cardBorderRadius => 10 * widthScale;
  double get largeBorderRadius => 20 * widthScale;
  double get smallBorderRadius => 4 * widthScale;
  double get extraLargeBorderRadius => 30 * widthScale;

  // ============ RESPONSIVE ICON SIZES ============
  double get iconSizeSmall => 20 * widthScale;
  double get iconSizeMedium => 24 * widthScale;
  double get iconSizeLarge => 32 * widthScale;
  double get iconSizeXL => 60 * widthScale;
  double get iconSizeXXL => 80 * widthScale;

  // ============ RESPONSIVE IMAGE HEIGHTS ============
  double get bannerHeight => 180 * heightScale;
  double get cardImageHeight => 140 * heightScale;
  double get avatarSize => 50 * widthScale;
  double get largeAvatarSize => 80 * widthScale;
  double get paymentIconSize => 50 * widthScale;
  double get restaurantImageSize => 83 * widthScale;

  // ============ RESPONSIVE SHADOW VALUES ============
  double get shadowBlurSmall => 8 * widthScale;
  double get shadowBlurMedium => 12 * widthScale;
  double get shadowBlurLarge => 24 * widthScale;
  double get shadowOffsetSmall => 2 * widthScale;
  double get shadowOffsetMedium => 4 * widthScale;

  // ============ RESPONSIVE DIVIDER & BORDER ============
  double get borderWidthThin => 1 * widthScale;
  double get borderWidthMedium => 1.5 * widthScale;
  double get borderWidthThick => 2 * widthScale;
  double get dividerThickness => 1 * widthScale;

  // ============ APPBAR & BOTTOM NAVIGATION ============
  double get appBarHeight => 56 * heightScale;
  double get appBarLeadingWidth => 80 * widthScale;
  double get bottomNavHeight => 70 * heightScale;
  double get bottomNavButtonHeight => 60 * heightScale;

  // ============ FORM & INPUT ============
  double get formFieldHeight => 50 * heightScale;
  double get formFieldPaddingHorizontal => 14 * widthScale;
  double get formFieldPaddingVertical => 12 * heightScale;
  double get inputBorderRadius => 8 * widthScale;

  // ============ GRID & LAYOUT ============
  int get gridCrossAxisCount {
    switch (deviceType) {
      case DeviceType.small:
        return 2;
      case DeviceType.medium:
        return 2;
      case DeviceType.large:
        return 2;
    }
  }

  double get gridChildAspectRatio {
    // Responsive aspect ratio calculation
    return screenHeight / screenWidth * 0.36;
  }

  double get gridChildAspectRatioForFood {
    // Responsive aspect ratio calculation
    return screenHeight / screenWidth * 0.325;
  }

  double get gridChildAspectRatioForOfferFood {
    // Responsive aspect ratio calculation
    return screenHeight / screenWidth * 0.285;
  }

  double get gridMainAxisSpacing => spacing16;
  double get gridCrossAxisSpacing => spacing12;

  // ============ PADDING & MARGINS ============
  EdgeInsets get horizontalPadding20 =>
      EdgeInsets.symmetric(horizontal: spacing20);
  EdgeInsets get horizontalPadding16 =>
      EdgeInsets.symmetric(horizontal: spacing16);
  EdgeInsets get verticalPadding20 => EdgeInsets.symmetric(vertical: spacing20);
  EdgeInsets get verticalPadding12 => EdgeInsets.symmetric(vertical: spacing12);
  EdgeInsets get allPadding20 => EdgeInsets.all(spacing20);
  EdgeInsets get allPadding16 => EdgeInsets.all(spacing16);
  EdgeInsets get allPadding12 => EdgeInsets.all(spacing12);
  EdgeInsets get allPadding10 => EdgeInsets.all(spacing10);

  // ============ CONTAINER PADDING FOR SECTIONS ============
  EdgeInsets get containerPadding =>
      EdgeInsets.symmetric(vertical: spacing20, horizontal: spacing20);

  EdgeInsets get containerPaddingSmall =>
      EdgeInsets.symmetric(vertical: spacing12, horizontal: spacing12);

  EdgeInsets get containerPaddingLarge =>
      EdgeInsets.symmetric(vertical: spacing24, horizontal: spacing20);

  // ============ BOTTOM SHEET PADDING ============
  EdgeInsets get bottomSheetPadding => EdgeInsets.only(
    left: spacing16,
    right: spacing16,
    top: spacing10,
    bottom: spacing20,
  );

  // ============ UTILITY METHODS ============
  /// Get responsive value based on device type
  T getResponsiveValue<T>({
    required T small,
    required T medium,
    required T large,
  }) {
    switch (deviceType) {
      case DeviceType.small:
        return small;
      case DeviceType.medium:
        return medium;
      case DeviceType.large:
        return large;
    }
  }

  /// Check if device is in landscape
  bool get isLandscape => Get.mediaQuery.orientation == Orientation.landscape;

  /// Check if device is in portrait
  bool get isPortrait => Get.mediaQuery.orientation == Orientation.portrait;

  /// Get responsive padding based on safe area
  EdgeInsets getSafeAreaPadding({
    double horizontal = 20,
    double vertical = 20,
  }) {
    return EdgeInsets.only(
      top: topPadding + spacing(vertical),
      bottom: bottomPadding + spacing(vertical),
      left: spacing(horizontal),
      right: spacing(horizontal),
    );
  }

  /// Convert any value to responsive value
  double spacing(double value) => value * widthScale;

  /// Create responsive box shadow
  BoxShadow responsiveBoxShadow({
    Color color = const Color(0x00000000),
    double opacity = 0.05,
    double blurRadius = 24,
    double offsetY = 0,
  }) {
    return BoxShadow(
      color: color.withOpacity(opacity),
      blurRadius: blurRadius * widthScale,
      offset: Offset(0, offsetY * heightScale),
    );
  }

  /// Create responsive border decoration
  BoxDecoration responsiveContainer({
    Color backgroundColor = Colors.white,
    double? borderRadius,
    Color borderColor = Colors.transparent,
    double borderWidth = 1,
    bool addShadow = true,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius ?? largeBorderRadius),
      border: Border.all(color: borderColor, width: borderWidth * widthScale),
      boxShadow:
          addShadow
              ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: shadowBlurLarge,
                  offset: Offset(0, shadowOffsetMedium),
                ),
              ]
              : [],
    );
  }
}

/// Device type enum for classification
enum DeviceType { small, medium, large }

/// Extension on BuildContext for easier access
extension ResponsiveContextExtension on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper();
}

/// Extension for easier access with Get
extension ResponsiveGetExtension on GetInterface {
  ResponsiveHelper get responsive => ResponsiveHelper();
}

extension SizeExtension on Size {
  double get diagonal {
    // Pythagorean theorem: √(width² + height²)
    return math.sqrt((width * width) + (height * height));
  }
}
