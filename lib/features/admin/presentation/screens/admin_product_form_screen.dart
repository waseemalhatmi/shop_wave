import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_providers.dart';
import '../providers/admin_categories_notifier.dart';
import '../../../home/presentation/providers/home_providers.dart';

class AdminProductFormScreen extends ConsumerStatefulWidget {
  const AdminProductFormScreen({super.key, this.product});
  final Map<String, dynamic>? product;

  @override
  ConsumerState<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends ConsumerState<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameEn = TextEditingController(text: widget.product?['name_en'] as String? ?? '');
  late final TextEditingController _nameAr = TextEditingController(text: widget.product?['name_ar'] as String? ?? '');
  late final TextEditingController _descEn = TextEditingController(text: widget.product?['description_en'] as String? ?? '');
  late final TextEditingController _descAr = TextEditingController(text: widget.product?['description_ar'] as String? ?? '');
  late final TextEditingController _price = TextEditingController(text: widget.product?['base_price']?.toString() ?? '');
  late final TextEditingController _discount = TextEditingController(text: widget.product?['discount_percent']?.toString() ?? '0');
  late final TextEditingController _sku = TextEditingController(text: widget.product?['sku'] as String? ?? '');
  late final TextEditingController _stock = TextEditingController(text: '0');
  late final TextEditingController _slug = TextEditingController(text: widget.product?['slug'] as String? ?? '');
  late bool _isFeatured = widget.product?['is_featured'] as bool? ?? false;
  late bool _isNewArrival = widget.product?['is_new_arrival'] as bool? ?? false;
  late bool _isOnSale = widget.product?['is_on_sale'] as bool? ?? false;
  late bool _isActive = widget.product?['is_active'] as bool? ?? true;
  String? _categoryId;
  final List<XFile> _newImages = [];
  final List<Map<String, dynamic>> _variants = [];
  bool _isLoading = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.product?['category_id'] as String?;
  }

  @override
  void dispose() {
    _nameEn.dispose(); _nameAr.dispose(); _descEn.dispose(); _descAr.dispose();
    _price.dispose(); _discount.dispose(); _sku.dispose(); _slug.dispose(); _stock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final categoriesAsync = ref.watch(adminCategoriesNotifierProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(_isEditing ? (isAr ? 'تعديل المنتج' : 'Edit Product') : (isAr ? 'إضافة منتج' : 'Add Product'), style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => GoRouter.of(context).pop()),
        actions: [
          if (_isLoading)
            const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
          else
            TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded, color: Colors.white),
              label: Text(isAr ? 'حفظ' : 'Save', style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 16)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSection(isAr ? 'أسماء المنتج' : 'Product Names', isDark, [
              _buildField(_nameEn, isAr ? 'الاسم (إنجليزي)' : 'Name (English)', required: true, isAr: isAr),
              _buildField(_nameAr, isAr ? 'الاسم (عربي)' : 'Name (Arabic)', required: true, isAr: isAr),
              _buildField(_slug, isAr ? 'الرابط الدائم (Slug)' : 'Slug (URL-friendly)', hint: isAr ? 'مثال: wireless-headphones' : 'e.g. wireless-headphones', isAr: isAr),
            ]),
            const SizedBox(height: 16),
            _buildSection(isAr ? 'الوصف' : 'Descriptions', isDark, [
              _buildField(_descEn, isAr ? 'الوصف (إنجليزي)' : 'Description (English)', maxLines: 3, isAr: isAr),
              _buildField(_descAr, isAr ? 'الوصف (عربي)' : 'Description (Arabic)', maxLines: 3, isAr: isAr),
            ]),
            const SizedBox(height: 16),
            _buildSection(isAr ? 'السعر والرمز (SKU)' : 'Pricing & SKU', isDark, [
              _buildField(_price, isAr ? 'السعر الأساسي (ر.س)' : 'Base Price (SAR)', keyboardType: TextInputType.number, required: true, isAr: isAr),
              _buildField(_discount, isAr ? 'نسبة الخصم %' : 'Discount %', keyboardType: TextInputType.number, isAr: isAr),
              _buildField(_stock, isAr ? 'المخزون المتوفر (Stock)' : 'Available Stock', keyboardType: TextInputType.number, required: true, isAr: isAr),
              _buildField(_sku, isAr ? 'رمز SKU' : 'SKU Code', isAr: isAr),
            ]),
            const SizedBox(height: 16),
            _buildSection(isAr ? 'القسم' : 'Category', isDark, [
              categoriesAsync.when(
                data: (cats) => DropdownButtonFormField<String>(
                  value: _categoryId,
                  hint: Text(isAr ? 'اختر القسم' : 'Select Category', style: const TextStyle(fontFamily: 'Outfit')),
                  items: cats.categories.map((c) => DropdownMenuItem<String>(value: c['id'] as String, child: Text(c[isAr ? 'name_ar' : 'name_en'] as String? ?? '', style: const TextStyle(fontFamily: 'Outfit')))).toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                  decoration: _inputDecoration(isAr ? 'القسم' : 'Category', isDark),
                ),
                loading: () => const LinearProgressIndicator(color: AppColors.primary),
                error: (_, __) => Text(isAr ? 'فشل تحميل الأقسام' : 'Failed to load categories'),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection(isAr ? 'إعدادات إضافية' : 'Flags', isDark, [
              _buildSwitch(isAr ? 'نشط' : 'Is Active', _isActive, (v) => setState(() => _isActive = v)),
              _buildSwitch(isAr ? 'منتج مميز' : 'Featured Product', _isFeatured, (v) => setState(() => _isFeatured = v)),
              _buildSwitch(isAr ? 'وصل حديثاً' : 'New Arrival', _isNewArrival, (v) => setState(() => _isNewArrival = v)),
              _buildSwitch(isAr ? 'عليه عرض' : 'On Sale', _isOnSale, (v) => setState(() => _isOnSale = v)),
            ]),
            const SizedBox(height: 16),
            _buildSection(isAr ? 'الأنواع والخيارات (اللون، المقاس)' : 'Product Variants', isDark, [
              if (_variants.isEmpty)
                Text(
                  isAr 
                    ? 'سيتم إنشاء نوع افتراضي تلقائياً بالمخزون والسعر أعلاه.' 
                    : 'A default variant will be created automatically using the stock and price above.',
                  style: TextStyle(color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight, fontSize: 13, fontFamily: 'Outfit'),
                ),
              if (_variants.isNotEmpty)
                ..._variants.map((v) {
                  final attrs = (v['attributes'] as Map<String, String>).entries.map((e) => '${e.key}: ${e.value}').join(', ');
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(attrs, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                              const SizedBox(height: 4),
                              Text('Stock: ${v['stock']} | Price: ${v['price']} | SKU: ${v['sku'] ?? 'N/A'}', style: const TextStyle(fontSize: 12, fontFamily: 'Outfit')),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () => setState(() => _variants.remove(v)),
                        )
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _showAddVariantDialog,
                icon: const Icon(Icons.add),
                label: Text(isAr ? 'إضافة خيار (مثال: أحمر مقاس L)' : 'Add Variant'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              )
            ]),
            const SizedBox(height: 16),
            _buildSection('Product Images', isDark, [
              Wrap(
                spacing: 8, runSpacing: 8,
                children: [
                  ..._newImages.map((f) => Stack(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(f.path), width: 80, height: 80, fit: BoxFit.cover)),
                      Positioned(top: 0, right: 0, child: GestureDetector(
                        onTap: () => setState(() => _newImages.remove(f)),
                        child: Container(width: 22, height: 22, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 14)),
                      )),
                    ],
                  )),
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.primaryLight,
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary),
                        Text(isAr ? 'إضافة صورة' : 'Add Image', style: const TextStyle(color: AppColors.primary, fontSize: 10, fontFamily: 'Outfit')),
                      ]),
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, bool isDark, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.primary)),
          const SizedBox(height: 12),
          ...children.map((w) => Padding(padding: const EdgeInsets.only(bottom: 12), child: w)),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, {TextInputType keyboardType = TextInputType.text, int maxLines = 1, bool required = false, String? hint, bool isAr = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Outfit'),
      validator: required ? (v) => (v == null || v.isEmpty) ? (isAr ? 'مطلوب' : 'Required') : null : null,
      decoration: _inputDecoration(label, Theme.of(context).brightness == Brightness.dark, hintText: hint),
    );
  }

  Widget _buildSwitch(String label, bool value, void Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600)),
        Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, bool isDark, {String? hintText}) => InputDecoration(
    labelText: label, hintText: hintText,
    labelStyle: const TextStyle(fontFamily: 'Outfit'),
    hintStyle: const TextStyle(fontFamily: 'Outfit'),
    filled: true, fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.backgroundLight,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
  );

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) setState(() => _newImages.addAll(picked));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final ds = ref.read(adminDataSourceProvider);
      final defaultSku = _sku.text.trim().isNotEmpty ? _sku.text.trim() : 'SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

      final data = {
        'name_en': _nameEn.text.trim(),
        'name_ar': _nameAr.text.trim(),
        'description_en': _descEn.text.trim(),
        'description_ar': _descAr.text.trim(),
        'slug': _slug.text.trim().isNotEmpty 
            ? _slug.text.trim() 
            : '${_nameEn.text.trim().toLowerCase().replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        'base_price': double.tryParse(_price.text) ?? 0,
        'discount_percent': double.tryParse(_discount.text) ?? 0,
        'sku': defaultSku,
        'category_id': _categoryId,
        'is_active': _isActive,
        'is_featured': _isFeatured,
        'is_new_arrival': _isNewArrival,
        'is_on_sale': _isOnSale,
      };

      String productId;
      
      final List<Map<String, dynamic>> variantsToSave = _variants.isNotEmpty 
          ? _variants 
          : [
              {
                'price': double.tryParse(_price.text) ?? 0,
                'stock': int.tryParse(_stock.text) ?? 0,
                'sku': defaultSku,
                'is_default': true,
                'attributes': <String, String>{},
              }
            ];

      if (_isEditing) {
        await ds.updateProduct(widget.product!['id'] as String, data, variants: variantsToSave);
        productId = widget.product!['id'] as String;
      } else {
        final result = await ds.createProduct(data, variants: variantsToSave);
        productId = result['id'] as String;
      }

      // Upload new images
      for (int i = 0; i < _newImages.length; i++) {
        final file = _newImages[i];
        final bytes = Uint8List.fromList(await file.readAsBytes());
        final path = 'products/$productId/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final url = await ds.uploadImage('product-images', path, bytes);
        await ds.addProductImage({'product_id': productId, 'url': url, 'sort_order': i, 'is_primary': i == 0});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Product updated successfully!' : 'Product created successfully!', style: const TextStyle(fontFamily: 'Outfit')),
          backgroundColor: AppColors.success,
        ));
        GoRouter.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e', style: const TextStyle(fontFamily: 'Outfit')),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddVariantDialog() {
    final priceCtrl = TextEditingController(text: _price.text);
    final stockCtrl = TextEditingController(text: '0');
    final skuCtrl = TextEditingController();
    
    final attrNameCtrl = TextEditingController();
    final attrValCtrl = TextEditingController();
    final Map<String, String> attributes = {};

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isAr = Localizations.localeOf(context).languageCode == 'ar';
          final isDark = Theme.of(context).brightness == Brightness.dark;
          
          return AlertDialog(
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
            title: Text(isAr ? 'إضافة نوع/خيار جديد' : 'Add New Variant', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: isAr ? 'السعر' : 'Price')),
                  const SizedBox(height: 8),
                  TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: isAr ? 'المخزون' : 'Stock')),
                  const SizedBox(height: 8),
                  TextField(controller: skuCtrl, decoration: InputDecoration(labelText: isAr ? 'SKU (اختياري)' : 'SKU (Optional)')),
                  const SizedBox(height: 16),
                  Text(isAr ? 'السمات (مثال: Color, Size)' : 'Attributes (e.g., Color, Size)', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                  const SizedBox(height: 8),
                  ...attributes.entries.map((e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${e.key}: ${e.value}', style: const TextStyle(fontFamily: 'Outfit')),
                    trailing: IconButton(icon: const Icon(Icons.delete, color: AppColors.error), onPressed: () {
                      setDialogState(() => attributes.remove(e.key));
                    }),
                  )),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: attrNameCtrl, decoration: InputDecoration(hintText: isAr ? 'السمة (Color)' : 'Attr (Color)'))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: attrValCtrl, decoration: InputDecoration(hintText: isAr ? 'القيمة (Red)' : 'Value (Red)'))),
                      IconButton(icon: const Icon(Icons.add_circle, color: AppColors.primary), onPressed: () {
                        if (attrNameCtrl.text.isNotEmpty && attrValCtrl.text.isNotEmpty) {
                          setDialogState(() {
                            attributes[attrNameCtrl.text.trim()] = attrValCtrl.text.trim();
                            attrNameCtrl.clear();
                            attrValCtrl.clear();
                          });
                        }
                      })
                    ],
                  ),
                  if (attributes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(isAr ? 'يجب إضافة سمة واحدة على الأقل.' : 'Add at least one attribute.', style: const TextStyle(color: AppColors.error, fontSize: 12, fontFamily: 'Outfit')),
                    )
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'إلغاء' : 'Cancel', style: const TextStyle(fontFamily: 'Outfit'))),
              ElevatedButton(
                onPressed: () {
                  if (attributes.isEmpty) return;
                  setState(() {
                    _variants.add({
                      'price': double.tryParse(priceCtrl.text) ?? 0,
                      'stock': int.tryParse(stockCtrl.text) ?? 0,
                      'sku': skuCtrl.text.trim().isNotEmpty 
                          ? skuCtrl.text.trim() 
                          : 'SKU-V-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                      'is_default': _variants.isEmpty,
                      'attributes': Map<String, String>.from(attributes),
                    });
                  });
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: Text(isAr ? 'إضافة' : 'Add', style: const TextStyle(fontFamily: 'Outfit'))
              )
            ],
          );
        }
      )
    );
  }
}

