import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getResponsiveFontSize(BuildContext context, {
    double baseSize = 16.0,
    double? minSize,
    double? maxSize,
  }) {
    final width = screenWidth(context);
    final height = screenHeight(context);
    
    // Ekran boyutuna göre font boyutunu ayarla
    double fontSize = baseSize;
    
    if (width < 320) { // Çok küçük ekranlar
      fontSize = baseSize * 0.8;
    } else if (width < 480) { // Küçük ekranlar
      fontSize = baseSize * 0.9;
    } else if (width < 768) { // Orta ekranlar
      fontSize = baseSize;
    } else if (width < 1024) { // Büyük ekranlar
      fontSize = baseSize * 1.1;
    } else { // Çok büyük ekranlar
      fontSize = baseSize * 1.2;
    }
    
    // Minimum ve maksimum değerleri uygula
    if (minSize != null && fontSize < minSize) fontSize = minSize;
    if (maxSize != null && fontSize > maxSize) fontSize = maxSize;
    
    return fontSize;
  }

  static double getResponsivePadding(BuildContext context, {
    double basePadding = 16.0,
    double? minPadding,
    double? maxPadding,
  }) {
    final width = screenWidth(context);
    
    double padding = basePadding;
    
    if (width < 320) {
      padding = basePadding * 0.7;
    } else if (width < 480) {
      padding = basePadding * 0.8;
    } else if (width < 768) {
      padding = basePadding;
    } else if (width < 1024) {
      padding = basePadding * 1.2;
    } else {
      padding = basePadding * 1.5;
    }
    
    if (minPadding != null && padding < minPadding) padding = minPadding;
    if (maxPadding != null && padding > maxPadding) padding = maxPadding;
    
    return padding;
  }

  static EdgeInsets getResponsiveEdgeInsets(BuildContext context, {
    double baseValue = 16.0,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return EdgeInsets.only(
      top: top ?? vertical ?? baseValue,
      bottom: bottom ?? vertical ?? baseValue,
      left: left ?? horizontal ?? baseValue,
      right: right ?? horizontal ?? baseValue,
    );
  }

  static double getResponsiveIconSize(BuildContext context, {
    double baseSize = 24.0,
    double? minSize,
    double? maxSize,
  }) {
    final width = screenWidth(context);
    
    double iconSize = baseSize;
    
    if (width < 320) {
      iconSize = baseSize * 0.8;
    } else if (width < 480) {
      iconSize = baseSize * 0.9;
    } else if (width < 768) {
      iconSize = baseSize;
    } else if (width < 1024) {
      iconSize = baseSize * 1.1;
    } else {
      iconSize = baseSize * 1.2;
    }
    
    if (minSize != null && iconSize < minSize) iconSize = minSize;
    if (maxSize != null && iconSize > maxSize) iconSize = maxSize;
    
    return iconSize;
  }

  static int getResponsiveGridCrossAxisCount(BuildContext context, {
    int baseCount = 2,
    int? minCount,
    int? maxCount,
  }) {
    final width = screenWidth(context);
    
    int crossAxisCount = baseCount;
    
    if (width < 480) {
      crossAxisCount = 1;
    } else if (width < 768) {
      crossAxisCount = 2;
    } else if (width < 1024) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 4;
    }
    
    if (minCount != null && crossAxisCount < minCount) crossAxisCount = minCount;
    if (maxCount != null && crossAxisCount > maxCount) crossAxisCount = maxCount;
    
    return crossAxisCount;
  }

  static double getResponsiveCardHeight(BuildContext context, {
    double baseHeight = 120.0,
    double? minHeight,
    double? maxHeight,
  }) {
    final width = screenWidth(context);
    final height = screenHeight(context);
    
    double cardHeight = baseHeight;
    
    if (width < 320) {
      cardHeight = baseHeight * 0.8;
    } else if (width < 480) {
      cardHeight = baseHeight * 0.9;
    } else if (width < 768) {
      cardHeight = baseHeight;
    } else if (width < 1024) {
      cardHeight = baseHeight * 1.1;
    } else {
      cardHeight = baseHeight * 1.2;
    }
    
    if (minHeight != null && cardHeight < minHeight) cardHeight = minHeight;
    if (maxHeight != null && cardHeight > maxHeight) cardHeight = maxHeight;
    
    return cardHeight;
  }

  static double getResponsiveImageSize(BuildContext context, {
    double baseSize = 80.0,
    double? minSize,
    double? maxSize,
  }) {
    final width = screenWidth(context);
    
    double imageSize = baseSize;
    
    if (width < 320) {
      imageSize = baseSize * 0.7;
    } else if (width < 480) {
      imageSize = baseSize * 0.8;
    } else if (width < 768) {
      imageSize = baseSize;
    } else if (width < 1024) {
      imageSize = baseSize * 1.2;
    } else {
      imageSize = baseSize * 1.5;
    }
    
    if (minSize != null && imageSize < minSize) imageSize = minSize;
    if (maxSize != null && imageSize > maxSize) imageSize = maxSize;
    
    return imageSize;
  }

  static bool isSmallScreen(BuildContext context) {
    return screenWidth(context) < 480;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = screenWidth(context);
    return width >= 480 && width < 768;
  }

  static bool isLargeScreen(BuildContext context) {
    final width = screenWidth(context);
    return width >= 768 && width < 1024;
  }

  static bool isExtraLargeScreen(BuildContext context) {
    return screenWidth(context) >= 1024;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static double getSafeAreaTop(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double getSafeAreaBottom(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  static double getSafeAreaLeft(BuildContext context) {
    return MediaQuery.of(context).padding.left;
  }

  static double getSafeAreaRight(BuildContext context) {
    return MediaQuery.of(context).padding.right;
  }

  static double getResponsiveButtonHeight(BuildContext context, {
    double baseHeight = 48.0,
    double? minHeight,
    double? maxHeight,
  }) {
    final width = screenWidth(context);
    
    double buttonHeight = baseHeight;
    
    if (width < 320) {
      buttonHeight = baseHeight * 0.8;
    } else if (width < 480) {
      buttonHeight = baseHeight * 0.9;
    } else if (width < 768) {
      buttonHeight = baseHeight;
    } else if (width < 1024) {
      buttonHeight = baseHeight * 1.1;
    } else {
      buttonHeight = baseHeight * 1.2;
    }
    
    if (minHeight != null && buttonHeight < minHeight) buttonHeight = minHeight;
    if (maxHeight != null && buttonHeight > maxHeight) buttonHeight = maxHeight;
    
    return buttonHeight;
  }
}

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1024) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= 768) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isSmallScreen, bool isMediumScreen, bool isLargeScreen) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    final isSmallScreen = width < 480;
    final isMediumScreen = width >= 480 && width < 768;
    final isLargeScreen = width >= 768;
    
    return builder(context, isSmallScreen, isMediumScreen, isLargeScreen);
  }
} 