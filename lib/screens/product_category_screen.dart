import 'package:flutter/material.dart';
import 'product_list_screen.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/product_service.dart';
import 'subcategory_screen.dart';

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
        title: const Text('Kategori Seç'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: _categories.isEmpty
          ? const Center(child: Text('Kategori bulunamadı'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.8,
                    ),
              itemCount: _categories.length,
                    itemBuilder: (context, index) {
                final cat = _categories[index];
                      return InkWell(
                  borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                        builder: (context) => SubCategoryScreen(
                          category: cat,
                        ),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.04),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                        IconTheme(
                          data: IconThemeData(
                            size: 24,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: _categoryIcon(cat['name'] ?? ''),
                        ),
                        const SizedBox(height: 6),
                              Text(
                          cat['name'] ?? '',
                          textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
            ),
    );
  }
} 