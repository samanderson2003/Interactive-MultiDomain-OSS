import 'package:flutter/material.dart';

// App Information
class AppConstants {
  static const String appName = 'Interactive Telecom';
  static const String appVersion = 'v1.0.0';
  static const String appTagline = 'Network Monitoring Dashboard';
}

// User Roles
enum UserRole {
  ADMIN,
  RAN_ENGINEER,
  CORE_ENGINEER,
  IP_ENGINEER,
  NOC_MANAGER,
  NETWORK_ANALYST,
}

// Role Extensions
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.ADMIN:
        return 'System Administrator';
      case UserRole.RAN_ENGINEER:
        return 'RAN Engineer';
      case UserRole.CORE_ENGINEER:
        return 'CORE Engineer';
      case UserRole.IP_ENGINEER:
        return 'IP Transport Engineer';
      case UserRole.NOC_MANAGER:
        return 'NOC Manager';
      case UserRole.NETWORK_ANALYST:
        return 'Network Analyst';
    }
  }

  String get value {
    return toString().split('.').last;
  }

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.value == role,
      orElse: () => UserRole.RAN_ENGINEER,
    );
  }
}

// Color Palette - Dark Mode (Network Monitoring Theme)
class DarkThemeColors {
  // Main Background Colors (Dark Navy/Black)
  static const Color background = Color(0xFF0a0e1a);
  static const Color cardBackground = Color(0xFF131823);
  static const Color surfaceElevated = Color(0xFF1a2030);

  // Text Colors
  static const Color textPrimary = Color(0xFFf8fafc);
  static const Color textSecondary = Color(0xFF94a3b8);
  static const Color textTertiary = Color(0xFF64748b);

  // Primary Brand Colors (Electric Blue/Cyan)
  static const Color primary = Color(0xFF0ea5e9);
  static const Color primaryLight = Color(0xFF38bdf8);
  static const Color primaryDark = Color(0xFF0284c7);

  // Accent Colors (Purple/Violet)
  static const Color accent = Color(0xFF8b5cf6);
  static const Color accentLight = Color(0xFFa78bfa);
  static const Color accentDark = Color(0xFF7c3aed);

  // Status Colors (Vibrant Neon)
  static const Color success = Color(0xFF10b981); // Green
  static const Color successBright = Color(0xFF34d399);
  static const Color warning = Color(0xFFf59e0b); // Orange
  static const Color warningBright = Color(0xFFfbbf24);
  static const Color error = Color(0xFFef4444); // Red
  static const Color errorBright = Color(0xFFf87171);
  static const Color info = Color(0xFF06b6d4); // Cyan
  static const Color infoBright = Color(0xFF22d3ee);

  // Chart/Graph Colors (Neon/Vibrant)
  static const Color chartBlue = Color(0xFF3b82f6);
  static const Color chartCyan = Color(0xFF06b6d4);
  static const Color chartGreen = Color(0xFF10b981);
  static const Color chartYellow = Color(0xFFfbbf24);
  static const Color chartOrange = Color(0xFFf97316);
  static const Color chartRed = Color(0xFFef4444);
  static const Color chartPurple = Color(0xFF8b5cf6);
  static const Color chartPink = Color(0xFFec4899);

  // Border & Divider Colors
  static const Color border = Color(0xFF1e293b);
  static const Color borderLight = Color(0xFF334155);
  static const Color divider = Color(0xFF1e293b);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF0a0e1a),
    Color(0xFF1e3a8a),
    Color(0xFF6366f1),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF3b82f6),
    Color(0xFF8b5cf6),
    Color(0xFFec4899),
  ];

  static const List<Color> successGradient = [
    Color(0xFF059669),
    Color(0xFF10b981),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFdc2626),
    Color(0xFFef4444),
  ];
}

// Color Palette - Light Mode
class LightThemeColors {
  static const Color background = Color(0xFFf7f9fc);
  static const Color cardBackground = Color(0xFFffffff);
  static const Color textPrimary = Color(0xFF2d3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color accent = Color(0xFF3b82f6);
  static const Color accentLight = Color(0xFF60a5fa);
  static const Color success = Color(0xFF22c55e);
  static const Color warning = Color(0xFFf59e0b);
  static const Color error = Color(0xFFef4444);
  static const Color info = Color(0xFF06b6d4);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFFffffff),
    Color(0xFF3b82f6),
    Color(0xFF8b5cf6),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF3b82f6),
    Color(0xFF8b5cf6),
  ];
}

// Routes
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String adminDashboard = '/admin-dashboard';
  static const String ranDashboard = '/ran-dashboard';
  static const String coreDashboard = '/core-dashboard';
  static const String ipDashboard = '/ip-dashboard';
  static const String nocDashboard = '/noc-dashboard';
  static const String analystDashboard = '/analyst-dashboard';
}

// Storage Keys
class StorageKeys {
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String isLoggedIn = 'is_logged_in';
  static const String theme = 'theme_mode';
  static const String rememberMe = 'remember_me';
}

// Error Messages
class ErrorMessages {
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String loginFailed = 'Invalid email or password';
  static const String networkError =
      'Network error. Please check your connection';
  static const String userNotFound = 'User not found in database';
  static const String unknownError = 'An unexpected error occurred';
}

// Success Messages
class SuccessMessages {
  static const String loginSuccess = 'Login successful!';
  static const String logoutSuccess = 'Logged out successfully';
}

// Firestore Collections
class FirestoreCollections {
  static const String users = 'users';
  static const String btsData = 'bts_data';
  static const String coreElements = 'core_elements';
  static const String ipTransport = 'ip_transport';
  static const String alarms = 'alarms';
  static const String reports = 'reports';
}

// Animation Durations
class AnimationDurations {
  static const Duration splash = Duration(seconds: 3);
  static const Duration short = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration long = Duration(milliseconds: 800);
}
