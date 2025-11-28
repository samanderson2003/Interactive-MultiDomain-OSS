import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/model/auth_model.dart';
import '../../utils/constants.dart';
import '../model/core_profile_model.dart';

class CoreProfileController with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  String _errorMessage = '';

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadUserProfile(UserModel currentUser) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .doc(currentUser.uid)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        _userProfile = UserProfile(
          uid: currentUser.uid,
          email: currentUser.email,
          name: currentUser.name,
          role: currentUser.role,
          employeeId: data['employeeId'] ?? 'N/A',
          location: data['location'] ?? 'Unknown',
          joinedDate:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          permissions: _getRolePermissions(currentUser.role),
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  List<String> _getRolePermissions(UserRole role) {
    switch (role) {
      case UserRole.CORE_ENGINEER:
        return [
          'View CORE Network Elements',
          'Monitor Network Topology',
          'View KPI Metrics',
          'Access Service Health',
          'View Analytics',
          'Generate Reports',
        ];
      case UserRole.ADMIN:
        return [
          'Full System Access',
          'User Management',
          'Configuration',
          'All Module Access',
        ];
      default:
        return ['View Dashboard'];
    }
  }

  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    if (_userProfile == null) return;

    try {
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .doc(_userProfile!.uid)
          .update({'preferences': preferences});

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update preferences';
      notifyListeners();
    }
  }

  void clearProfile() {
    _userProfile = null;
    _errorMessage = '';
    notifyListeners();
  }
}
