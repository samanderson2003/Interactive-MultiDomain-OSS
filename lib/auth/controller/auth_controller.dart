import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/auth_model.dart';
import '../../utils/constants.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // Check if user is already logged in
  Future<bool> checkAuthStatus() async {
    try {
      final User? firebaseUser = _auth.currentUser;

      if (firebaseUser != null) {
        // Fetch user data from Firestore
        await _fetchUserData(firebaseUser.uid);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Auth check error: $e');
      return false;
    }
  }

  // Login with email and password
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Sign in with Firebase Auth
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      if (userCredential.user != null) {
        // Fetch user data from Firestore
        await _fetchUserData(userCredential.user!.uid);

        if (_currentUser != null) {
          // Update last login timestamp
          await _updateLastLogin(_currentUser!.uid);

          // Save login state
          await _saveLoginState(rememberMe);

          _setLoading(false);
          return true;
        } else {
          _errorMessage = ErrorMessages.userNotFound;
          _setLoading(false);
          return false;
        }
      }

      _setLoading(false);
      return false;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _handleAuthException(e);
      return false;
    } catch (e) {
      _setLoading(false);
      _errorMessage = ErrorMessages.unknownError;
      debugPrint('Login error: $e');
      return false;
    }
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData(String uid) async {
    try {
      final DocumentSnapshot userDoc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();

      if (userDoc.exists) {
        _currentUser = UserModel.fromDocument(userDoc);
        notifyListeners();
      } else {
        _errorMessage = ErrorMessages.userNotFound;
      }
    } catch (e) {
      _errorMessage = ErrorMessages.networkError;
      debugPrint('Fetch user data error: $e');
    }
  }

  // Update last login timestamp
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection(FirestoreCollections.users).doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Update last login error: $e');
    }
  }

  // Save login state to local storage
  Future<void> _saveLoginState(bool rememberMe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageKeys.isLoggedIn, true);
      await prefs.setString(StorageKeys.userId, _currentUser!.uid);
      await prefs.setString(StorageKeys.userRole, _currentUser!.role.value);
      await prefs.setBool(StorageKeys.rememberMe, rememberMe);
    } catch (e) {
      debugPrint('Save login state error: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _setLoading(true);

      // Sign out from Firebase
      await _auth.signOut();

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Clear current user
      _currentUser = null;
      _errorMessage = null;

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      debugPrint('Logout error: $e');
    }
  }

  // Signup with email and password
  Future<bool> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String department,
    required UserRole role,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Create user in Firebase Auth
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      if (userCredential.user != null) {
        // Generate employee ID
        final employeeId =
            'EMP-${DateTime.now().year}-${userCredential.user!.uid.substring(0, 8).toUpperCase()}';

        // Create user document in Firestore
        final newUser = UserModel(
          uid: userCredential.user!.uid,
          email: email.trim(),
          name: name.trim(),
          role: role,
          department: department.trim(),
          phone: phone.trim(),
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          isActive: true,
          preferences: UserPreferences(),
        );

        // Save to Firestore with additional fields
        final userData = newUser.toMap();
        userData['employeeId'] = employeeId;
        userData['location'] = 'India'; // Default location

        await _firestore
            .collection(FirestoreCollections.users)
            .doc(userCredential.user!.uid)
            .set(userData);

        // Set current user
        _currentUser = newUser;

        // Save login state
        await _saveLoginState(true);

        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _handleSignupException(e);
      return false;
    } catch (e) {
      _setLoading(false);
      _errorMessage = ErrorMessages.unknownError;
      debugPrint('Signup error: $e');
      return false;
    }
  }

  // Password reset
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      await _auth.sendPasswordResetEmail(email: email.trim());
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _handleAuthException(e);
      return false;
    } catch (e) {
      _setLoading(false);
      _errorMessage = ErrorMessages.unknownError;
      return false;
    }
  }

  // Get dashboard route based on user role
  String getDashboardRoute() {
    if (_currentUser == null) return AppRoutes.login;

    switch (_currentUser!.role) {
      case UserRole.ADMIN:
        return AppRoutes.adminDashboard;
      case UserRole.RAN_ENGINEER:
        return AppRoutes.ranDashboard;
      case UserRole.CORE_ENGINEER:
        return AppRoutes.coreDashboard;
      case UserRole.IP_ENGINEER:
        return AppRoutes.ipDashboard;
      case UserRole.NOC_MANAGER:
        return AppRoutes.nocDashboard;
      case UserRole.NETWORK_ANALYST:
        return AppRoutes.analystDashboard;
    }
  }

  // Handle Firebase Auth exceptions
  void _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
        _errorMessage = ErrorMessages.loginFailed;
        break;
      case 'invalid-email':
        _errorMessage = ErrorMessages.emailInvalid;
        break;
      case 'user-disabled':
        _errorMessage = 'This account has been disabled';
        break;
      case 'too-many-requests':
        _errorMessage = 'Too many attempts. Please try again later';
        break;
      case 'network-request-failed':
        _errorMessage = ErrorMessages.networkError;
        break;
      default:
        _errorMessage = ErrorMessages.loginFailed;
    }
  }

  // Handle Firebase Signup exceptions
  void _handleSignupException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        _errorMessage = 'This email is already registered';
        break;
      case 'invalid-email':
        _errorMessage = ErrorMessages.emailInvalid;
        break;
      case 'operation-not-allowed':
        _errorMessage = 'Signup is currently disabled';
        break;
      case 'weak-password':
        _errorMessage = 'Password is too weak';
        break;
      case 'network-request-failed':
        _errorMessage = ErrorMessages.networkError;
        break;
      default:
        _errorMessage = 'Signup failed. Please try again';
    }
  }

  // Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
