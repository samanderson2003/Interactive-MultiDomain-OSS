import '../../utils/constants.dart';

class UserProfile {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String employeeId;
  final String location;
  final DateTime joinedDate;
  final List<String> permissions;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.employeeId,
    required this.location,
    required this.joinedDate,
    required this.permissions,
  });

  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.toString(),
      'employeeId': employeeId,
      'location': location,
      'joinedDate': joinedDate.toIso8601String(),
      'permissions': permissions,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == json['role'],
        orElse: () => UserRole.NETWORK_ANALYST,
      ),
      employeeId: json['employeeId'],
      location: json['location'],
      joinedDate: DateTime.parse(json['joinedDate']),
      permissions: List<String>.from(json['permissions']),
    );
  }
}
