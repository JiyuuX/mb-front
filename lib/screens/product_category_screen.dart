import 'package:flutter/material.dart';
import 'product_list_screen.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/responsive_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/product_service.dart';
import 'subcategory_screen.dart';
import 'all_products_screen.dart';

class ProductCategoryScreen extends StatefulWidget {
  const ProductCategoryScreen({super.key});

  @override
  State<ProductCategoryScreen> createState() => _ProductCategoryScreenState();
}

class _ProductCategoryScreenState extends State<ProductCategoryScreen> {
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final cats = await ProductService.fetchCategories();
      if (mounted) {
        setState(() { _categories = cats; });
      }
    } catch (e) {
      print('Kategori çekme hatası: $e');
    }
  }

  Icon _categoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'kadın giyim':
        return const Icon(Icons.female);
      case 'erkek giyim':
        return const Icon(Icons.male);
      case 'çocuk giyim':
        return const Icon(Icons.child_care);
      case 'ayakkabı':
        return const Icon(Icons.directions_run);
      case 'çanta & aksesuar':
      case 'çanta&aksesuar':
        return const Icon(Icons.shopping_bag);
      case 'elektronik':
        return const Icon(Icons.phone_iphone);
      case 'ev & yaşam':
        return const Icon(Icons.chair);
      case 'kitap & dergi':
        return const Icon(Icons.menu_book);
      case 'oyuncak':
        return const Icon(Icons.toys);
      case 'anne & bebek':
        return const Icon(Icons.child_friendly);
      case 'kozmetik & kişisel bakım':
        return const Icon(Icons.spa);
      case 'saat & takı':
        return const Icon(Icons.watch);
      case 'spor & outdoor':
        return const Icon(Icons.sports_soccer);
      case 'diğer':
        return const Icon(Icons.category);
      default:
        return const Icon(Icons.category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Ürün Seçenekleri', style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18)
        )),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: Padding(
        padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
        child: Column(
          children: [
            // Tüm Ürünler Seçeneği
            Container(
              margin: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 0, bottom: 16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AllProductsScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.all_inclusive,
                            color: Theme.of(context).colorScheme.primary,
                            size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 28),
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 20)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tüm Ürünler',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18),
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tüm ürünleri görüntüle ve ara',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Kategorik Ürünler Seçeneği
            Container(
              margin: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 0, bottom: 16),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CategoryListScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.category,
                            color: Theme.of(context).colorScheme.secondary,
                            size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 28),
                          ),
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 20)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kategorik Ürünler',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18),
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Kategoriye göre ürünleri keşfet',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Kategori listesi için ayrı bir widget
class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final cats = await ProductService.fetchCategories();
      if (mounted) {
        setState(() { _categories = cats; });
      }
    } catch (e) {
      print('Kategori çekme hatası: $e');
    }
  }

  Icon _categoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'kadın giyim':
        return const Icon(Icons.female);
      case 'erkek giyim':
        return const Icon(Icons.male);
      case 'çocuk giyim':
        return const Icon(Icons.child_care);
      case 'ayakkabı':
        return const Icon(Icons.directions_run);
      case 'çanta & aksesuar':
      case 'çanta&aksesuar':
        return const Icon(Icons.shopping_bag);
      case 'elektronik':
        return const Icon(Icons.phone_iphone);
      case 'ev & yaşam':
        return const Icon(Icons.chair);
      case 'kitap & dergi':
        return const Icon(Icons.menu_book);
      case 'oyuncak':
        return const Icon(Icons.toys);
      case 'anne & bebek':
        return const Icon(Icons.child_friendly);
      case 'kozmetik & kişisel bakım':
        return const Icon(Icons.spa);
      case 'saat & takı':
        return const Icon(Icons.watch);
      case 'spor & outdoor':
        return const Icon(Icons.sports_soccer);
      case 'diğer':
        return const Icon(Icons.category);
      default:
        return const Icon(Icons.category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Kategori Seç', style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18)
        )),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: _categories.isEmpty
          ? const Center(child: Text('Kategori bulunamadı'))
          : ListView.builder(
              padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return Container(
                  margin: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 0, bottom: 12),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SubCategoryScreen(
                              category: cat,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
                        child: Row(
                          children: [
                            Container(
                              padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _categoryIcon(cat['name'] ?? '').icon,
                                color: Theme.of(context).colorScheme.primary,
                                size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 24),
                              ),
                            ),
                            SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)),
                            Expanded(
                              child: Text(
                                cat['name'] ?? '',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 16),
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
} 