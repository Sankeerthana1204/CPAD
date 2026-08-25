import "package:flutter/material.dart";

import "../models/product.dart";
import "../services/product_service.dart";
import "../utils/product_images.dart";

class ProductDetailScreen extends StatefulWidget {
  final String token;
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.token,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoading = true;
  String? _error;
  Product? _product;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ProductService(widget.token);
      final product = await service.fetchProductById(widget.productId);
      if (!mounted) {
        return;
      }
      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAssetPath = _product == null ? "assets/notebook.jpg" : ProductImages.forProduct(_product!);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1000;
    final contentMaxWidth = isLargeScreen ? 920.0 : 720.0;
    final imageHeight = isLargeScreen ? 380.0 : 220.0;

    return Scaffold(
      appBar: AppBar(title: const Text("Product Details")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _product == null
                  ? const Center(child: Text("Product not found"))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: contentMaxWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  height: imageHeight,
                                  child: Image.asset(
                                    detailAssetPath,
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.low,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _product!.name,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Rs ${_product!.price.toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 20, color: Colors.indigo, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 10),
                              Text("Stock available: ${_product!.stockQty}"),
                              const SizedBox(height: 16),
                              Text(
                                _product!.description.isEmpty ? "No description available" : _product!.description,
                                style: const TextStyle(fontSize: 16, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }
}
