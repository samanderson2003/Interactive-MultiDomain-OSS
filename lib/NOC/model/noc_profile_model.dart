import '../../utils/constants.dart';
import '../../auth/model/auth_model.dart';

class NOCUserProfile {
  final String uid;
  final String name;
  final String email;
  final String employeeId;
  final String location;
  final UserRole role;
  final DateTime joinedDate;
  final List<String> permissions;

  NOCUserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.employeeId,
    required this.location,
    required this.role,
    required this.joinedDate,
    required this.permissions,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  factory NOCUserProfile.fromUser(UserModel user, List<String> permissions) {
    return NOCUserProfile(
      uid: user.uid,
      name: user.name,
      email: user.email,
      employeeId: 'EMP-${user.uid.substring(0, 6).toUpperCase()}',
      location: user.department,
      role: user.role,
      joinedDate: user.createdAt,
      permissions: permissions,
    );
  }
}
