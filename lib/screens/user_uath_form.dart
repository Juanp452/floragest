import 'package:flutter/material.dart';
import '../main.dart'; // Importa las constantes de color

// ----------------------------------------------------
// PANTALLA DE AUTENTICACIÓN/REGISTRO REAL
// ----------------------------------------------------
class UserAuthForm extends StatefulWidget {
  final String userType; // 'Cliente' o 'Vendedor'
  const UserAuthForm({required this.userType, super.key});

  @override
  State<UserAuthForm> createState() => _UserAuthFormState();
}

class _UserAuthFormState extends State<UserAuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true; // Estado para alternar entre Login y Registro
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  // Campos adicionales para Vendedor
  final TextEditingController businessNameController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Por ahora, solo navegamos a la pantalla principal como demo
      // TODO: IMPLEMENTAR: Lógica de Firebase Auth y guardar datos en Firestore
      print(
        '${isLogin ? 'Iniciando Sesión' : 'Registrando'} como ${widget.userType}',
      );
      // Navegación a Home
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    businessNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${isLogin ? 'Login' : 'Registro'} de ${widget.userType}'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Título
                Text(
                  isLogin ? 'Bienvenido de nuevo' : 'Únete a FloraGest',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Campos comunes de Autenticación
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email, color: primaryColor),
                  ),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Por favor, introduce un correo válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock, color: primaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Campos de Registro (solo si isLogin es false)
                if (!isLogin) ...[
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre Completo',
                      prefixIcon: Icon(Icons.person, color: primaryColor),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce tu nombre.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  // Campo específico para Vendedores
                  if (widget.userType == 'Vendedor')
                    TextFormField(
                      controller: businessNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de tu Floristería/Negocio',
                        prefixIcon: Icon(Icons.storefront, color: accentColor),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido para Vendedores.';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 30),
                ],

                // Botón principal de acción
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(isLogin ? 'INICIAR SESIÓN' : 'REGISTRARSE'),
                ),
                const SizedBox(height: 20),

                // Alternar entre Login y Registro
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                      _formKey.currentState
                          ?.reset(); // Limpiar validación al cambiar
                    });
                  },
                  child: Text(
                    isLogin
                        ? '¿No tienes cuenta? Regístrate aquí.'
                        : '¿Ya tienes cuenta? Inicia sesión.',
                    style: TextStyle(color: primaryColor.withOpacity(0.8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
