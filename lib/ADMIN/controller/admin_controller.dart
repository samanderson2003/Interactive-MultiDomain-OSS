import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/admin_user_model.dart';
import '../model/admin_system_stats_model.dart';

class AdminController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminSystemStats _systemStats = AdminSystemStats.empty();
  UserRoleDistribution _roleDistribution = UserRoleDistribution.empty();
  List<NetworkDomainStats> _domainStats = [];
  List<AdminActivityLog> _recentActivities = [];
  bool _isLoading = false;

  // Getters
  AdminSystemStats get systemStats => _systemStats;
  UserRoleDistribution get roleDistribution => _roleDistribution;
  List<NetworkDomainStats> get domainStats => _domainStats;
  List<AdminActivityLog> get recentActivities => _recentActivities;
  bool get isLoading => _isLoading;

  // Load dashboard statistics
  Future<void> loadDashboardStats() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future.wait([
        _loadSystemStats(),
        _loadRoleDistribution(),
        _loadDomainStats(),
        _loadRecentActivities(),
      ]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading dashboard stats: $e');
    }
  }

  Future<void> _loadSystemStats() async {
    try {
      // Load users count
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;
      final activeUsers = usersSnapshot.docs
          .where((doc) => (doc.data()['isActive'] ?? false) == true)
          .length;

      // Mock data for network elements (replace with actual queries)
      _systemStats = AdminSystemStats(
        totalUsers: totalUsers,
        activeUsers: activeUsers,
        inactiveUsers: totalUsers - activeUsers,
        activeSessions: 42, // Mock data
        totalRANSites: 150,
        totalCOREElements: 85,
        totalIPNodes: 120,
        criticalAlarms: 8,
        majorAlarms: 23,
        minorAlarms: 45,
        systemUptime: 99.87,
        cpuUsage: 45.3,
        memoryUsage: 62.8,
        diskUsage: 38.5,
        totalNetworkElements: 355,
      );
    } catch (e) {
      debugPrint('Error loading system stats: $e');
    }
  }

  Future<void> _loadRoleDistribution() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();

      int adminCount = 0;
      int ranCount = 0;
      int coreCount = 0;
      int ipCount = 0;
      int nocCount = 0;

      for (var doc in usersSnapshot.docs) {
        final role = doc.data()['role'] as String?;
        switch (role) {
          case 'ADMIN':
            adminCount++;
            break;
          case 'RAN_ENGINEER':
            ranCount++;
            break;
          case 'CORE_ENGINEER':
            coreCount++;
            break;
          case 'IP_ENGINEER':
            ipCount++;
            break;
          case 'NOC_MANAGER':
            nocCount++;
            break;
        }
      }

      _roleDistribution = UserRoleDistribution(
        adminCount: adminCount,
        ranEngineerCount: ranCount,
        coreEngineerCount: coreCount,
        ipEngineerCount: ipCount,
        nocManagerCount: nocCount,
      );
    } catch (e) {
      debugPrint('Error loading role distribution: $e');
    }
  }

  Future<void> _loadDomainStats() async {
    // Mock data for domain statistics
    _domainStats = [
      NetworkDomainStats(
        domain: 'RAN',
        totalElements: 150,
        activeElements: 142,
        inactiveElements: 8,
        alarms: 23,
      ),
      NetworkDomainStats(
        domain: 'CORE',
        totalElements: 85,
        activeElements: 82,
        inactiveElements: 3,
        alarms: 12,
      ),
      NetworkDomainStats(
        domain: 'IP Transport',
        totalElements: 120,
        activeElements: 115,
        inactiveElements: 5,
        alarms: 18,
      ),
    ];
  }

  Future<void> _loadRecentActivities() async {
    try {
      final activitiesSnapshot = await _firestore
          .collection('activity_logs')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      _recentActivities = activitiesSnapshot.docs
          .map((doc) => AdminActivityLog.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error loading recent activities: $e');
      // Provide mock data if Firestore collection doesn't exist
      _recentActivities = [];
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    await loadDashboardStats();
  }

  // Log activity
  Future<void> logActivity({
    required String userId,
    required String userName,
    required String action,
    required String description,
    String? ipAddress,
  }) async {
    try {
      await _firestore.collection('activity_logs').add({
        'userId': userId,
        'userName': userName,
        'action': action,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'ipAddress': ipAddress ?? 'Unknown',
      });
    } catch (e) {
      debugPrint('Error logging activity: $e');
    }
  }
}
