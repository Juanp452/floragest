import 'package:flutter/material.dart';
import 'package:floragest/services/firestore_service.dart';
import 'package:floragest/models/cart_item.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final FirestoreService firestoreService = FirestoreService();

  Future<void> _processOrder(BuildContext context) async {
    // Si la función es asíncrona, siempre comprueba 'mounted' si vas a usar 'context'
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Procesando orden...')),
    );

    await firestoreService.clearCart();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('¡Compra realizada con éxito y carrito vaciado!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CartItem>>(
      stream: firestoreService.getCartStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error al cargar carrito: ${snapshot.error}'));
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return const Center(
            child: Text('Tu carrito está vacío. ¡Añade algunas plantas!',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          );
        }

        double total =
            items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 2,
                    child: ListTile(
                      leading: Image.network(item.imageUrl,
                          width: 50, height: 50, fit: BoxFit.cover),
                      title: Text(item.name),
                      subtitle: Text(
                          'Precio: \$${item.price.toStringAsFixed(2)} x ${item.quantity}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          firestoreService.removeItemFromCart(item.productId);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Sección de Total y Botón de Pago
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total a Pagar:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.indigo)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _processOrder(context),
                    icon: const Icon(Icons.payment),
                    label: const Text('Comprar y Pagar'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
