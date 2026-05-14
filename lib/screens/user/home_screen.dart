import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'user_orders_screen.dart';
import '../admin/admin_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Product> _allProducts = [];
  List<Product> _filtered = [];
  String _selectedCategory = 'All';
  bool _loading = true;
  final TextEditingController _searchCtrl = TextEditingController();
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final List<Map<String, String>> _categories = [
    {'name': 'All', 'icon': '✨'},
    {'name': 'Electronics', 'icon': '📱'},
    {'name': 'Clothing', 'icon': '👕'},
    {'name': 'Shoes', 'icon': '👟'},
    {'name': 'Watches', 'icon': '⌚'},
    {'name': 'Furniture', 'icon': '🛋️'},
    {'name': 'Accessories', 'icon': '🕶️'},
    {'name': 'Beauty', 'icon': '💄'},
    {'name': 'Sports', 'icon': '⚽'},
    {'name': 'Groceries', 'icon': '🍎'},
    {'name': 'Toys', 'icon': '🧸'},
  ];

  late PageController _pageCtrl;
  int _currentPage = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _pageCtrl = PageController(initialPage: 0);
    _loadProducts();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < 3) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageCtrl.hasClients) {
        _pageCtrl.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pageCtrl.dispose();
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    final products = await ApiService.getProducts();
    setState(() {
      _allProducts = products;
      _filtered = products;
      _loading = false;
    });
    _fadeCtrl.forward(from: 0);
  }

  void _applyFilters() {
    setState(() {
      _filtered = _allProducts.where((p) {
        final matchesCat = _selectedCategory == 'All' || p.category == _selectedCategory;
        final matchesSearch = p.name.toLowerCase().contains(_searchCtrl.text.toLowerCase());
        return matchesCat && matchesSearch;
      }).toList();
    });
    _fadeCtrl.forward(from: 0);
  }

  void _filterCategory(String cat) {
    _selectedCategory = cat;
    _applyFilters();
  }

  void _onSearch(String query) {
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final size = MediaQuery.of(context).size;

    // Filter products for different sale sections
    final sale50 = _allProducts.where((p) => p.discountPercent == 50).toList();
    final sale30 = _allProducts.where((p) => p.discountPercent == 30).toList();
    final sale25 = _allProducts.where((p) => p.discountPercent == 25).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        color: const Color(0xFF6C63FF),
        onRefresh: _loadProducts,
        child: CustomScrollView(
          slivers: [
            // ===== SLIVER APP BAR =====
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Color(0xFF2D2D2D)),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B0C2A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                    ),
                    child: const Icon(Icons.shopping_bag_rounded, color: Color(0xFFFFD700), size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SHOP',
                    style: TextStyle(
                      color: Color(0xFF0B0C2A),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Text(
                    'NOW',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.w300,
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF6C63FF)),
                  onPressed: () => Navigator.pushNamed(context, '/admin'),
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF2D2D2D)),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: 6, top: 6,
                        child: Container(
                          width: 18, height: 18,
                          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]), shape: BoxShape.circle),
                          child: Center(child: Text('${cart.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),

            // ===== SEARCH BAR =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText: 'Search for products...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6C63FF)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
            
            // ===== AUTO-SLIDING BANNER CAROUSEL =====
            if (_selectedCategory == 'All' && _searchCtrl.text.isEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    height: 190,
                    child: PageView(
                      controller: _pageCtrl,
                      onPageChanged: (idx) => setState(() => _currentPage = idx),
                      children: [
                        _buildHeroCard('NEW ARRIVALS', 'Premium Collection\n2026 Edition', [const Color(0xFF6C63FF), const Color(0xFF0B0C2A)], 'Discover Now', Icons.shopping_bag_outlined),
                        _buildHeroCard('MEGA SALE', 'Get Up To 50% OFF\non all Electronics', [const Color(0xFF0B0C2A), const Color(0xFF6C63FF)], 'Shop Mega Sale', Icons.flash_on_rounded),
                        _buildHeroCard('HOT DEALS', 'Trending Styles\n30% OFF Today', [const Color(0xFF6C63FF), const Color(0xFFFF6584)], 'View Deals', Icons.local_fire_department_rounded),
                        _buildHeroCard('BUDGET BUYS', 'Style for Everyone\nFlat 25% OFF', [const Color(0xFF1E1B4B), const Color(0xFF4338CA)], 'Browse All', Icons.stars_rounded),
                      ],
                    ),
                  ),
                ),
              ),
              // Indicators
              SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index ? const Color(0xFF6C63FF) : Colors.grey.shade300,
                    ),
                  )),
                ),
              )],

            SliverToBoxAdapter(
              child: Container(
                height: 100, margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final selected = _selectedCategory == cat['name'];
                    return GestureDetector(
                      onTap: () => _filterCategory(cat['name']!),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 15),
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                              gradient: selected ? const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]) : null,
                              color: selected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [BoxShadow(color: selected ? const Color(0xFF6C63FF).withOpacity(0.3) : Colors.grey.withOpacity(0.05), blurRadius: 10)],
                            ),
                            child: Center(child: Text(cat['icon']!, style: const TextStyle(fontSize: 24))),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Text(cat['name']!, style: TextStyle(fontSize: 10, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: selected ? const Color(0xFF6C63FF) : Colors.grey)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            // ===== FLASH SALE SECTION =====
            if (_allProducts.any((p) => p.discountPercent > 0))
              _buildSaleSection('⚡ Flash Sale', _allProducts.where((p) => p.discountPercent > 0).toList(), const Color(0xFFFF6584)),

            // ===== CATEGORY SPECIFIC SECTIONS =====
            if (_allProducts.any((p) => p.category == 'Electronics'))
              _buildSaleSection('📱 Tech Zone', _allProducts.where((p) => p.category == 'Electronics').toList(), const Color(0xFF6C63FF)),

            if (_allProducts.any((p) => p.category == 'Clothing'))
              _buildSaleSection('👕 Fashion Hub', _allProducts.where((p) => p.category == 'Clothing').toList(), const Color(0xFF0B0C2A)),

            // ===== ALL PRODUCTS GRID HEADER =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_searchCtrl.text.isNotEmpty ? 'Search Results' : 'Explore All',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0B0C2A))),
                    Text('${_filtered.length} Items', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

            _loading
                ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))))
                : _filtered.isEmpty
                    ? SliverToBoxAdapter(
                        child: Container(height: 200, alignment: Alignment.center,
                          child: const Column(mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text('😔', style: TextStyle(fontSize: 50)), Text('No products found', style: TextStyle(color: Colors.grey))],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => FadeTransition(opacity: _fadeAnim, child: _ProductCard(product: _filtered[i])),
                            childCount: _filtered.length,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: size.width > 1200 ? 5 : (size.width > 800 ? 3 : 2),
                            childAspectRatio: 0.70,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                        ),
                      ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(String title, String subtitle, List<Color> colors, String btnText, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Positioned(right: -20, top: -20, child: Icon(icon, size: 160, color: Colors.white.withOpacity(0.1))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ),
                const SizedBox(height: 12),
                Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.2)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Text(btnText, style: TextStyle(color: colors[0], fontSize: 12, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleSection(String title, List<Product> products, Color color) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0B0C2A))),
                const Spacer(),
                const Text('View All', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              itemBuilder: (context, i) {
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 16),
                  child: _ProductCard(product: products[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0B0C2A)),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Color(0xFFFFD700),
              child: Icon(Icons.person_rounded, size: 40, color: Color(0xFF0B0C2A)),
            ),
            accountName: Text(AuthService.isLoggedIn ? (AuthService.currentUser!.email?.split('@')[0] ?? 'User') : 'Guest', style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(AuthService.isLoggedIn ? AuthService.currentUser!.email! : 'Please login to continue'),
          ),
          ListTile(leading: const Icon(Icons.home_outlined), title: const Text('Home'), onTap: () => Navigator.pop(context)),
          if (AuthService.isLoggedIn)
            ListTile(leading: const Icon(Icons.receipt_long_outlined), title: const Text('My Orders'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const UserOrdersScreen())); }),
          ListTile(leading: const Icon(Icons.admin_panel_settings_outlined), title: const Text('Admin Panel'), onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/admin'); }),
          const Spacer(),
          if (AuthService.isLoggedIn)
            ListTile(leading: const Icon(Icons.logout_rounded, color: Colors.redAccent), title: const Text('Logout', style: TextStyle(color: Colors.redAccent)), onTap: () { AuthService.logout(); Navigator.pop(context); setState(() {}); }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final hasDiscount = product.discountPercent > 0;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 12)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(width: double.infinity, decoration: const BoxDecoration(color: Color(0xFFF0F2FF), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                    child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: product.imageUrl != null
                          ? Image.network(
                              product.imageUrl!.startsWith('http') ? product.imageUrl! : '${ApiService.serverUrl}${product.imageUrl}',
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(Icons.image_outlined, color: Colors.grey),
                            )
                          : const Icon(Icons.image_outlined, color: Colors.grey),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(top: 8, right: 8,
                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFF6584), borderRadius: BorderRadius.circular(10)),
                        child: Text('${product.discountPercent}% OFF', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0B0C2A))),
                  const SizedBox(height: 4),
                  // Price Logic
                  if (hasDiscount) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('Rs. ${product.discountedPrice.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF6C63FF))),
                        const SizedBox(width: 4),
                        const Text('Sale', style: TextStyle(color: Color(0xFFFF6584), fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text('Rs. ${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 11, decoration: TextDecoration.lineThrough, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 6),
                        Text('${product.discountPercent}% OFF',
                            style: const TextStyle(color: Color(0xFFFF6584), fontSize: 10, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ] else ...[
                    Text('Rs. ${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0B0C2A))),
                    const SizedBox(height: 18), // Spacer to keep height consistent
                  ],
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity, height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B0C2A), elevation: 0, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: () { cart.addToCart(product); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} added! 🛒'), backgroundColor: const Color(0xFF6C63FF), duration: const Duration(seconds: 1), behavior: SnackBarBehavior.floating)); },
                      child: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
