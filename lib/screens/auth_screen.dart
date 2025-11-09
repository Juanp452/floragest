import 'package:flutter/material.dart';
import '../main.dart'; // Importa las constantes de color
import 'user_auth_form.dart'; // Importa el formulario de login/registro

// ----------------------------------------------------
// PANTALLA DE AUTENTICACIÓN / SELECCIÓN DE ROL
// ----------------------------------------------------
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenido/a a FloraGest')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.local_florist, size: 80, color: primaryColor),
              const SizedBox(height: 20),
              const Text(
                'Selecciona tu Tipo de Cuenta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Botón para Cliente
              _AuthButton(
                icon: Icons.person,
                label: 'Soy Cliente (Comprar)',
                color: accentColor,
                onPressed: () {
                  // Navegación a la pantalla de Autenticación/Registro específica para Cliente
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const UserAuthForm(userType: 'Cliente'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Botón para Vendedor
              _AuthButton(
                icon: Icons.store,
                label: 'Soy Vendedor (Gestionar/Vender)',
                color: primaryColor,
                onPressed: () {
                  // Navegación a la pantalla de Autenticación/Registro específica para Vendedor
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const UserAuthForm(userType: 'Vendedor'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // Botón de acceso directo a HOME (temporal para demo)
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/home'),
                child: const Text(
                  'Omitir por ahora (Ir a Home Demo)',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget de botón reutilizable, mantenido aquí por simplicidad.
class _AuthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _AuthButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 60), // Ocupa todo el ancho
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
    );
  }
}
