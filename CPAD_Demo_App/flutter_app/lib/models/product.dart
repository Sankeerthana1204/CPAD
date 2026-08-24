class Product {
  final int productId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stockQty;

  Product({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stockQty,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json["product_id"] as int,
      name: (json["name"] ?? "") as String,
      description: (json["description"] ?? "") as String,
      price: (json["price"] as num).toDouble(),
      imageUrl: (json["image_url"] ?? "") as String,
      stockQty: (json["stock_qty"] ?? 0) as int,
    );
  }
}
