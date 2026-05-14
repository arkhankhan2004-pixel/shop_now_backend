import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F2FF),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)],
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0B0C2A)),
          ),
        ),
        title: const Text('My Cart',
            style: TextStyle(color: Color(0xFF0B0C2A), fontWeight: FontWeight.w900, fontSize: 22)),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Clear Cart'),
                    content: const Text('Remove all items from cart?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () { cart.clearCart(); Navigator.pop(context); },
                        child: const Text('Clear', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Clear All', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 20)],
                    ),
                    child: const Text('🛒', style: TextStyle(fontSize: 60)),
                  ),
                  const SizedBox(height: 24),
                  const Text('Your cart is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0B0C2A))),
                  const SizedBox(height: 8),
                  const Text('Add products to see them here', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Browse Products', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, i) {
                      final item = cart.items[i];
                      return Dismissible(
                        key: Key('cart_${item.product.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                        ),
                        onDismissed: (_) => cart.removeFromCart(item.product.id),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 12)],
                          ),
                          child: Row(
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: 75, height: 75,
                                  color: const Color(0xFFF0F2FF),
                                  child: item.product.imageUrl != null
                                      ? Image.network(
                                          item.product.imageUrl!.startsWith('http')
                                              ? item.product.imageUrl!
                                              : '${ApiService.serverUrl}${item.product.imageUrl}',
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => const Icon(Icons.image_outlined, color: Colors.grey),
                                        )
                                      : const Icon(Icons.image_outlined, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.name,
                                        maxLines: 1, overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0B0C2A))),
                                    const SizedBox(height: 4),
                                    Text(item.product.category,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    const SizedBox(height: 8),
                                    Text('Rs. ${item.totalPrice.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w900, fontSize: 16,
                                            color: Color(0xFF6C63FF))),
                                  ],
                                ),
                              ),
                              // Qty Controls
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F2FF),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    _qBtn(Icons.remove_rounded, () => cart.decreaseQuantity(item.product.id)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text('${item.quantity}',
                                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                    ),
                                    _qBtn(Icons.add_rounded, () => cart.addToCart(item.product)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // ===== Bottom checkout panel =====
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, -5))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Amount', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 4),
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                                ).createShader(bounds),
                                child: Text('Rs. ${cart.totalAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 28, fontWeight: FontWeight.w900,
                                        color: Colors.white)),
                              ),
                            ],
                          ),
                          Text('${cart.itemCount} items', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity, height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                            child: const Text('Proceed to Checkout →',
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _qBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: const Color(0xFF6C63FF)),
      ),
    );
  }
}
