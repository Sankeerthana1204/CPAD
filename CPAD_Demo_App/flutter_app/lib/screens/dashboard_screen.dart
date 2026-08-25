import "package:flutter/material.dart";

import "../models/product.dart";
import "../services/auth_service.dart";
import "../services/product_service.dart";
import "../utils/product_images.dart";
import "product_detail_screen.dart";

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

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
      final products = await service.fetchProducts(search: _searchController.text.trim());

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

  Future<void> _clearSearch() async {
    _searchController.clear();
    await _search();
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
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pick your products"),
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
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      labelText: "Search products",
                      border: const OutlineInputBorder(),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: _isLoading ? null : _clearSearch,
                              icon: const Icon(Icons.clear),
                              tooltip: "Clear search",
                            )
                          : null,
                    ),
                    onSubmitted: (_) => _search(),
                    onChanged: (_) {
                      setState(() {});
                    },
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
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final crossAxisCount = width >= 1100 ? 3 : width >= 700 ? 2 : 1;

                            Widget buildProductCard(Product item) {
                              final assetPath = ProductImages.forProduct(item);
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                elevation: 2,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailScreen(token: _token, productId: item.productId),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: Image.asset(
                                          assetPath,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  item.description.isEmpty ? "No description available" : item.description,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(color: Colors.grey.shade700),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Rs ${item.price.toStringAsFixed(2)}",
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.indigo,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Stock: ${item.stockQty}",
                                                      style: TextStyle(color: Colors.grey.shade700),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (crossAxisCount == 1) {
                              return ListView.separated(
                                itemCount: _products.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = _products[index];
                                  return SizedBox(
                                    height: 280,
                                    child: buildProductCard(item),
                                  );
                                },
                              );
                            }

                            final childAspectRatio = crossAxisCount == 2 ? 0.9 : 1.05;
                            return GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: childAspectRatio,
                              ),
                              itemCount: _products.length,
                              itemBuilder: (context, index) {
                                final item = _products[index];
                                return buildProductCard(item);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
