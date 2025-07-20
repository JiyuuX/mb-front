// Bu script tüm ekranlara responsive import eklemek için kullanılır
// Aşağıdaki ekranlara import eklenmesi gerekiyor:

/*
1. dashboard_screen.dart - ✅ TAMAMLANDI
2. product_list_screen.dart - ✅ TAMAMLANDI
3. profile_screen.dart - ✅ TAMAMLANDI
4. forum_screen.dart - ✅ TAMAMLANDI
5. login_screen.dart
6. register_screen.dart
7. product_detail_screen.dart
8. product_form_screen.dart
9. product_category_screen.dart
10. subcategory_screen.dart
11. my_store_screen.dart
12. favorites_screen.dart
13. events_screen.dart
14. event_detail_screen.dart
15. tickets_screen.dart
16. chat_list_screen.dart
17. chat_screen.dart
18. thread_detail_screen.dart
19. public_profile_screen.dart
20. settings_screen.dart
21. followers_following_list_screen.dart

Her ekrana şu import'u ekleyin:
import '../utils/responsive_utils.dart';

Sonra sabit değerleri responsive hale getirin:
- const EdgeInsets.all() -> ResponsiveUtils.getResponsiveEdgeInsets()
- fontSize: -> ResponsiveUtils.getResponsiveFontSize()
- size: -> ResponsiveUtils.getResponsiveIconSize()
- width:, height: -> ResponsiveUtils.getResponsiveImageSize()
- const SizedBox() -> SizedBox() with ResponsiveUtils.getResponsivePadding()
- crossAxisCount: -> ResponsiveUtils.getResponsiveGridCrossAxisCount()
- height: -> ResponsiveUtils.getResponsiveCardHeight()

Bu değişiklikler tüm ekranları responsive hale getirecek ve overflow hatalarını önleyecektir.
*/ 