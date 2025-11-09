class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String role; // 'Cliente' o 'Vendedor'

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // Nota: El 'uid' no viene en el Map de Firestore, pero lo necesitas.
    // Asumo que lo tienes en el Map por simplificación, o puedes ajustarlo
    // si lo pasas desde el DocumentReference.
    return UserProfile(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
    };
  }
}
