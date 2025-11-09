import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:floragest/main.dart'; // Importa geminiApiUrl
import 'package:firebase_auth/firebase_auth.dart';

// Definición de un mensaje en el chat
class ChatMessage {
  final String text;
  final bool isUser; // true si es el usuario, false si es el bot
  final bool isError;
  final String? userId; // Solo para mostrar quién escribe

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    this.userId,
  });
}

class AiFeatureScreen extends StatefulWidget {
  const AiFeatureScreen({super.key});

  @override
  State<AiFeatureScreen> createState() => _AiFeatureScreenState();
}

class _AiFeatureScreenState extends State<AiFeatureScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'Invitado';
    _addInitialMessage();
  }

  void _addInitialMessage() {
    _messages.add(
      ChatMessage(
        text:
            '¡Hola! Soy FloraBot, tu asistente de Floragest. Pregúntame sobre cuidado de plantas, tipos de flores o consejos de jardinería.',
        isUser: false,
        userId: 'FloraBot',
      ),
    );
  }

  // Lógica para llamar a la API de Gemini
  Future<void> _sendMessage(String text) async {
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, userId: _currentUserId),
      );
      _textController.clear();
      _isLoading = true;
    });

    try {
      // 1. Definición de la Instrucción del Sistema para guiar al modelo
      final systemInstruction = {
        "parts": [
          {
            "text":
                "Eres FloraBot, un amable y experto asistente de e-commerce de flores y plantas llamado Floragest. Tu objetivo es proporcionar consejos de cuidado, responder preguntas sobre botánica, y dirigir amablemente a los usuarios a la tienda si preguntan por la compra de flores o plantas. Responde en español de forma concisa y útil.",
          },
        ],
      };

      // 2. Construcción del historial de chat
      // Para Gemini, el historial se envía en el cuerpo de la solicitud
      final contents = _messages
          .map(
            (m) => {
              "role": m.isUser ? "user" : "model",
              "parts": [
                {"text": m.text},
              ],
            },
          )
          .toList();

      // 3. Payload de la API de Gemini
      final payload = {
        "contents": contents,
        "systemInstruction": systemInstruction,
        // Habilita la búsqueda en Google para grounding
        "tools": [
          {"google_search": {}},
        ],
        "config": {"temperature": 0.7},
      };

      // 4. Solicitud HTTP con retroceso exponencial para reintentos
      final response = await _makeApiRequest(payload);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final responseText =
            data['candidates'][0]['content']['parts'][0]['text'] ??
            'Lo siento, no pude obtener una respuesta válida.';

        setState(() {
          _messages.add(
            ChatMessage(text: responseText, isUser: false, userId: 'FloraBot'),
          );
          _isLoading = false;
        });
      } else {
        throw Exception('Error API: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error en la solicitud Gemini: $e');
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                'Error de conexión: No pude contactar a FloraBot. Asegúrate de que tu clave de API sea válida. $e',
            isUser: false,
            isError: true,
            userId: 'FloraBot',
          ),
        );
        _isLoading = false;
      });
    }
  }

  Future<http.Response> _makeApiRequest(
    Map<String, dynamic> payload, [
    int retryCount = 0,
  ]) async {
    const maxRetries = 3;
    try {
      final response = await http.post(
        Uri.parse(geminiApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
      if (response.statusCode == 429 && retryCount < maxRetries) {
        final delay = Duration(seconds: 1 << retryCount);
        debugPrint(
          'Tasa limitada (429). Reintentando en ${delay.inSeconds}s...',
        );
        await Future.delayed(delay);
        return _makeApiRequest(payload, retryCount + 1);
      }
      return response;
    } catch (e) {
      if (retryCount < maxRetries) {
        final delay = Duration(seconds: 1 << retryCount);
        debugPrint('Error de red. Reintentando en ${delay.inSeconds}s...');
        await Future.delayed(delay);
        return _makeApiRequest(payload, retryCount + 1);
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FloraBot: Asistente IA')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(color: Colors.indigo),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!message.isUser)
            const CircleAvatar(
              backgroundColor: Colors.indigo,
              child: Icon(Icons.psychology_alt, color: Colors.white),
            ),
          const SizedBox(width: 8.0),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  message.userId!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  margin: message.isUser
                      ? const EdgeInsets.only(left: 60.0, top: 5.0)
                      : const EdgeInsets.only(right: 60.0, top: 5.0),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Colors.indigo.shade100
                        : (message.isError
                              ? Colors.red.shade100
                              : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(15),
                      topRight: const Radius.circular(15),
                      bottomLeft: message.isUser
                          ? const Radius.circular(15)
                          : const Radius.circular(0),
                      bottomRight: message.isUser
                          ? const Radius.circular(0)
                          : const Radius.circular(15),
                    ),
                    border: Border.all(
                      color: message.isError
                          ? Colors.red
                          : Colors.indigo.shade200,
                      width: message.isError ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isError
                          ? Colors.red.shade800
                          : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          if (message.isUser)
            CircleAvatar(
              backgroundColor: Colors.grey.shade400,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: (value) => _sendMessage(value),
                decoration: InputDecoration.collapsed(
                  hintText: 'Chatea con FloraBot...',
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                color: Colors.indigo,
                onPressed: _isLoading
                    ? null
                    : () => _sendMessage(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
