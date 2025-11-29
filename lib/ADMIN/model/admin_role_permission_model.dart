import 'package:cloud_firestore/cloud_firestore.dart';

class RolePermission {
  final String id;
  final String roleName;
  final String description;
  final List<String> permissions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RolePermission({
    required this.id,
    required this.roleName,
    required this.description,
    required this.permissions,
    required this.createdAt,
    this.updatedAt,
  });

  factory RolePermission.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RolePermission(
      id: doc.id,
      roleName: data['roleName'] ?? '',
      description: data['description'] ?? '',
      permissions: List<String>.from(data['permissions'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roleName': roleName,
      'description': description,
      'permissions': permissions,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}

class Permission {
  final String id;
  final String name;
  final String category;
  final String description;

  Permission({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
  });

  factory Permission.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Permission(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
    );
  }
}
