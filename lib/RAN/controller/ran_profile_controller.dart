import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/profile_model.dart';
import '../../auth/model/auth_model.dart';
import '../../utils/constants.dart';

class RANProfileController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserProfile? _userProfile;
  bool _isLoading = false;
  String _errorMessage = '';

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Load user profile from Firebase
  Future<void> loadUserProfile(UserModel currentUser) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Fetch user document from Firestore
      final userDoc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;

        // Get role-based permissions
        final permissions = _getRolePermissions(currentUser.role);

        // Convert UserModel to UserProfile
        _userProfile = UserProfile(
          id: currentUser.uid,
          name: currentUser.name,
          email: currentUser.email,
          role: currentUser.role.displayName,
          department: currentUser.department,
          employeeId:
              data['employeeId'] ??
              'EMP-${currentUser.uid.substring(0, 8).toUpperCase()}',
          phone: currentUser.phone,
          location: data['location'] ?? 'India',
          joinedDate: currentUser.createdAt,
          avatarUrl: currentUser.profilePicture ?? '',
          permissions: permissions,
          preferences: {
            'theme': currentUser.preferences.theme,
            'notifications': currentUser.preferences.notifications,
            'language': currentUser.preferences.language,
            'autoRefresh': data['autoRefresh'] ?? true,
            'refreshInterval': data['refreshInterval'] ?? 5,
          },
        );

        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = 'User profile not found';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to load user profile: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get permissions based on user role
  List<String> _getRolePermissions(UserRole role) {
    switch (role) {
      case UserRole.ADMIN:
        return [
          'Full System Access',
          'User Management',
          'System Configuration',
          'All Module Access',
          'Export Reports',
          'View Analytics',
          'Manage Alerts',
        ];
      case UserRole.RAN_ENGINEER:
        return [
          'View BTS Data',
          'Manage Alerts',
          'Export Reports',
          'Configure Thresholds',
          'View Analytics',
          'Access RAN Module',
        ];
      case UserRole.CORE_ENGINEER:
        return [
          'View CORE Data',
          'Manage Network Elements',
          'Export Reports',
          'View Analytics',
          'Access CORE Module',
        ];
      case UserRole.IP_ENGINEER:
        return [
          'View IP Transport Data',
          'Manage Network Devices',
          'Export Reports',
          'View Analytics',
          'Access IP Module',
        ];
      case UserRole.NOC_MANAGER:
        return [
          'View All Modules',
          'Manage All Alerts',
          'Export Reports',
          'View Analytics',
          'Team Management',
        ];
      case UserRole.NETWORK_ANALYST:
        return [
          'View All Data',
          'Advanced Analytics',
          'Export Reports',
          'Generate Reports',
          'View Analytics',
        ];
    }
  }

  // Update user preferences in Firebase
  Future<void> updatePreferences(Map<String, dynamic> newPreferences) async {
    if (_userProfile == null) return;

    try {
      // Update preferences in Firestore
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(_userProfile!.id)
          .update({
            'preferences.theme':
                newPreferences['theme'] ?? _userProfile!.preferences['theme'],
            'preferences.notifications':
                newPreferences['notifications'] ??
                _userProfile!.preferences['notifications'],
            'preferences.language':
                newPreferences['language'] ??
                _userProfile!.preferences['language'],
            if (newPreferences.containsKey('autoRefresh'))
              'autoRefresh': newPreferences['autoRefresh'],
            if (newPreferences.containsKey('refreshInterval'))
              'refreshInterval': newPreferences['refreshInterval'],
          });

      // Update local profile
      _userProfile = UserProfile(
        id: _userProfile!.id,
        name: _userProfile!.name,
        email: _userProfile!.email,
        role: _userProfile!.role,
        department: _userProfile!.department,
        employeeId: _userProfile!.employeeId,
        phone: _userProfile!.phone,
        location: _userProfile!.location,
        joinedDate: _userProfile!.joinedDate,
        avatarUrl: _userProfile!.avatarUrl,
        permissions: _userProfile!.permissions,
        preferences: {..._userProfile!.preferences, ...newPreferences},
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update preferences: $e';
      notifyListeners();
    }
  }

  // Clear profile on logout
  void clearProfile() {
    _userProfile = null;
    _errorMessage = '';
    notifyListeners();
  }
}
