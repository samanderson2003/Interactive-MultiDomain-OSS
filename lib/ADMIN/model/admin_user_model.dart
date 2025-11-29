import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';

class AdminUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String phone;
  final String department;
  final String employeeId;
  final String location;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastLogin;
  final String? profilePicture;

  AdminUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.department,
    required this.employeeId,
    required this.location,
    required this.isActive,
    required this.createdAt,
    required this.lastLogin,
    this.profilePicture,
  });

  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get statusText => isActive ? 'Active' : 'Inactive';

  factory AdminUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUser(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: UserRoleExtension.fromString(data['role'] ?? 'RAN_ENGINEER'),
      phone: data['phone'] ?? '',
      department: data['department'] ?? '',
      employeeId: data['employeeId'] ?? '',
      location: data['location'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      profilePicture: data['profilePicture'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.value,
      'phone': phone,
      'department': department,
      'employeeId': employeeId,
      'location': location,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'profilePicture': profilePicture,
    };
  }
}

class AdminActivityLog {
  final String id;
  final String userId;
  final String userName;
  final String action;
  final String description;
  final DateTime timestamp;
  final String? ipAddress;

  AdminActivityLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.description,
    required this.timestamp,
    this.ipAddress,
  });

  factory AdminActivityLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminActivityLog(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      action: data['action'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ipAddress: data['ipAddress'],
    );
  }
}

class AdminSession {
  final String sessionId;
  final String userId;
  final String userName;
  final String email;
  final UserRole role;
  final DateTime loginTime;
  final String deviceInfo;
  final String ipAddress;
  final bool isActive;

  AdminSession({
    required this.sessionId,
    required this.userId,
    required this.userName,
    required this.email,
    required this.role,
    required this.loginTime,
    required this.deviceInfo,
    required this.ipAddress,
    required this.isActive,
  });

  factory AdminSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminSession(
      sessionId: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      email: data['email'] ?? '',
      role: UserRoleExtension.fromString(data['role'] ?? 'RAN_ENGINEER'),
      loginTime: (data['loginTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deviceInfo: data['deviceInfo'] ?? '',
      ipAddress: data['ipAddress'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }
}
