import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/noc_profile_model.dart';
import '../../auth/model/auth_model.dart';
import '../../utils/constants.dart';

class NOCProfileController with ChangeNotifier {
  NOCUserProfile? _userProfile;
  bool _isLoading = false;
  String _errorMessage = '';

  NOCUserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> loadUserProfile(UserModel user) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Get user-specific data from Firestore if needed
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      // Get role-based permissions
      final permissions = _getRolePermissions(user.role);

      // Create profile
      _userProfile = NOCUserProfile.fromUser(user, permissions);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  List<String> _getRolePermissions(UserRole role) {
    switch (role) {
      case UserRole.NOC_MANAGER:
        return [
          'View all network alarms',
          'Acknowledge and clear alarms',
          'Assign alarms to engineers',
          'Generate alarm reports',
          'Configure alarm thresholds',
          'Manage escalation policies',
          'View network performance metrics',
          'Access historical alarm data',
        ];
      default:
        return [];
    }
  }

  void clearProfile() {
    _userProfile = null;
    _errorMessage = '';
    _isLoading = false;
    notifyListeners();
  }
}
