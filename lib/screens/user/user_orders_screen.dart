import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class UserOrdersScreen extends StatefulWidget {
  const UserOrdersScreen({super.key});

  @override
  State<UserOrdersScreen> createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  List<OrderModel> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (!AuthService.isLoggedIn) return;
    setState(() => _loading = true);
    final orders = await ApiService.getUserOrders(AuthService.currentUser!.uid);
    setState(() {
      _orders = orders;
      _loading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'Shipped': return Colors.blue;
      case 'Delivered': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF),
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0B0C2A),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No orders yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Go Shopping')),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, i) {
                    final order = _orders[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(order.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(order.status, style: TextStyle(color: _statusColor(order.status), fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _detailRow(Icons.calendar_today_outlined, 'Placed on: ${order.createdAt.split('T')[0]}'),
                            const SizedBox(height: 8),
                            _detailRow(Icons.payment_outlined, 'Payment: ${order.paymentMethod}'),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Amount:', style: TextStyle(color: Colors.grey)),
                                Text('Rs. ${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF6C63FF))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }
}
