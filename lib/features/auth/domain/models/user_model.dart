import 'package:equatable/equatable.dart';

enum UserRole { admin, user }

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;

  static UserRole determineRoleFromEmail(String email) {
    if (email.trim().toLowerCase().endsWith('@admin.com')) {
      return UserRole.admin;
    }
    return UserRole.user;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.user,
    );
  }

  @override
  List<Object?> get props => [id, email, name, role];
}
