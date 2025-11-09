import 'package:flutter/material.dart';
import 'package:floragest/services/firestore_service.dart';
import 'package:floragest/models/product.dart';

// CORRECCIÓN: ShopScreen ya NO es const.
class ShopScreen extends StatelessWidget {
  ShopScreen({super.key});

  // CORRECCIÓN: Inicialización simple sin 'const'
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: firestoreService.getProductsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error al cargar productos: ${snapshot.error}'));
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const Center(
            child: Text(
                'No hay productos disponibles. Agrega algunos en Firestore.',
                style: TextStyle(color: Colors.grey)),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.75,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _ProductCard(
              product: product,
              firestoreService: firestoreService,
              tabController: DefaultTabController.of(context),
            );
          },
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final FirestoreService firestoreService;
  final TabController? tabController;

  const _ProductCard({
    super.key,
    required this.product,
    required this.firestoreService,
    this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: Icon(Icons.photo_size_select_actual_sharp,
                          size: 50, color: Colors.green),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image_not_supported,
                          size: 50, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(product.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(product.category,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart,
                      color: Color(0xFF4CAF50)),
                  onPressed: () async {
                    await firestoreService.addItemToCart(product, 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} añadido al carrito.'),
                        duration: const Duration(seconds: 1),
                        action: SnackBarAction(
                          label: 'Ver Carrito',
                          onPressed: () {
                            tabController?.animateTo(2);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
