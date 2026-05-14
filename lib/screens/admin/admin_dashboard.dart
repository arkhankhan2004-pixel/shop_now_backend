import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/api_service.dart';
import 'add_edit_product.dart';
import 'add_product.dart';
import 'orders_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Product> _products = [];
  bool _loading = true;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    final products = await ApiService.getProducts();
    setState(() { _products = products; _loading = false; _selectedIds.clear(); });
  }

  Map<String, int> _getCategoryCounts() {
    Map<String, int> counts = {};
    for (var p in _products) {
      counts[p.category] = (counts[p.category] ?? 0) + 1;
    }
    return counts;
  }

  void _selectAll() {
    setState(() {
      if (_selectedIds.length == _products.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(_products.map((p) => p.id));
      }
    });
  }

  Future<void> _bulkDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Bulk Delete', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to delete ${_selectedIds.length} items? This cannot be undone.', style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() => _loading = true);
      final success = await ApiService.bulkDeleteProducts(_selectedIds.toList());
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_selectedIds.length} products deleted'), backgroundColor: Colors.green));
      }
      await _loadProducts();
    }
  }

  Future<void> _delete(Product p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Product', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Delete "${p.name}"? This cannot be undone.', style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ApiService.deleteProduct(p.id);
      _loadProducts();
    }
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSelectionMode = _selectedIds.isNotEmpty;
    final catCounts = _getCategoryCounts();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: isSelectionMode 
          ? IconButton(onPressed: () => setState(() => _selectedIds.clear()), icon: const Icon(Icons.close_rounded, color: Color(0xFF0B0C2A)))
          : IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0B0C2A))),
        title: isSelectionMode 
          ? Text('${_selectedIds.length} Selected', style: const TextStyle(color: Color(0xFF0B0C2A), fontWeight: FontWeight.w900))
          : const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0B0C2A))),
        actions: [
          if (isSelectionMode) ...[
            IconButton(
              onPressed: _selectAll,
              icon: Icon(_selectedIds.length == _products.length ? Icons.deselect_rounded : Icons.select_all_rounded, color: const Color(0xFF6C63FF)),
              tooltip: 'Select All',
            ),
            IconButton(onPressed: _bulkDelete, icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 28))
          ] else
            IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen())), icon: const Icon(Icons.receipt_long_rounded, color: Color(0xFF6C63FF))),
        ],
      ),
      body: Column(
        children: [
          if (!isSelectionMode && _products.isNotEmpty)
            Container(
              height: 60,
              color: Colors.white,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                children: [
                  _summaryChip('Total: ${_products.length}', const Color(0xFF0B0C2A)),
                  ...catCounts.entries.map((e) => _summaryChip('${e.key}: ${e.value}', const Color(0xFF6C63FF))),
                ],
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _products.length,
                    itemBuilder: (context, i) {
                      final p = _products[i];
                      final isSelected = _selectedIds.contains(p.id);
                      return GestureDetector(
                        onLongPress: () => _toggleSelection(p.id),
                        onTap: () {
                          if (isSelectionMode) {
                            _toggleSelection(p.id);
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditProductScreen(product: p))).then((v) {
                              if(v == true) _loadProducts();
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.05) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent, width: 2),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                                child: Container(
                                  width: 90, height: 90,
                                  color: const Color(0xFFF0F2FF),
                                  child: Stack(
                                    children: [
                                      p.imageUrl != null
                                          ? Image.network(
                                              p.imageUrl!.startsWith('http') ? p.imageUrl! : '${ApiService.serverUrl}${p.imageUrl}',
                                              fit: BoxFit.cover, width: 90, height: 90,
                                              errorBuilder: (c, e, s) => const Icon(Icons.image_outlined, color: Colors.grey))
                                          : const Center(child: Icon(Icons.image_outlined, color: Colors.grey)),
                                      if (isSelected)
                                        Container(color: const Color(0xFF6C63FF).withOpacity(0.4), child: const Center(child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 30))),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0B0C2A))),
                                      const SizedBox(height: 4),
                                      Text(p.category, style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 11, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 6),
                                      Text('Rs. ${p.discountedPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF6C63FF))),
                                    ],
                                  ),
                                ),
                              ),
                              if (!isSelectionMode)
                                IconButton(icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 22), onPressed: () => _delete(p)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: isSelectionMode 
          ? null 
          : FloatingActionButton(
              backgroundColor: const Color(0xFF0B0C2A),
              onPressed: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
                if (result == true) _loadProducts();
              },
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
            ),
    );
  }

  Widget _summaryChip(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.2))),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
