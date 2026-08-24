import "../models/product.dart";
import "api_client.dart";

class ProductService {
  final String token;

  ProductService(this.token);

  Future<List<Product>> fetchProducts({String search = ""}) async {
    final client = ApiClient(authToken: token);
    final response = await client.get("/products?search=${Uri.encodeQueryComponent(search)}");
    final list = (response["items"] as List<dynamic>? ?? <dynamic>[]);
    return list
        .whereType<Map<String, dynamic>>()
        .map((item) => Product.fromJson(item))
        .toList();
  }

  Future<Product> fetchProductById(int productId) async {
    final client = ApiClient(authToken: token);
    final response = await client.get("/products/$productId");
    return Product.fromJson(response);
  }
}
