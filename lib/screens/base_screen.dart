import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floragest/screens/shop_screen.dart';
import 'package:floragest/screens/ai_feature_screen.dart';
import 'package:floragest/screens/cart_screen.dart';
import 'package:floragest/screens/support_screen.dart';
import 'package:floragest/services/firestore_service.dart';
import 'package:floragest/models/user_profile.dart';
import 'package:floragest/models/cart_item.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Vendedor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.admin_panel_settings, size: 80, color: Colors.indigo),
            SizedBox(height: 16),
            Text(
              'Bienvenido, Vendedor/Administrador',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Aquí va la gestión de productos, pedidos, etc.'),
          ],
        ),
      ),
    );
  }
}

class BaseScreen extends StatelessWidget {
  BaseScreen({super.key});

  final FirestoreService firestoreService = FirestoreService();

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<UserProfile?>(
      future: firestoreService.getUserProfile(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = snapshot.data;
        final isClient = (profile?.role ?? 'Cliente') == 'Cliente';

        if (!isClient) {
          return const AdminDashboard();
        }

        return _buildClientInterface(context);
      },
    );
  }

  Widget _buildClientInterface(BuildContext context) {
    final cartCountStream = firestoreService.getCartStream().map(
          (items) => items.fold<int>(0, (sum, item) => sum + item.quantity),
        );

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Floragest: Tienda de Plantas'),
          actions: [
            StreamBuilder<int>(
              stream: cartCountStream,
              initialData: 0,
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Stack(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.shopping_cart, color: Colors.white),
                      onPressed: () {
                        DefaultTabController.of(context)?.animateTo(2);
                      },
                    ),
                    if (count > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: () => _logout(context),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.store), text: 'Tienda'),
              Tab(icon: Icon(Icons.auto_fix_high), text: 'IA Cuidado'),
              Tab(icon: Icon(Icons.shopping_cart), text: 'Carrito'),
              Tab(icon: Icon(Icons.support_agent), text: 'Soporte'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            ShopScreen(),
            const AiFeatureScreen(),
            CartScreen(),
            const SupportScreen(),
          ],
        ),
      ),
    );
  }
}
