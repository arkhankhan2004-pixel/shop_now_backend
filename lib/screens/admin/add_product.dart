import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedCategory = 'Electronics';
  int _discountPercent = 0;
  
  XFile? _pickedFile;
  Uint8List? _webImage;
  bool _isLoading = false;

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

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
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
    setState(() => _isLoading = true);

    bool success = await ApiService.addProduct(
      name: _nameCtrl.text,
      description: _descCtrl.text,
      price: _priceCtrl.text,
      category: _selectedCategory,
      discountPercent: _discountPercent,
      imagePath: kIsWeb ? null : _pickedFile?.path,
      imageBytes: kIsWeb ? _webImage : null,
      imageName: _pickedFile?.name,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('✅ Product Added Successfully!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
      );
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to add product'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {TextInputType type = TextInputType.text, int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2)),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add New Product', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B0C2A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2), width: 2, style: BorderStyle.solid),
                    ),
                    child: _pickedFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: kIsWeb ? Image.memory(_webImage!, fit: BoxFit.cover) : Image.file(File(_pickedFile!.path), fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_rounded, size: 50, color: Color(0xFF6C63FF)),
                              SizedBox(height: 10),
                              Text('Tap to select product image', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.w700)),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              _field(_nameCtrl, 'Product Name', Icons.shopping_bag_outlined, validator: (v) => v!.isEmpty ? 'Enter name' : null),
              const SizedBox(height: 16),
              
              _field(_priceCtrl, 'Price (RS)', Icons.payments_outlined, type: TextInputType.number, validator: (v) => v!.isEmpty ? 'Enter price' : null),
              const SizedBox(height: 20),

              const Text('Select Discount', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0B0C2A))),
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
                          child: Text(d == 0 ? 'None' : '$d%', style: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              const Text('Select Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0B0C2A))),
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
                          gradient: selected ? const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]) : null,
                          color: selected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: selected ? const Color(0xFF6C63FF).withOpacity(0.3) : Colors.grey.withOpacity(0.1), blurRadius: 8)],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cat['icon']!, style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 2),
                            Text(cat['name']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF0B0C2A))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              _field(_descCtrl, 'Description', Icons.description_outlined, maxLines: 3, validator: (v) => v!.isEmpty ? 'Enter description' : null),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B0C2A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: const Color(0xFF0B0C2A).withOpacity(0.4),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('SAVE PRODUCT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
