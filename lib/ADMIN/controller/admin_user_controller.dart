import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/admin_user_model.dart';
import '../../utils/constants.dart';

class AdminUserController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<AdminUser> _users = [];
  List<AdminSession> _activeSessions = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  String _searchQuery = '';
  UserRole? _filterRole;
  bool? _filterStatus;

  // Getters
  List<AdminUser> get users => _getFilteredUsers();
  List<AdminSession> get activeSessions => _activeSessions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get filtered users
  List<AdminUser> _getFilteredUsers() {
    var filtered = _users;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.employeeId.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_filterRole != null) {
      filtered = filtered.where((user) => user.role == _filterRole).toList();
    }

    if (_filterStatus != null) {
      filtered = filtered
          .where((user) => user.isActive == _filterStatus)
          .toList();
    }

    return filtered;
  }

  // Load all users
  Future<void> loadUsers() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final snapshot = await _firestore.collection('users').get();
      _users = snapshot.docs
          .map((doc) => AdminUser.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load users: $e';
      notifyListeners();
      debugPrint('Error loading users: $e');
    }
  }

  // Load active sessions
  Future<void> loadActiveSessions() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('active_sessions')
          .where('isActive', isEqualTo: true)
          .get();

      _activeSessions = snapshot.docs
          .map((doc) => AdminSession.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('Error loading active sessions: $e');
      // Provide mock data if collection doesn't exist
      _activeSessions = [];
      notifyListeners();
    }
  }

  // Create new user
  Future<bool> createUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    required String department,
    required String location,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        final employeeId =
            'EMP-${DateTime.now().year}-${uid.substring(0, 8).toUpperCase()}';

        // Create user document in Firestore
        await _firestore.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'role': role.value,
          'phone': phone,
          'department': department,
          'employeeId': employeeId,
          'location': location,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });

        await loadUsers();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to create user: $e';
      notifyListeners();
      debugPrint('Error creating user: $e');
      return false;
    }
  }

  // Update user
  Future<bool> updateUser({
    required String uid,
    required String name,
    required String phone,
    required UserRole role,
    required String department,
    required String location,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'phone': phone,
        'role': role.value,
        'department': department,
        'location': location,
      });

      await loadUsers();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update user: $e';
      notifyListeners();
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  // Toggle user status (activate/deactivate)
  Future<bool> toggleUserStatus(String uid, bool isActive) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isActive': isActive,
      });

      await loadUsers();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update user status: $e';
      notifyListeners();
      debugPrint('Error toggling user status: $e');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('users').doc(uid).delete();

      await loadUsers();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete user: $e';
      notifyListeners();
      debugPrint('Error deleting user: $e');
      return false;
    }
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set role filter
  void setRoleFilter(UserRole? role) {
    _filterRole = role;
    notifyListeners();
  }

  // Set status filter
  void setStatusFilter(bool? status) {
    _filterStatus = status;
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _filterRole = null;
    _filterStatus = null;
    notifyListeners();
  }

  // Get user by ID
  AdminUser? getUserById(String uid) {
    try {
      return _users.firstWhere((user) => user.uid == uid);
    } catch (e) {
      return null;
    }
  }

  // Terminate session
  Future<bool> terminateSession(String sessionId) async {
    try {
      await _firestore.collection('active_sessions').doc(sessionId).update({
        'isActive': false,
        'endTime': FieldValue.serverTimestamp(),
      });

      await loadActiveSessions();
      return true;
    } catch (e) {
      debugPrint('Error terminating session: $e');
      return false;
    }
  }
}
