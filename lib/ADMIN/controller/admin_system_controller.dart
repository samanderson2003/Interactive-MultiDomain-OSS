import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSystemController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  // System Health
  Map<String, dynamic> _systemHealth = {};
  List<SystemService> _services = [];
  List<SystemLog> _systemLogs = [];
  Map<String, dynamic> _resourceUtilization = {};

  // Settings
  Map<String, dynamic> _systemSettings = {};
  List<Integration> _integrations = [];
  List<BackupRecord> _backupRecords = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get systemHealth => _systemHealth;
  List<SystemService> get services => _services;
  List<SystemLog> get systemLogs => _systemLogs;
  Map<String, dynamic> get resourceUtilization => _resourceUtilization;
  Map<String, dynamic> get systemSettings => _systemSettings;
  List<Integration> get integrations => _integrations;
  List<BackupRecord> get backupRecords => _backupRecords;

  // Load system health
  Future<void> loadSystemHealth() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _systemHealth = {
        'status': 'Healthy',
        'uptime': '45d 12h 34m',
        'lastRestart': DateTime.now().subtract(const Duration(days: 45)),
        'cpuUsage': 42.5,
        'memoryUsage': 68.3,
        'diskUsage': 54.7,
        'networkLatency': 23,
        'activeProcesses': 187,
        'queuedTasks': 12,
        'errorRate': 0.02,
      };

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load system health: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load services
  Future<void> loadServices() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore.collection('system_services').get();
      _services = snapshot.docs
          .map((doc) => SystemService.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load services: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load system logs
  Future<void> loadSystemLogs({int limit = 100}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('system_logs')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      _systemLogs = snapshot.docs
          .map((doc) => SystemLog.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load system logs: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load resource utilization
  Future<void> loadResourceUtilization() async {
    try {
      _isLoading = true;
      notifyListeners();

      _resourceUtilization = {
        'cpu': {
          'current': 42.5,
          'average': 38.2,
          'peak': 87.3,
          'trend': List.generate(24, (i) => 30 + (i % 12) * 4),
        },
        'memory': {
          'current': 68.3,
          'average': 65.7,
          'peak': 92.1,
          'total': 32768, // MB
          'used': 22363,
          'trend': List.generate(24, (i) => 60 + (i % 8) * 3),
        },
        'disk': {
          'current': 54.7,
          'total': 512000, // MB
          'used': 280064,
          'free': 231936,
        },
        'network': {
          'inbound': 125.4, // Mbps
          'outbound': 87.6,
          'totalBandwidth': 1000,
        },
      };

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load resource utilization: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load system settings
  Future<void> loadSystemSettings() async {
    try {
      _isLoading = true;
      notifyListeners();

      final doc = await _firestore
          .collection('system_settings')
          .doc('global')
          .get();
      _systemSettings = doc.data() ?? {};

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load system settings: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update system settings
  Future<void> updateSystemSettings(Map<String, dynamic> settings) async {
    try {
      await _firestore
          .collection('system_settings')
          .doc('global')
          .update(settings);
      _systemSettings.addAll(settings);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update system settings: $e';
      notifyListeners();
    }
  }

  // Load integrations
  Future<void> loadIntegrations() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore.collection('integrations').get();
      _integrations = snapshot.docs
          .map((doc) => Integration.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load integrations: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Test integration
  Future<bool> testIntegration(String integrationId) async {
    try {
      // Simulate integration test
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      _errorMessage = 'Integration test failed: $e';
      notifyListeners();
      return false;
    }
  }

  // Load backup records
  Future<void> loadBackupRecords() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('backup_records')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      _backupRecords = snapshot.docs
          .map((doc) => BackupRecord.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load backup records: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create backup
  Future<void> createBackup(String initiatedBy) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('backup_records').add({
        'initiatedBy': initiatedBy,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'In Progress',
        'type': 'Manual',
      });

      await loadBackupRecords();
    } catch (e) {
      _errorMessage = 'Failed to create backup: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Restart service
  Future<void> restartService(String serviceId) async {
    try {
      await _firestore.collection('system_services').doc(serviceId).update({
        'status': 'Restarting',
        'lastRestart': FieldValue.serverTimestamp(),
      });
      await loadServices();
    } catch (e) {
      _errorMessage = 'Failed to restart service: $e';
      notifyListeners();
    }
  }
}

class SystemService {
  final String id;
  final String name;
  final String status;
  final DateTime lastRestart;
  final double cpuUsage;
  final double memoryUsage;

  SystemService({
    required this.id,
    required this.name,
    required this.status,
    required this.lastRestart,
    required this.cpuUsage,
    required this.memoryUsage,
  });

  factory SystemService.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SystemService(
      id: doc.id,
      name: data['name'] ?? '',
      status: data['status'] ?? '',
      lastRestart: (data['lastRestart'] as Timestamp).toDate(),
      cpuUsage: (data['cpuUsage'] ?? 0).toDouble(),
      memoryUsage: (data['memoryUsage'] ?? 0).toDouble(),
    );
  }
}

class SystemLog {
  final String id;
  final String level;
  final String source;
  final String message;
  final DateTime timestamp;

  SystemLog({
    required this.id,
    required this.level,
    required this.source,
    required this.message,
    required this.timestamp,
  });

  factory SystemLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SystemLog(
      id: doc.id,
      level: data['level'] ?? '',
      source: data['source'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

class Integration {
  final String id;
  final String name;
  final String type;
  final bool isActive;
  final DateTime lastSync;

  Integration({
    required this.id,
    required this.name,
    required this.type,
    required this.isActive,
    required this.lastSync,
  });

  factory Integration.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Integration(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      isActive: data['isActive'] ?? false,
      lastSync: (data['lastSync'] as Timestamp).toDate(),
    );
  }
}

class BackupRecord {
  final String id;
  final DateTime timestamp;
  final String status;
  final String type;
  final int? sizeBytes;

  BackupRecord({
    required this.id,
    required this.timestamp,
    required this.status,
    required this.type,
    this.sizeBytes,
  });

  factory BackupRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BackupRecord(
      id: doc.id,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: data['status'] ?? '',
      type: data['type'] ?? '',
      sizeBytes: data['sizeBytes'],
    );
  }
}
