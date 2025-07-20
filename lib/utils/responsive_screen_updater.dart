// Bu dosya tüm ekranları responsive hale getirmek için kullanılacak
// Her ekran için aşağıdaki değişiklikleri yapmanız gerekiyor:

/*
1. Import ekleyin:
import '../utils/responsive_utils.dart';

2. Sabit değerleri responsive hale getirin:

// Padding/Margin
const EdgeInsets.all(16) -> ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16)
const EdgeInsets.only(bottom: 12) -> ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 0, bottom: 12)
const EdgeInsets.symmetric(horizontal: 8, vertical: 4) -> ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 0, horizontal: 8, vertical: 4)

// Font Size
fontSize: 16 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 16)
fontSize: 18 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18)
fontSize: 20 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 20)
fontSize: 24 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 24)

// Icon Size
size: 24 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 24)
size: 32 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 32)
size: 40 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 40)
size: 64 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 64)

// Image Size
width: 80, height: 80 -> width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 80), height: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 80)

// SizedBox
const SizedBox(height: 16) -> SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16))
const SizedBox(width: 20) -> SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 20))

// Grid
crossAxisCount: 2 -> crossAxisCount: ResponsiveUtils.getResponsiveGridCrossAxisCount(context, baseCount: 2)
crossAxisSpacing: 16 -> crossAxisSpacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)
mainAxisSpacing: 16 -> mainAxisSpacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)

// Card Height
height: 200 -> height: ResponsiveUtils.getResponsiveCardHeight(context, baseHeight: 200)

// Container Width
width: 280 -> width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 280)

3. Responsive kontroller ekleyin:
- ResponsiveUtils.isSmallScreen(context)
- ResponsiveUtils.isMediumScreen(context)
- ResponsiveUtils.isLargeScreen(context)
- ResponsiveUtils.isExtraLargeScreen(context)

4. Safe Area kullanın:
- ResponsiveUtils.getSafeAreaTop(context)
- ResponsiveUtils.getSafeAreaBottom(context)
- ResponsiveUtils.getSafeAreaLeft(context)
- ResponsiveUtils.getSafeAreaRight(context)

5. ResponsiveWidget kullanın:
ResponsiveWidget(
  mobile: MobileWidget(),
  tablet: TabletWidget(),
  desktop: DesktopWidget(),
)

6. ResponsiveBuilder kullanın:
ResponsiveBuilder(
  builder: (context, isSmallScreen, isMediumScreen, isLargeScreen) {
    if (isSmallScreen) {
      return SmallScreenWidget();
    } else if (isMediumScreen) {
      return MediumScreenWidget();
    } else {
      return LargeScreenWidget();
    }
  },
)
*/ 