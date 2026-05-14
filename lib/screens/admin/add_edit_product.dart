import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl, _priceCtrl, _descCtrl;
  late String _selectedCategory;
  XFile? _pickedFile;
  Uint8List? _webImage;
  bool _loading = false;
  int _discountPercent = 0;

  final List<int> _discountOptions = [0, 25, 30, 50];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Electronics', 'icon': '📱'},
    {'name': 'Clothing', 'icon': '👕'},
    {'name': 'Shoes', 'icon': '👟'},
    {'name': 'Accessories', 'icon': '👜'},
    {'name': 'Watches', 'icon': '⌚'},
    {'name': 'Furniture', 'icon': '🛋️'},
    {'name': 'Beauty', 'icon': '💄'},
    {'name': 'Sports', 'icon': '⚽'},
    {'name': 'Groceries', 'icon': '🍎'},
    {'name': 'Toys', 'icon': '🧸'},
  ];

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _priceCtrl = TextEditingController(text: widget.product?.price.toString() ?? '');
    _descCtrl = TextEditingController(text: widget.product?.description ?? '');
    _selectedCategory = widget.product?.category ?? 'Electronics';
    _discountPercent = widget.product?.discountPercent ?? 0;
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() { _webImage = bytes; _pickedFile = picked; });
    } else {
      setState(() => _pickedFile = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    bool success = _isEdit
        ? await ApiService.editProduct(
            id: widget.product!.id,
            name: _nameCtrl.text, description: _descCtrl.text,
            price: _priceCtrl.text, category: _selectedCategory,
            discountPercent: _discountPercent,
            imagePath: kIsWeb ? null : _pickedFile?.path,
            imageBytes: kIsWeb ? _webImage : null, imageName: _pickedFile?.name)
        : await ApiService.addProduct(
            name: _nameCtrl.text, description: _descCtrl.text,
            price: _priceCtrl.text, category: _selectedCategory,
            discountPercent: _discountPercent,
            imagePath: kIsWeb ? null : _pickedFile?.path,
            imageBytes: kIsWeb ? _webImage : null, imageName: _pickedFile?.name);

    setState(() => _loading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? '✅ Product updated!' : '✅ Product added!'),
        backgroundColor: Colors.green, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('❌ Operation failed. Try again.'),
        backgroundColor: Colors.red, behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F2FF),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)]),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0B0C2A)),
          ),
        ),
        title: Text(_isEdit ? 'Edit Product' : 'Add New Product',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0B0C2A))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Image Picker ──
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 12)],
                    border: Border.all(
                      color: _pickedFile != null || widget.product?.imageUrl != null
                          ? Colors.transparent
                          : const Color(0xFF6C63FF).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: _buildImagePreview(),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text('Tap image to change',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              const SizedBox(height: 20),

              // ── Product Name ──
              _field(_nameCtrl, 'Product Name', Icons.inventory_2_outlined,
                  validator: (v) => v!.isEmpty ? 'Enter product name' : null),
              const SizedBox(height: 14),

              // ── Price ──
              _field(_priceCtrl, 'Price (RS)', Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Enter price' : null),
              const SizedBox(height: 14),

              // ── Discount Selection ──
              const Text('Select Discount',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0B0C2A))),
              const SizedBox(height: 10),
              Row(
                children: _discountOptions.map((d) {
                  final selected = _discountPercent == d;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _discountPercent = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF6C63FF) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selected ? Colors.transparent : Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Text(
                            d == 0 ? 'None' : '$d%',
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // ── Category ──
              const Text('Select Category',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0B0C2A))),
              const SizedBox(height: 10),
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final selected = cat['name'] == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat['name']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: selected
                              ? const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)])
                              : null,
                          color: selected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(
                            color: selected ? const Color(0xFF6C63FF).withOpacity(0.3) : Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                          )],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cat['icon']!, style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 2),
                            Text(cat['name']!,
                                style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w700,
                                  color: selected ? Colors.white : const Color(0xFF0B0C2A),
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // ── Description ──
              _field(_descCtrl, 'Description', Icons.description_outlined,
                  maxLines: 4,
                  validator: (v) => v!.isEmpty ? 'Enter description' : null),
              const SizedBox(height: 30),

              // ── Submit Button ──
              SizedBox(
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(width: 24, height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text(_isEdit ? 'Save Changes ✓' : 'Add Product +',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_pickedFile != null) {
      return kIsWeb
          ? Image.memory(_webImage!, fit: BoxFit.cover)
          : Image.file(File(_pickedFile!.path), fit: BoxFit.cover);
    }
    if (widget.product?.imageUrl != null) {
      return Image.network(
        '${ApiService.serverUrl}${widget.product!.imageUrl}', fit: BoxFit.cover,
        errorBuilder: (c, e, s) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF0F2FF),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_photo_alternate_outlined, size: 40, color: Color(0xFF6C63FF)),
          ),
          const SizedBox(height: 10),
          const Text('Tap to upload image',
              style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl, maxLines: maxLines, keyboardType: keyboardType, validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF6584))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
