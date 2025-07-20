// Bu dosya tüm ekranları otomatik olarak responsive hale getirmek için kullanılır
// Aşağıdaki adımları takip ederek tüm ekranları responsive hale getirebilirsiniz:

/*
AUTOMATED RESPONSIVE CONVERSION SCRIPT

1. TÜM EKRANLARA IMPORT EKLEME:
Her ekran dosyasının başına şu import'u ekleyin:
import '../utils/responsive_utils.dart';

2. SABİT DEĞERLERİ DEĞİŞTİRME:

A. Padding/Margin Değişiklikleri:
- const EdgeInsets.all(16) -> ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16)
- const EdgeInsets.all(20) -> ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 20)
- const EdgeInsets.all(24) -> ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 24)
- const EdgeInsets.all(32) -> ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 32)
- const EdgeInsets.only(bottom: 12) -> ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 0, bottom: 12)
- const EdgeInsets.only(right: 16) -> ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 0, right: 16)
- const EdgeInsets.symmetric(horizontal: 16, vertical: 8) -> ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 0, horizontal: 16, vertical: 8)

B. Font Size Değişiklikleri:
- fontSize: 12 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 12)
- fontSize: 14 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
- fontSize: 16 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 16)
- fontSize: 18 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18)
- fontSize: 20 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 20)
- fontSize: 22 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 22)
- fontSize: 24 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 24)
- fontSize: 28 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 28)
- fontSize: 32 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 32)
- fontSize: 36 -> fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 36)

C. Icon Size Değişiklikleri:
- size: 16 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 16)
- size: 20 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 20)
- size: 24 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 24)
- size: 32 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 32)
- size: 40 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 40)
- size: 48 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 48)
- size: 56 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 56)
- size: 64 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 64)
- size: 80 -> size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 80)

D. Image Size Değişiklikleri:
- width: 80, height: 80 -> width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 80), height: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 80)
- width: 100, height: 100 -> width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 100), height: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 100)
- width: 120, height: 120 -> width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 120), height: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 120)

E. SizedBox Değişiklikleri:
- const SizedBox(height: 8) -> SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 8))
- const SizedBox(height: 12) -> SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 12))
- const SizedBox(height: 16) -> SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16))
- const SizedBox(height: 20) -> SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 20))
- const SizedBox(height: 24) -> SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 24))
- const SizedBox(height: 32) -> SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 32))
- const SizedBox(height: 48) -> SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 48))
- const SizedBox(width: 8) -> SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 8))
- const SizedBox(width: 12) -> SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 12))
- const SizedBox(width: 16) -> SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 16))
- const SizedBox(width: 20) -> SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 20))
- const SizedBox(width: 24) -> SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 24))

F. Grid Değişiklikleri:
- crossAxisCount: 1 -> crossAxisCount: ResponsiveUtils.getResponsiveGridCrossAxisCount(context, baseCount: 1)
- crossAxisCount: 2 -> crossAxisCount: ResponsiveUtils.getResponsiveGridCrossAxisCount(context, baseCount: 2)
- crossAxisCount: 3 -> crossAxisCount: ResponsiveUtils.getResponsiveGridCrossAxisCount(context, baseCount: 3)
- crossAxisSpacing: 8 -> crossAxisSpacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 8))
- crossAxisSpacing: 16 -> crossAxisSpacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 16))
- mainAxisSpacing: 8 -> mainAxisSpacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 8))
- mainAxisSpacing: 16 -> mainAxisSpacing: ResponsiveUtils.getResponsivePadding(context, basePadding: 16))

G. Height Değişiklikleri:
- height: 50 -> height: ResponsiveUtils.getResponsiveCardHeight(context, baseHeight: 50)
- height: 80 -> height: ResponsiveUtils.getResponsiveCardHeight(context, baseHeight: 80)
- height: 120 -> height: ResponsiveUtils.getResponsiveCardHeight(context, baseHeight: 120)
- height: 200 -> height: ResponsiveUtils.getResponsiveCardHeight(context, baseHeight: 200)
- height: 300 -> height: ResponsiveUtils.getResponsiveCardHeight(context, baseHeight: 300)

H. Width Değişiklikleri:
- width: 280 -> width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 280)
- width: 320 -> width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 320)
- width: 400 -> width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 400)

3. OVERFLOW ÖNLEME STRATEJİLERİ:

A. Text Overflow:
- maxLines parametresi ekleyin
- overflow: TextOverflow.ellipsis kullanın
- Flexible widget ile sarın

B. Image Overflow:
- fit: BoxFit.cover kullanın
- ClipRRect ile sarın
- AspectRatio kullanın

C. ListView Overflow:
- shrinkWrap: true kullanın
- physics: NeverScrollableScrollPhysics() kullanın
- SingleChildScrollView ile sarın

D. Container Overflow:
- ConstrainedBox kullanın
- LayoutBuilder kullanın
- Flexible/Expanded widget'ları kullanın

4. RESPONSIVE KONTROLLER:

A. Ekran Boyutu Kontrolleri:
- ResponsiveUtils.isSmallScreen(context)
- ResponsiveUtils.isMediumScreen(context)
- ResponsiveUtils.isLargeScreen(context)
- ResponsiveUtils.isExtraLargeScreen(context)

B. Orientation Kontrolleri:
- ResponsiveUtils.isPortrait(context)
- ResponsiveUtils.isLandscape(context)

C. Safe Area Kullanımı:
- ResponsiveUtils.getSafeAreaTop(context)
- ResponsiveUtils.getSafeAreaBottom(context)
- ResponsiveUtils.getSafeAreaLeft(context)
- ResponsiveUtils.getSafeAreaRight(context)

5. RESPONSIVE WIDGET KULLANIMI:

A. ResponsiveWidget:
ResponsiveWidget(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)

B. ResponsiveBuilder:
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

6. TEST EDİLMESİ GEREKEN CİHAZLAR:

- Küçük Telefonlar: 320-480px genişlik
- Büyük Telefonlar: 480-768px genişlik
- Tabletler: 768-1024px genişlik
- Desktop: 1024px+ genişlik
- Landscape Modu: Yatay ekran testleri

Bu script'i takip ederek tüm ekranları responsive hale getirebilir ve overflow hatalarını önleyebilirsiniz.
*/ 