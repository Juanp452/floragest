import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floragest/models/user_profile.dart';
import 'package:floragest/models/product.dart';
import 'package:floragest/models/cart_item.dart';

class FirestoreService {
  FirestoreService();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- MÉTODOS DE PERFIL DE USUARIO (ROL) ---

  Future<void> saveUserProfile(
      String uid, String email, String name, String role) async {
    final userProfile = UserProfile(
      uid: uid,
      email: email,
      name: name,
      role: role,
    );
    // Nota: Aquí se usa el set, y toMap() no tiene 'uid' si vienes del constructor
    await _db.collection('users').doc(uid).set(userProfile.toMap());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        // Se añade el 'uid' al map para cumplir con el constructor del modelo
        final data = doc.data()!;
        data['uid'] = doc.id;
        return UserProfile.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error al obtener perfil de usuario: $e');
      return null;
    }
  }

  // --- MÉTODOS DE PRODUCTOS ---

  Stream<List<Product>> getProductsStream() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data()!, doc.id))
          .toList();
    });
  }

  // --- MÉTODOS DE CARRITO ---

  String get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid ?? 'guest_user_id';
  }

  Stream<List<CartItem>> getCartStream() {
    return _db
        .collection('users')
        .doc(currentUserId)
        .collection('cart')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CartItem.fromMap(doc.data()!, doc.id))
          .toList();
    });
  }

  Future<void> addItemToCart(Product product, int quantity) async {
    final cartRef =
        _db.collection('users').doc(currentUserId).collection('cart');
    final productDoc = await cartRef.doc(product.id).get();

    if (productDoc.exists) {
      final currentItem = CartItem.fromMap(productDoc.data()!, product.id);
      await cartRef.doc(product.id).update({
        'quantity': currentItem.quantity + quantity,
      });
    } else {
      final newCartItem = CartItem(
        id: product.id,
        productId: product.id,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        quantity: quantity,
      );
      await cartRef.doc(product.id).set(newCartItem.toMap());
    }
  }

  Future<void> removeItemFromCart(String productId) async {
    final cartRef =
        _db.collection('users').doc(currentUserId).collection('cart');
    await cartRef.doc(productId).delete();
  }

  Future<void> clearCart() async {
    final cartRef =
        _db.collection('users').doc(currentUserId).collection('cart');
    final snapshot = await cartRef.get();

    final batch = _db.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
