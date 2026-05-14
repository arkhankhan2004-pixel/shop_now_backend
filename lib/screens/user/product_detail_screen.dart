import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final p = widget.product;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF),
      body: Stack(
        children: [
          // ===== Background Image Half =====
          Positioned(
            top: 0, left: 0, right: 0,
            height: 380,
            child: Container(
              color: const Color(0xFFE8EAFF),
              child: p.imageUrl != null
                  ? Image.network(
                      p.imageUrl!.startsWith('http') ? p.imageUrl! : '${ApiService.serverUrl}${p.imageUrl}',
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Center(
                          child: Icon(Icons.image_outlined, size: 80, color: Colors.grey)))
                  : const Center(child: Icon(Icons.image_outlined, size: 80, color: Colors.grey)),
            ),
          ),
          // Gradient overlay on image
          Positioned(
            top: 200, left: 0, right: 0, height: 180,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xFFF0F2FF)],
                ),
              ),
            ),
          ),

          // ===== Back Button =====
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                ),
                child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0B0C2A)),
              ),
            ),
          ),

          // ===== Cart Button =====
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CartScreen())),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                ),
                child: const Icon(Icons.shopping_cart_outlined, size: 20, color: Color(0xFF6C63FF)),
              ),
            ),
          ),

          // ===== Bottom Sheet Details =====
          Positioned(
            top: 340, left: 0, right: 0, bottom: 0,
            child: SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F2FF),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category & Sale Badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(p.category, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                            if (p.discountPercent > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6584).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFFF6584), width: 1),
                                ),
                                child: Text('${p.discountPercent}% OFF FLASH SALE', style: const TextStyle(color: Color(0xFFFF6584), fontSize: 11, fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Name & Price Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(p.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0B0C2A), height: 1.2)),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]).createShader(bounds),
                                  child: Text('Rs. ${p.discountedPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                                ),
                                if (p.discountPercent > 0)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Rs. ${p.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, fontSize: 14, decoration: TextDecoration.lineThrough, fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 6),
                                      Text('(${p.discountPercent}% OFF)', style: const TextStyle(color: Color(0xFFFF6584), fontSize: 12, fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Description
                        const Text('Product Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0B0C2A))),
                        const SizedBox(height: 8),
                        Text(p.description, style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.7)),
                        const SizedBox(height: 24),

                        // Quantity Selector
                        Row(
                          children: [
                            const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)]),
                              child: Row(
                                children: [
                                  _qBtn(Icons.remove, () { if (_qty > 1) setState(() => _qty--); }),
                                  Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('$_qty', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))),
                                  _qBtn(Icons.add, () => setState(() => _qty++)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Add to Cart Button
                        SizedBox(
                          width: double.infinity, height: 56,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                              label: Text('Add $_qty to Cart · Rs. ${(p.discountedPrice * _qty).toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                              onPressed: () {
                                for (int i = 0; i < _qty; i++) cart.addToCart(p);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Added to cart! 🛒'), backgroundColor: const Color(0xFF6C63FF), duration: const Duration(seconds: 1), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 20, color: const Color(0xFF6C63FF)),
      ),
    );
  }
}
