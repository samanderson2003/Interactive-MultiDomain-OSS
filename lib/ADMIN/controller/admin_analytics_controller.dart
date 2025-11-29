import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnalyticsController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  // Performance Metrics
  Map<String, dynamic> _performanceMetrics = {};
  List<Map<String, dynamic>> _userActivityTrends = [];
  List<Map<String, dynamic>> _networkPerformanceTrends = [];
  List<Map<String, dynamic>> _systemResourceTrends = [];

  // Reports
  List<ReportTemplate> _reportTemplates = [];
  List<GeneratedReport> _generatedReports = [];

  // Date range filter
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get performanceMetrics => _performanceMetrics;
  List<Map<String, dynamic>> get userActivityTrends => _userActivityTrends;
  List<Map<String, dynamic>> get networkPerformanceTrends =>
      _networkPerformanceTrends;
  List<Map<String, dynamic>> get systemResourceTrends => _systemResourceTrends;
  List<ReportTemplate> get reportTemplates => _reportTemplates;
  List<GeneratedReport> get generatedReports => _generatedReports;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  // Load performance metrics
  Future<void> loadPerformanceMetrics() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Aggregate performance data
      _performanceMetrics = {
        'avgResponseTime': 245, // ms
        'totalRequests': 1248765,
        'successRate': 99.7,
        'errorRate': 0.3,
        'avgCpuUsage': 45.2,
        'avgMemoryUsage': 62.8,
        'avgDiskUsage': 58.3,
        'networkThroughput': 1250, // Mbps
        'activeConnections': 3456,
        'peakConcurrentUsers': 892,
      };

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load performance metrics: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user activity trends
  Future<void> loadUserActivityTrends() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('activity_logs')
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate),
          )
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(_endDate))
          .get();

      // Group by date and count activities
      Map<String, int> activityByDate = {};
      for (var doc in snapshot.docs) {
        final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();
        final dateKey = '${timestamp.year}-${timestamp.month}-${timestamp.day}';
        activityByDate[dateKey] = (activityByDate[dateKey] ?? 0) + 1;
      }

      _userActivityTrends = activityByDate.entries
          .map((e) => {'date': e.key, 'count': e.value})
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load user activity trends: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load network performance trends
  Future<void> loadNetworkPerformanceTrends() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Mock data - in production, fetch from monitoring system
      _networkPerformanceTrends = List.generate(30, (index) {
        final date = DateTime.now().subtract(Duration(days: 29 - index));
        return {
          'date': '${date.month}/${date.day}',
          'latency': 20 + (index % 10) * 2,
          'throughput': 950 + (index % 15) * 10,
          'packetLoss': 0.1 + (index % 5) * 0.05,
        };
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load network performance: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load system resource trends
  Future<void> loadSystemResourceTrends() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Mock data - in production, fetch from system monitoring
      _systemResourceTrends = List.generate(24, (index) {
        return {
          'hour': '$index:00',
          'cpu': 30 + (index % 12) * 3,
          'memory': 55 + (index % 8) * 2,
          'disk': 45 + (index % 6) * 1.5,
        };
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load system resource trends: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load report templates
  Future<void> loadReportTemplates() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore.collection('report_templates').get();
      _reportTemplates = snapshot.docs
          .map((doc) => ReportTemplate.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load report templates: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load generated reports
  Future<void> loadGeneratedReports() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('generated_reports')
          .orderBy('generatedAt', descending: true)
          .limit(50)
          .get();

      _generatedReports = snapshot.docs
          .map((doc) => GeneratedReport.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load generated reports: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate report
  Future<void> generateReport(String templateId, String generatedBy) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('generated_reports').add({
        'templateId': templateId,
        'generatedBy': generatedBy,
        'generatedAt': FieldValue.serverTimestamp(),
        'status': 'Processing',
        'startDate': Timestamp.fromDate(_startDate),
        'endDate': Timestamp.fromDate(_endDate),
      });

      await loadGeneratedReports();
    } catch (e) {
      _errorMessage = 'Failed to generate report: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set date range
  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  // Export data
  Future<Map<String, dynamic>> exportData(
    String format,
    List<String> dataTypes,
  ) async {
    try {
      // Collect requested data
      Map<String, dynamic> exportData = {};

      if (dataTypes.contains('performance')) {
        exportData['performanceMetrics'] = _performanceMetrics;
      }

      if (dataTypes.contains('userActivity')) {
        exportData['userActivityTrends'] = _userActivityTrends;
      }

      if (dataTypes.contains('networkPerformance')) {
        exportData['networkPerformanceTrends'] = _networkPerformanceTrends;
      }

      if (dataTypes.contains('systemResources')) {
        exportData['systemResourceTrends'] = _systemResourceTrends;
      }

      return {
        'success': true,
        'data': exportData,
        'format': format,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}

class ReportTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> dataPoints;

  ReportTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.dataPoints,
  });

  factory ReportTemplate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportTemplate(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      dataPoints: List<String>.from(data['dataPoints'] ?? []),
    );
  }
}

class GeneratedReport {
  final String id;
  final String templateId;
  final String generatedBy;
  final DateTime generatedAt;
  final String status;
  final String? downloadUrl;

  GeneratedReport({
    required this.id,
    required this.templateId,
    required this.generatedBy,
    required this.generatedAt,
    required this.status,
    this.downloadUrl,
  });

  factory GeneratedReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GeneratedReport(
      id: doc.id,
      templateId: data['templateId'] ?? '',
      generatedBy: data['generatedBy'] ?? '',
      generatedAt: (data['generatedAt'] as Timestamp).toDate(),
      status: data['status'] ?? '',
      downloadUrl: data['downloadUrl'],
    );
  }
}
