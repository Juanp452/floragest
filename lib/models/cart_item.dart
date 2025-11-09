class CartItem {
  final String id;
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  factory CartItem.fromMap(Map<String, dynamic> map, String documentId) {
    return CartItem(
      id: documentId,
      productId: map['productId'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['imageUrl'] as String,
      quantity: map['quantity'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }
}
