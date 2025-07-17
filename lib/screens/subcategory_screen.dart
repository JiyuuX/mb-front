import 'package:flutter/material.dart';
import 'product_list_screen.dart';

class SubCategoryScreen extends StatelessWidget {
  final Map<String, dynamic> category;
  const SubCategoryScreen({Key? key, required this.category}) : super(key: key);

  Icon _subcategoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'elbise':
        return const Icon(Icons.checkroom);
      case 't-shirt':
        return const Icon(Icons.emoji_people);
      case 'pantolon':
        return const Icon(Icons.checkroom);
      case 'etek':
        return const Icon(Icons.checkroom);
      case 'ceket':
        return const Icon(Icons.checkroom);
      case 'bluz':
        return const Icon(Icons.checkroom);
      case 'çanta&cüzdan':
      case 'çanta':
        return const Icon(Icons.shopping_bag);
      case 'ayakkabı':
        return const Icon(Icons.directions_run);
      case 'takı & aksesuar':
      case 'aksesuar':
        return const Icon(Icons.watch);
      case 'gömlek':
        return const Icon(Icons.checkroom);
      case 'kız çocuk':
      case 'erkek çocuk':
      case 'bebek':
      case 'bebek giyim':
        return const Icon(Icons.child_care);
      case 'roman':
        return const Icon(Icons.menu_book);
      case 'telefon':
        return const Icon(Icons.phone_iphone);
      case 'bilgisayar':
        return const Icon(Icons.computer);
      case 'tablet':
        return const Icon(Icons.tablet_mac);
      case 'kulaklık':
        return const Icon(Icons.headphones);
      case 'dekorasyon':
        return const Icon(Icons.chair);
      case 'oyuncak':
        return const Icon(Icons.toys);
      case 'makyaj':
      case 'cilt bakımı':
      case 'saç bakımı':
      case 'parfüm':
        return const Icon(Icons.spa);
      case 'kol saati':
        return const Icon(Icons.watch);
      case 'spor giyim':
      case 'spor ayakkabı':
        return const Icon(Icons.sports_soccer);
      case 'diger':
      case 'diğer':
        return const Icon(Icons.category);
      default:
        return const Icon(Icons.category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List subcategories = category['subcategories'] ?? [];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('${category['name']} Alt Kategorileri'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: subcategories.isEmpty
          ? const Center(child: Text('Alt kategori bulunamadı'))
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: subcategories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final subcat = subcategories[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  minLeadingWidth: 0,
                  leading: IconTheme(
                    data: IconThemeData(
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: _subcategoryIcon(subcat['name'] ?? ''),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  tileColor: Theme.of(context).colorScheme.primary,
                  title: Text(
                    subcat['name'],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onPrimary, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProductListScreen(
                          category: category['id'].toString(),
                          subcategory: subcat['id'].toString(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
} 