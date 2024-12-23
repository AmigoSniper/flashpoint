class User {
  final int id;
  final String? image;
  final String name;
  final String email;
  final String role;
  final String status;
  final String? resetPasswordToken;
  final String? resetTokenExpires;
  final String? tokenLogin;
  final String? tokenLoginExpires;
  final DateTime createdAt;
  final DateTime? deletedAt;

  User({
    required this.id,
    this.image,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.resetPasswordToken,
    this.resetTokenExpires,
    this.tokenLogin,
    this.tokenLoginExpires,
    required this.createdAt,
    this.deletedAt,
  });

  // Factory constructor untuk parsing JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      image: json['image'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      status: json['status'],
      resetPasswordToken: json['ResetPasswordToken'],
      resetTokenExpires: json['ResetTokenExpires'],
      tokenLogin: json['tokenLogin'],
      tokenLoginExpires: json['tokenLoginExpires'],
      createdAt: DateTime.parse(json['createdAt']),
      deletedAt:
          json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    );
  }

  // Konversi objek ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'ResetPasswordToken': resetPasswordToken,
      'ResetTokenExpires': resetTokenExpires,
      'tokenLogin': tokenLogin,
      'tokenLoginExpires': tokenLoginExpires,
      'createdAt': createdAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}
