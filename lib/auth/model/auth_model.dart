import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String department;
  final String phone;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime lastLogin;
  final bool isActive;
  final UserPreferences preferences;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.department,
    required this.phone,
    this.profilePicture,
    required this.createdAt,
    required this.lastLogin,
    this.isActive = true,
    required this.preferences,
  });

  // Convert UserModel to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.value,
      'department': department,
      'phone': phone,
      'profilePicture': profilePicture,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'isActive': isActive,
      'preferences': preferences.toMap(),
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: UserRoleExtension.fromString(map['role'] ?? 'RAN_ENGINEER'),
      department: map['department'] ?? '',
      phone: map['phone'] ?? '',
      profilePicture: map['profilePicture'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      preferences: map['preferences'] != null
          ? UserPreferences.fromMap(map['preferences'])
          : UserPreferences(),
    );
  }

  // Create UserModel from Firestore DocumentSnapshot
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  // Copy with method for updating user data
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    UserRole? role,
    String? department,
    String? phone,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    UserPreferences? preferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, role: ${role.displayName})';
  }
}

// User Preferences Model
class UserPreferences {
  final String theme; // 'dark' or 'light'
  final bool notifications;
  final String language;

  UserPreferences({
    this.theme = 'dark',
    this.notifications = true,
    this.language = 'en',
  });

  Map<String, dynamic> toMap() {
    return {
      'theme': theme,
      'notifications': notifications,
      'language': language,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      theme: map['theme'] ?? 'dark',
      notifications: map['notifications'] ?? true,
      language: map['language'] ?? 'en',
    );
  }

  UserPreferences copyWith({
    String? theme,
    bool? notifications,
    String? language,
  }) {
    return UserPreferences(
      theme: theme ?? this.theme,
      notifications: notifications ?? this.notifications,
      language: language ?? this.language,
    );
  }
}
