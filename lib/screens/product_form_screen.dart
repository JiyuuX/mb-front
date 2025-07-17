import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  final String? category;
  const ProductFormScreen({super.key, this.product, this.category});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  String _status = 'used';
  List<XFile> _pickedImages = [];
  bool _isLoading = false;
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    // Kategori ve alt kategori çekme fonksiyonu her zaman çağrılacak
    _fetchCategories();
    if (widget.product != null) {
      _titleController.text = widget.product!.title;
      _descController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _selectedCategoryId = widget.product!.category;
      _selectedSubcategoryId = widget.product!.subcategory;
      _status = widget.product!.status;
    } else if (widget.category != null) {
      _selectedCategoryId = int.tryParse(widget.category!);
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final cats = await ProductService.fetchCategories();
      setState(() { _categories = cats; });
    } catch (e, st) {
      print('Kategori çekme hatası: $e');
      print(st);
    }
  }

  // Güvenli kategori bulma fonksiyonu
  Map<String, dynamic>? _findCategory(int? categoryId) {
    if (categoryId == null || _categories.isEmpty) return null;
    try {
      return _categories.firstWhere((cat) => cat['id'] == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Güvenli alt kategori listesi alma
  List<Map<String, dynamic>> _getSubcategories(int? categoryId) {
    final category = _findCategory(categoryId);
    if (category == null) return [];
    return (category['subcategories'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _pickedImages = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });
    try {
      final data = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'category': _selectedCategoryId,
        'subcategory': _selectedSubcategoryId,
        'status': _status,
      };
      final product = widget.product == null
          ? await ProductService.createProduct(data)
          : await ProductService.updateProduct(widget.product!.id, data);
      if (widget.product == null && _pickedImages.isNotEmpty) {
        await ProductService.uploadProductImages(product.id, _pickedImages);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.product == null ? 'Ürün Ekle' : 'Ürünü Düzenle', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: Center(
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
          ),
          margin: const EdgeInsets.all(24),
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Başlık',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Başlık gerekli' : null,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: 'Açıklama',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    maxLines: 3,
                    validator: (v) => v == null || v.isEmpty ? 'Açıklama gerekli' : null,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Fiyat (TL)',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Fiyat gerekli' : null,
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    items: _categories.map<DropdownMenuItem<int>>((cat) => DropdownMenuItem<int>(
                      value: cat['id'] as int,
                      child: Text(cat['name'] ?? ''),
                    )).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategoryId = val;
                        _selectedSubcategoryId = null;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Kategori',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    validator: (v) => v == null ? 'Kategori gerekli' : null,
                  ),
                  const SizedBox(height: 18),
                  if (_selectedCategoryId != null)
                    DropdownButtonFormField<int>(
                      value: _selectedSubcategoryId,
                      items: _getSubcategories(_selectedCategoryId)
                          .map<DropdownMenuItem<int>>((subcat) => DropdownMenuItem<int>(
                                value: subcat['id'] as int,
                                child: Text(subcat['name']),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedSubcategoryId = val),
                      decoration: InputDecoration(
                        labelText: 'Alt Kategori',
                        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      validator: (v) => v == null ? 'Alt kategori gerekli' : null,
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    value: _status,
                    items: const [
                      DropdownMenuItem(value: 'new', child: Text('Yeni')),
                      DropdownMenuItem(value: 'used', child: Text('2. El')),
                    ],
                    onChanged: (v) => setState(() => _status = v ?? 'used'),
                    decoration: InputDecoration(
                      labelText: 'Durum',
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.image),
                        label: const Text('Görselleri Seç'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_pickedImages.isNotEmpty)
                        Expanded(
                          child: SizedBox(
                            height: 60,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _pickedImages.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, idx) {
                                if (kIsWeb) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.image, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                                  );
                                } else {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(_pickedImages[idx].path),
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: Text(widget.product == null ? 'Ekle' : 'Güncelle', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 