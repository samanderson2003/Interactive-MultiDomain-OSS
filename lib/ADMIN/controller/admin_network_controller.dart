import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/admin_network_stats_model.dart';

class AdminNetworkController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;

  // Network Statistics
  List<NetworkElement> _networkElements = [];
  List<NetworkAlarm> _alarms = [];
  List<NetworkTopologyNode> _topologyNodes = [];
  NetworkDomainSummary? _domainSummary;

  // Filters
  String _searchQuery = '';
  String? _domainFilter;
  String? _statusFilter;
  String? _severityFilter;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<NetworkElement> get networkElements => _filteredElements;
  List<NetworkAlarm> get alarms => _filteredAlarms;
  List<NetworkTopologyNode> get topologyNodes => _topologyNodes;
  NetworkDomainSummary? get domainSummary => _domainSummary;

  // Filtered data
  List<NetworkElement> get _filteredElements {
    var filtered = _networkElements;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (element) =>
                element.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                element.ipAddress.contains(_searchQuery),
          )
          .toList();
    }

    if (_domainFilter != null) {
      filtered = filtered.where((e) => e.domain == _domainFilter).toList();
    }

    if (_statusFilter != null) {
      filtered = filtered.where((e) => e.status == _statusFilter).toList();
    }

    return filtered;
  }

  List<NetworkAlarm> get _filteredAlarms {
    var filtered = _alarms;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (alarm) =>
                alarm.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                alarm.source.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (_severityFilter != null) {
      filtered = filtered.where((a) => a.severity == _severityFilter).toList();
    }

    if (_domainFilter != null) {
      filtered = filtered.where((a) => a.domain == _domainFilter).toList();
    }

    return filtered;
  }

  // Load network elements
  Future<void> loadNetworkElements() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final snapshot = await _firestore.collection('network_elements').get();
      _networkElements = snapshot.docs
          .map((doc) => NetworkElement.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load network elements: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load alarms
  Future<void> loadAlarms() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('network_alarms')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      _alarms = snapshot.docs
          .map((doc) => NetworkAlarm.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load alarms: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load topology
  Future<void> loadTopology() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final snapshot = await _firestore.collection('network_topology').get();
      _topologyNodes = snapshot.docs
          .map((doc) => NetworkTopologyNode.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load topology: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load domain summary
  Future<void> loadDomainSummary() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Count elements by domain
      final ranCount = _networkElements.where((e) => e.domain == 'RAN').length;
      final coreCount = _networkElements
          .where((e) => e.domain == 'CORE')
          .length;
      final ipCount = _networkElements.where((e) => e.domain == 'IP').length;

      // Count alarms by severity
      final criticalAlarms = _alarms
          .where((a) => a.severity == 'Critical')
          .length;
      final majorAlarms = _alarms.where((a) => a.severity == 'Major').length;
      final minorAlarms = _alarms.where((a) => a.severity == 'Minor').length;

      _domainSummary = NetworkDomainSummary(
        ranElements: ranCount,
        coreElements: coreCount,
        ipElements: ipCount,
        totalElements: _networkElements.length,
        activeElements: _networkElements
            .where((e) => e.status == 'Active')
            .length,
        criticalAlarms: criticalAlarms,
        majorAlarms: majorAlarms,
        minorAlarms: minorAlarms,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load domain summary: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Acknowledge alarm
  Future<void> acknowledgeAlarm(String alarmId, String acknowledgedBy) async {
    try {
      await _firestore.collection('network_alarms').doc(alarmId).update({
        'status': 'Acknowledged',
        'acknowledgedBy': acknowledgedBy,
        'acknowledgedAt': FieldValue.serverTimestamp(),
      });

      final index = _alarms.indexWhere((a) => a.id == alarmId);
      if (index != -1) {
        _alarms[index] = _alarms[index].copyWith(
          status: 'Acknowledged',
          acknowledgedBy: acknowledgedBy,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to acknowledge alarm: $e';
      notifyListeners();
    }
  }

  // Clear alarm
  Future<void> clearAlarm(String alarmId, String clearedBy) async {
    try {
      await _firestore.collection('network_alarms').doc(alarmId).update({
        'status': 'Cleared',
        'clearedBy': clearedBy,
        'clearedAt': FieldValue.serverTimestamp(),
      });

      final index = _alarms.indexWhere((a) => a.id == alarmId);
      if (index != -1) {
        _alarms[index] = _alarms[index].copyWith(status: 'Cleared');
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to clear alarm: $e';
      notifyListeners();
    }
  }

  // Update network element
  Future<void> updateNetworkElement(
    String elementId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore
          .collection('network_elements')
          .doc(elementId)
          .update(updates);
      await loadNetworkElements();
    } catch (e) {
      _errorMessage = 'Failed to update network element: $e';
      notifyListeners();
    }
  }

  // Filters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setDomainFilter(String? domain) {
    _domainFilter = domain;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setSeverityFilter(String? severity) {
    _severityFilter = severity;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _domainFilter = null;
    _statusFilter = null;
    _severityFilter = null;
    notifyListeners();
  }
}
