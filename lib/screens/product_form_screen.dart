import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../utils/responsive_utils.dart';
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
      
      print('Submitting product data: $data');
      
      final product = widget.product == null
          ? await ProductService.createProduct(data)
          : await ProductService.updateProduct(widget.product!.id, data);
      
      print('Product created/updated: ${product.id}');
      
      if (widget.product == null && _pickedImages.isNotEmpty) {
        print('Uploading ${_pickedImages.length} images for product ${product.id}');
        await ProductService.uploadProductImages(product.id, _pickedImages);
        print('Images uploaded successfully');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null ? 'Ürün başarıyla eklendi!' : 'Ürün başarıyla güncellendi!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('Product submit error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'), 
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
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
        title: Text(widget.product == null ? 'Ürün Ekle' : 'Ürünü Düzenle', style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 18),
          color: Theme.of(context).colorScheme.primary, 
          fontWeight: FontWeight.bold
        )),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.isLargeScreen(context) ? 600 : double.infinity,
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1),
              ),
              margin: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 16),
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Başlık',
                          labelStyle: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14),
                            color: Theme.of(context).colorScheme.onSurfaceVariant
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Başlık gerekli' : null,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)),
                      TextFormField(
                        controller: _descController,
                        decoration: InputDecoration(
                          labelText: 'Açıklama',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        maxLines: 3,
                        validator: (v) => v == null || v.isEmpty ? 'Açıklama gerekli' : null,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)),
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Fiyat (TL)',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? 'Fiyat gerekli' : null,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)),
                      DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        items: _categories.map<DropdownMenuItem<int>>((cat) => DropdownMenuItem<int>(
                          value: cat['id'] as int,
                          child: Text(
                            cat['name'] ?? '',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                            ),
                          ),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCategoryId = val;
                            _selectedSubcategoryId = null;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        validator: (v) => v == null ? 'Kategori gerekli' : null,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)),
                      if (_selectedCategoryId != null)
                        DropdownButtonFormField<int>(
                          value: _selectedSubcategoryId,
                          items: _getSubcategories(_selectedCategoryId)
                              .map<DropdownMenuItem<int>>((subcat) => DropdownMenuItem<int>(
                                    value: subcat['id'] as int,
                                    child: Text(
                                      subcat['name'],
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedSubcategoryId = val),
                          decoration: InputDecoration(
                            labelText: 'Alt Kategori',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                          validator: (v) => v == null ? 'Alt kategori gerekli' : null,
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)),
                      DropdownButtonFormField<String>(
                        value: _status,
                        items: [
                          DropdownMenuItem(
                            value: 'new', 
                            child: Text(
                              'Yeni',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                              )
                            )
                          ),
                          DropdownMenuItem(
                            value: 'used', 
                            child: Text(
                              '2. El',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                              )
                            )
                          ),
                        ],
                        onChanged: (v) => setState(() => _status = v ?? 'used'),
                        decoration: InputDecoration(
                          labelText: 'Durum',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 16)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImages,
                            icon: Icon(
                              Icons.image,
                              size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 18)
                            ),
                            label: Text(
                              'Görselleri Seç',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 14)
                              )
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                              padding: ResponsiveUtils.getResponsiveEdgeInsets(context, baseValue: 12, horizontal: 16, vertical: 8),
                            ),
                          ),
                          if (_pickedImages.isNotEmpty) ...[
                            SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 12)),
                            SizedBox(
                              height: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 60),
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _pickedImages.length,
                                separatorBuilder: (_, __) => SizedBox(width: ResponsiveUtils.getResponsivePadding(context, basePadding: 8)),
                                itemBuilder: (context, idx) {
                                  if (kIsWeb) {
                                    return Container(
                                      width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 60),
                                      height: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 60),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.image, 
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                        size: ResponsiveUtils.getResponsiveIconSize(context, baseSize: 24)
                                      ),
                                    );
                                  } else {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(_pickedImages[idx].path),
                                        width: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 60),
                                        height: ResponsiveUtils.getResponsiveImageSize(context, baseSize: 60),
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsivePadding(context, basePadding: 24)),
                      _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              )
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: ResponsiveUtils.getResponsiveButtonHeight(context, baseHeight: 48),
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  widget.product == null ? 'Ekle' : 'Güncelle', 
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, baseSize: 16), 
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 