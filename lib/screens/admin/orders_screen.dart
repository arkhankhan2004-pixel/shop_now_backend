import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderModel> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _loading = true);
    final orders = await ApiService.getOrders();
    setState(() { _orders = orders; _loading = false; });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending': return const Color(0xFFFF9800);
      case 'Shipped': return const Color(0xFF6C63FF);
      case 'Delivered': return const Color(0xFF4CAF50);
      default: return Colors.grey;
    }
  }

  String _statusIcon(String status) {
    switch (status) {
      case 'Pending': return '⏳';
      case 'Shipped': return '🚚';
      case 'Delivered': return '✅';
      default: return '📦';
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _orders.fold(0.0, (sum, o) => sum + o.totalAmount);

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
        title: const Text('Customer Orders',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0B0C2A))),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6C63FF)),
            onPressed: _loadOrders,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : Column(
              children: [
                // ── Stats Header ──
                if (_orders.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0B0C2A), Color(0xFF1E1B4B)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Row(
                      children: [
                        _statItem('Total Orders', '${_orders.length}', '📦'),
                        Container(width: 1, height: 50, color: Colors.white12),
                        _statItem('Total Revenue', '\$${total.toStringAsFixed(0)}', '💰'),
                        Container(width: 1, height: 50, color: Colors.white12),
                        _statItem('Pending', '${_orders.where((o) => o.status == 'Pending').length}', '⏳'),
                      ],
                    ),
                  ),

                Expanded(
                  child: _orders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('📋', style: TextStyle(fontSize: 60)),
                              const SizedBox(height: 16),
                              const Text('No orders yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0B0C2A))),
                              const SizedBox(height: 8),
                              const Text('Orders will appear here when customers place them', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                            ],
                          ))
                      : RefreshIndicator(
                          onRefresh: _loadOrders,
                          color: const Color(0xFF6C63FF),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                            itemCount: _orders.length,
                            itemBuilder: (context, i) {
                              final order = _orders[i];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 12)],
                                ),
                                child: Column(
                                  children: [
                                    // Order Header
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _statusColor(order.status).withOpacity(0.07),
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      ),
                                      child: Row(
                                        children: [
                                          Text('${_statusIcon(order.status)} Order #${order.id}',
                                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0B0C2A))),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _statusColor(order.status).withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(order.status,
                                                style: TextStyle(
                                                  color: _statusColor(order.status),
                                                  fontWeight: FontWeight.w800, fontSize: 12,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Order Details
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          _row(Icons.person_rounded, order.customerName, const Color(0xFF6C63FF)),
                                          const SizedBox(height: 8),
                                          _row(Icons.phone_rounded, order.phone, Colors.green),
                                          const SizedBox(height: 8),
                                          _row(Icons.payment_rounded, order.paymentMethod, Colors.orange),
                                          const SizedBox(height: 8),
                                          _row(Icons.access_time_rounded,
                                              order.createdAt.split('T').first, Colors.grey),
                                          const Divider(height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                              ShaderMask(
                                                shaderCallback: (bounds) => const LinearGradient(
                                                  colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                                                ).createShader(bounds),
                                                child: Text('\$${order.totalAmount.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontSize: 20, fontWeight: FontWeight.w900,
                                                      color: Colors.white,
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _statItem(String label, String value, String emoji) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0B0C2A)),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
