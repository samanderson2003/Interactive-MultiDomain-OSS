class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final String employeeId;
  final String phone;
  final String location;
  final DateTime joinedDate;
  final String avatarUrl;
  final List<String> permissions;
  final Map<String, dynamic> preferences;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.employeeId,
    required this.phone,
    required this.location,
    required this.joinedDate,
    this.avatarUrl = '',
    this.permissions = const [],
    this.preferences = const {},
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      department: json['department'] ?? '',
      employeeId: json['employeeId'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      joinedDate: DateTime.parse(
        json['joinedDate'] ?? DateTime.now().toIso8601String(),
      ),
      avatarUrl: json['avatarUrl'] ?? '',
      permissions: List<String>.from(json['permissions'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'department': department,
      'employeeId': employeeId,
      'phone': phone,
      'location': location,
      'joinedDate': joinedDate.toIso8601String(),
      'avatarUrl': avatarUrl,
      'permissions': permissions,
      'preferences': preferences,
    };
  }
}
