class UserData {
  final String uid; // ID de Firebase Auth
  final String email;
  final String name;
  final String role; // 'Cliente' o 'Vendedor'
  final String? businessName; // Solo para Vendedores

  UserData({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.businessName,
  });

  // Método para convertir el objeto a un mapa (para guardar en Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'businessName': businessName,
      'createdAt': DateTime.now(),
    };
  }

  // Método para crear el objeto a partir de un mapa (para leer desde Firestore)
  factory UserData.fromMap(Map<String, dynamic> data) {
    return UserData(
      uid: data['uid'] as String,
      email: data['email'] as String,
      name: data['name'] as String,
      role: data['role'] as String,
      businessName: data['businessName'] as String?,
    );
  }
}
