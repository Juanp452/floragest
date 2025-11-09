import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  // *** CORRECCIÓN: Agregar 'const' al constructor ***
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soporte y Ayuda'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido a Floragest',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tu compañero ideal para la jardinería. Usamos tecnología de IA para ayudarte a cuidar tus plantas y ofrecemos una selección curada de productos.',
              style: TextStyle(fontSize: 16),
            ),
            const Divider(height: 30),
            const Text(
              'Contacto',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.email, color: Color(0xFF4CAF50)),
              title: const Text('soporte@floragest.com'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Color(0xFF4CAF50)),
              title: const Text('+34 123 45 67 89'),
              onTap: () {},
            ),
            const Divider(height: 30),
            const Text(
              'Preguntas Frecuentes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFaqItem(
              '¿Cómo funciona la identificación de plantas con IA?',
              'Simplemente ve a la pestaña "AI Cuidado", toma una foto clara de tu planta (hojas, tronco y tierra) y nuestro modelo de Gemini la analizará para darte un diagnóstico.',
            ),
            _buildFaqItem(
              '¿Qué pasa si mi carrito está vacío?',
              'Si tu carrito está vacío, se te pedirá que vuelvas a la pestaña "Tienda" para explorar y añadir productos.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title:
          Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
          child: Text(answer, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }
}
