import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _paymentMethod = 'Cash on Delivery';
  bool _loading = false;

  final List<Map<String, dynamic>> _paymentOptions = [
    {'name': 'Cash on Delivery', 'icon': '💵'},
    {'name': 'Bank Transfer', 'icon': '🏦'},
    {'name': 'EasyPaisa', 'icon': '📲'},
    {'name': 'JazzCash', 'icon': '💳'},
  ];

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    // Gate: must be logged in
    if (!AuthService.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(onSuccess: () {
            Navigator.pop(context);
            _placeOrder();
          }),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    final cart = context.read<CartProvider>();

    final items = cart.items.map((i) => {
          'product_id': i.product.id,
          'quantity': i.quantity,
          'price': i.discountedPrice,
        }).toList();

    final success = await ApiService.placeOrder(
      firebaseUid: AuthService.currentUser!.uid,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      paymentMethod: _paymentMethod,
      totalAmount: cart.totalAmount,
      items: items,
    );

    setState(() => _loading = false);

    if (success && mounted) {
      cart.clearCart();
      _showSuccessDialog();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to place order. Please try again.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success animation
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.4),
                      blurRadius: 20, offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              const Text('Order Placed! 🎉',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0B0C2A))),
              const SizedBox(height: 10),
              const Text('Your order has been successfully\nplaced. We will contact you soon!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, height: 1.5)),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity, height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Back to Shopping',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    if (!AuthService.isLoggedIn) {
      return LoginScreen(onSuccess: () => setState(() {}));
    }

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
        title: const Text('Checkout',
            style: TextStyle(color: Color(0xFF0B0C2A), fontWeight: FontWeight.w900, fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Order Summary Card ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B0C2A), Color(0xFF1E1B4B)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.receipt_rounded, color: Colors.white70, size: 18),
                        SizedBox(width: 8),
                        Text('Order Summary', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...cart.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('${item.product.name} ×${item.quantity}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                    overflow: TextOverflow.ellipsis),
                              ),
                               Text('Rs. ${item.totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        )),
                    const Divider(color: Colors.white12, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                          ).createShader(bounds),
                          child: Text('Rs. ${cart.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w900,
                                color: Colors.white,
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _sectionTitle('📦 Delivery Details'),
              const SizedBox(height: 12),

              _field(_nameCtrl, 'Full Name', Icons.person_outline_rounded,
                  validator: (v) => v!.isEmpty ? 'Enter your name' : null),
              const SizedBox(height: 12),
              _field(_emailCtrl, 'Email Address', Icons.email_outlined,
                  validator: (v) => v!.isEmpty ? 'Enter your email' : null),
              const SizedBox(height: 12),
              _field(_phoneCtrl, 'Phone Number', Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Enter phone number' : null),
              const SizedBox(height: 12),
              _field(_addressCtrl, 'Delivery Address', Icons.location_on_outlined,
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Enter delivery address' : null),

              const SizedBox(height: 24),
              _sectionTitle('💳 Payment Method'),
              const SizedBox(height: 12),

              ..._paymentOptions.map((opt) => GestureDetector(
                    onTap: () => setState(() => _paymentMethod = opt['name']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _paymentMethod == opt['name']
                              ? const Color(0xFF6C63FF)
                              : Colors.grey.shade200,
                          width: _paymentMethod == opt['name'] ? 2 : 1,
                        ),
                        boxShadow: _paymentMethod == opt['name']
                            ? [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.15), blurRadius: 10)]
                            : [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          Text(opt['icon']!, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(opt['name']!,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: _paymentMethod == opt['name'] ? const Color(0xFF6C63FF) : const Color(0xFF0B0C2A))),
                          ),
                          if (_paymentMethod == opt['name'])
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 14),
                            ),
                        ],
                      ),
                    ),
                  )),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity, height: 58,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 18, offset: const Offset(0, 8))],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: _loading ? null : _placeOrder,
                    child: _loading
                        ? const SizedBox(width: 26, height: 26,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Place Order Now 🛍️',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0B0C2A)));
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
