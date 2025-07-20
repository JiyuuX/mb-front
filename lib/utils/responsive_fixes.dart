// Bu dosya tüm ekranlarda yapılması gereken responsive düzeltmeleri içerir
// Her ekran için aşağıdaki değişiklikleri yapın:

/*
1. Import ekleyin (her ekranın başına):
import '../utils/responsive_utils.dart';

2. Sabit değerleri değiştirin:

// Padding/Margin değişiklikleri:
const EdgeInsets.all(16) -> ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16)
const EdgeInsets.all(20) -> ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 20)
const EdgeInsets.all(24) -> ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 24)
const EdgeInsets.symmetric(horizontal: 16, vertical: 8) -> ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 0, horizontal: 16, vertical: 8)
const EdgeInsets.only(bottom: 12) -> ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 0, bottom: 12)
const EdgeInsets.only(right: 16) -> ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 0, right: 16)

// Font size değişiklikleri:
fontSize: 12 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 12)
fontSize: 14 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
fontSize: 16 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 16)
fontSize: 18 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18)
fontSize: 20 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 20)
fontSize: 22 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 22)
fontSize: 24 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 24)
fontSize: 28 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 28)
fontSize: 32 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 32)

// Icon size değişiklikleri:
size: 16 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 16)
size: 20 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 20)
size: 24 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 24)
size: 32 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 32)
size: 40 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 40)
size: 48 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 48)
size: 56 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 56)
size: 64 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 64)

// Image size değişiklikleri:
width: 80, height: 80 -> width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 80), height: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 80)
width: 100, height: 100 -> width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 100), height: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 100)
width: 120, height: 120 -> width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 120), height: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 120)

// SizedBox değişiklikleri:
const SizedBox(height: 8) -> SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 8))
const SizedBox(height: 12) -> SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 12))
const SizedBox(height: 16) -> SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16))
const SizedBox(height: 20) -> SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 20))
const SizedBox(height: 24) -> SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 24))
const SizedBox(height: 32) -> SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 32))
const SizedBox(width: 8) -> SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 8))
const SizedBox(width: 12) -> SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 12))
const SizedBox(width: 16) -> SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 16))
const SizedBox(width: 20) -> SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 20))
const SizedBox(width: 24) -> SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 24))

// Grid değişiklikleri:
crossAxisCount: 1 -> crossAxisCount: ResponsiveUtils.getResponsiveGridCrossAxisCount(context, baseCount: 1)
crossAxisCount: 2 -> crossAxisCount: ResponsiveUtils.getResponsiveGridCrossAxisCount(context, baseCount: 2)
crossAxisCount: 3 -> crossAxisCount: ResponsiveUtils.getResponsiveGridCrossAxisCount(context, baseCount: 3)
crossAxisSpacing: 8 -> crossAxisSpacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 8)
crossAxisSpacing: 16 -> crossAxisSpacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)
mainAxisSpacing: 8 -> mainAxisSpacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 8)
mainAxisSpacing: 16 -> mainAxisSpacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)

// Height değişiklikleri:
height: 50 -> height: ResponsiveUtils.getResponsiveCardHeight(context, baseHeight: 50)
height: 80 -> height: ResponsiveUtils.getResponsiveCardHeight(context, baseHeight: 80)
height: 120 -> height: ResponsiveUtils.getResponsiveCardHeight(context, baseHeight: 120)
height: 200 -> height: ResponsiveUtils.getResponsiveCardHeight(context, baseHeight: 200)
height: 300 -> height: ResponsiveUtils.getResponsiveCardHeight(context, baseHeight: 300)

// Width değişiklikleri:
width: 280 -> width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 280)
width: 320 -> width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 320)
width: 400 -> width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 400)

3. Responsive kontroller ekleyin:
- ResponsiveUtils.isSmallScreen(context) - 480px altı
- ResponsiveUtils.isMediumScreen(context) - 480-768px arası
- ResponsiveUtils.isLargeScreen(context) - 768-1024px arası
- ResponsiveUtils.isExtraLargeScreen(context) - 1024px üstü

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

7. Overflow kontrolü için:
- SingleChildScrollView kullanın
- Flexible/Expanded widget'ları kullanın
- ConstrainedBox kullanın
- LayoutBuilder kullanın

8. Text overflow için:
- maxLines parametresi kullanın
- overflow: TextOverflow.ellipsis kullanın
- Flexible widget ile sarın

9. Image overflow için:
- fit: BoxFit.cover kullanın
- ClipRRect ile sarın
- AspectRatio kullanın

10. ListView overflow için:
- shrinkWrap: true kullanın
- physics: NeverScrollableScrollPhysics() kullanın
- SingleChildScrollView ile sarın
*/ 