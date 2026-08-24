import "package:flutter/material.dart";

import "../models/product.dart";
import "../services/auth_service.dart";
import "../services/product_service.dart";
import "product_detail_screen.dart";

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _searchController = TextEditingController();

  bool _isLoading = true;
  String _customerName = "Customer";
  String? _error;
  String _token = "";
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        _goToLogin();
        return;
      }

      final customerName = await _authService.getCustomerName();
      final service = ProductService(token);
      final products = await service.fetchProducts();

      if (!mounted) {
        return;
      }

      setState(() {
        _token = token;
        _customerName = customerName;
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  Future<void> _search() async {
    if (_token.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ProductService(_token);
      final products = await service.fetchProducts(search: _searchController.text);

      if (!mounted) {
        return;
      }

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) {
      return;
    }
    _goToLogin();
  }

  void _goToLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard - $_customerName"),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: "Search products",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _search,
                  child: const Text("Search"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                      ? const Center(child: Text("No products found"))
                      : ListView.separated(
                          itemBuilder: (context, index) {
                            final item = _products[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              leading: CircleAvatar(child: Text(item.name.isNotEmpty ? item.name[0].toUpperCase() : "P")),
                              title: Text(item.name),
                              subtitle: Text("Rs ${item.price.toStringAsFixed(2)} | Stock: ${item.stockQty}"),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(token: _token, productId: item.productId),
                                  ),
                                );
                              },
                            );
                          },
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemCount: _products.length,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
