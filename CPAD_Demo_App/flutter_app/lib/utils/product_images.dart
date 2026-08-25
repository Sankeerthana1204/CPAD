import "../models/product.dart";

class ProductImages {
  static const String _defaultAsset = "assets/notebook.jpg";

  static const Map<String, String> _assetByProductName = {
    "Cotton T-Shirt": "assets/tshirt.jpg",
    "Sports Shoes": "assets/shoes.jpg",
    "Leather Wallet": "assets/wallet.jpg",
    "Analog Watch": "assets/watch.jpg",
    "Backpack": "assets/backbag.jpg",
    "Sunglasses": "assets/sunglases.png",
    "Wireless Earbuds": "assets/earbuds.png",
    "Ceramic Mug": "assets/mug.png",
    "Notebook": "assets/notebook.jpg",
  };

  static String forProduct(Product product) {
    return _assetByProductName[product.name] ?? _defaultAsset;
  }
}
