import 'package:flutter/material.dart';
import 'dart:async';
import '../model/noc_alarm_model.dart';
import '../model/alarm_severity.dart';
import '../model/alarm_status.dart';
import '../model/alarm_domain.dart';
import '../model/alarm_statistics_model.dart';

class NOCController with ChangeNotifier {
  List<NOCAlarm> _alarms = [];
  AlarmStatistics? _statistics;
  bool _isLoading = false;

  // Filters
  AlarmDomain? _filterDomain;
  AlarmSeverity? _filterSeverity;
  AlarmStatus? _filterStatus;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String _searchQuery = '';

  List<NOCAlarm> get alarms => _getFilteredAlarms();
  AlarmStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;

  AlarmDomain? get filterDomain => _filterDomain;
  AlarmSeverity? get filterSeverity => _filterSeverity;
  AlarmStatus? get filterStatus => _filterStatus;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;
  String get searchQuery => _searchQuery;

  List<NOCAlarm> get criticalAlarms => _alarms
      .where(
        (a) =>
            a.severity == AlarmSeverity.critical &&
            a.status == AlarmStatus.active,
      )
      .toList();

  List<NOCAlarm> get majorAlarms => _alarms
      .where(
        (a) =>
            a.severity == AlarmSeverity.major && a.status == AlarmStatus.active,
      )
      .toList();

  List<NOCAlarm> get minorAlarms => _alarms
      .where(
        (a) =>
            a.severity == AlarmSeverity.minor && a.status == AlarmStatus.active,
      )
      .toList();

  NOCController() {
    _loadInitialData();
  }

  void _loadInitialData() {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 500), () {
      _alarms = _generateMockAlarms();
      _statistics = _generateMockStatistics();
      _isLoading = false;
      notifyListeners();
    });
  }

  void refresh() {
    _loadInitialData();
  }

  List<NOCAlarm> _getFilteredAlarms() {
    List<NOCAlarm> filtered = List.from(_alarms);

    if (_filterDomain != null) {
      filtered = filtered.where((a) => a.domain == _filterDomain).toList();
    }

    if (_filterSeverity != null) {
      filtered = filtered.where((a) => a.severity == _filterSeverity).toList();
    }

    if (_filterStatus != null) {
      filtered = filtered.where((a) => a.status == _filterStatus).toList();
    }

    if (_filterStartDate != null) {
      filtered = filtered
          .where((a) => a.timestamp.isAfter(_filterStartDate!))
          .toList();
    }

    if (_filterEndDate != null) {
      filtered = filtered
          .where((a) => a.timestamp.isBefore(_filterEndDate!))
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (a) =>
                a.element.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                a.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // Sort by severity priority and timestamp
    filtered.sort((a, b) {
      final severityCompare = b.severity.priority.compareTo(
        a.severity.priority,
      );
      if (severityCompare != 0) return severityCompare;
      return b.timestamp.compareTo(a.timestamp);
    });

    return filtered;
  }

  void setFilterDomain(AlarmDomain? domain) {
    _filterDomain = domain;
    notifyListeners();
  }

  void setFilterSeverity(AlarmSeverity? severity) {
    _filterSeverity = severity;
    notifyListeners();
  }

  void setFilterStatus(AlarmStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setFilterDateRange(DateTime? start, DateTime? end) {
    _filterStartDate = start;
    _filterEndDate = end;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _filterDomain = null;
    _filterSeverity = null;
    _filterStatus = null;
    _filterStartDate = null;
    _filterEndDate = null;
    _searchQuery = '';
    notifyListeners();
  }

  void acknowledgeAlarm(String alarmId, String user) {
    final index = _alarms.indexWhere((a) => a.id == alarmId);
    if (index != -1) {
      _alarms[index] = _alarms[index].copyWith(
        status: AlarmStatus.acknowledged,
        acknowledgedAt: DateTime.now(),
        acknowledgedBy: user,
      );
      _updateStatistics();
      notifyListeners();
    }
  }

  void assignAlarm(String alarmId, String engineer) {
    final index = _alarms.indexWhere((a) => a.id == alarmId);
    if (index != -1) {
      _alarms[index] = _alarms[index].copyWith(
        assignedTo: engineer,
        status: AlarmStatus.inProgress,
      );
      notifyListeners();
    }
  }

  void resolveAlarm(String alarmId, String user) {
    final index = _alarms.indexWhere((a) => a.id == alarmId);
    if (index != -1) {
      _alarms[index] = _alarms[index].copyWith(
        status: AlarmStatus.resolved,
        resolvedAt: DateTime.now(),
        resolvedBy: user,
      );
      _updateStatistics();
      notifyListeners();
    }
  }

  void addComment(String alarmId, String user, String comment) {
    final index = _alarms.indexWhere((a) => a.id == alarmId);
    if (index != -1) {
      final newComment = AlarmComment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        user: user,
        comment: comment,
      );
      final updatedComments = List<AlarmComment>.from(_alarms[index].comments)
        ..add(newComment);
      _alarms[index] = _alarms[index].copyWith(comments: updatedComments);
      notifyListeners();
    }
  }

  void bulkAcknowledge(List<String> alarmIds, String user) {
    for (var id in alarmIds) {
      acknowledgeAlarm(id, user);
    }
  }

  void bulkAssign(List<String> alarmIds, String engineer) {
    for (var id in alarmIds) {
      assignAlarm(id, engineer);
    }
  }

  void _updateStatistics() {
    _statistics = _generateMockStatistics();
  }

  List<NOCAlarm> _generateMockAlarms() {
    final now = DateTime.now();
    return [
      // Critical Alarms
      NOCAlarm(
        id: 'ALM001',
        timestamp: now.subtract(const Duration(minutes: 5)),
        domain: AlarmDomain.core,
        severity: AlarmSeverity.critical,
        element: 'MME-Core-01',
        description: 'MME service down - All LTE connections lost',
        status: AlarmStatus.active,
        impact: 'High - 15000 users affected',
        affectedServices: ['Voice', 'Data', 'SMS'],
      ),
      NOCAlarm(
        id: 'ALM002',
        timestamp: now.subtract(const Duration(minutes: 12)),
        domain: AlarmDomain.ran,
        severity: AlarmSeverity.critical,
        element: 'eNodeB-Site-42',
        description: 'Cell site power failure - Complete outage',
        status: AlarmStatus.active,
        impact: 'High - Site offline',
        affectedServices: ['RAN Coverage'],
      ),
      NOCAlarm(
        id: 'ALM003',
        timestamp: now.subtract(const Duration(minutes: 18)),
        domain: AlarmDomain.ip,
        severity: AlarmSeverity.critical,
        element: 'Core-Router-01',
        description: 'Core router link down - Network partition detected',
        status: AlarmStatus.acknowledged,
        acknowledgedAt: now.subtract(const Duration(minutes: 15)),
        acknowledgedBy: 'John Smith',
        assignedTo: 'John Smith',
        impact: 'Critical - Network split',
        affectedServices: ['IP Transport', 'Routing'],
      ),

      // Major Alarms
      NOCAlarm(
        id: 'ALM004',
        timestamp: now.subtract(const Duration(minutes: 25)),
        domain: AlarmDomain.core,
        severity: AlarmSeverity.major,
        element: 'HSS-Database-02',
        description: 'Database replication lag exceeding threshold',
        status: AlarmStatus.inProgress,
        assignedTo: 'Sarah Johnson',
        impact: 'Medium - Performance degraded',
        affectedServices: ['Subscriber Management'],
      ),
      NOCAlarm(
        id: 'ALM005',
        timestamp: now.subtract(const Duration(minutes: 32)),
        domain: AlarmDomain.ran,
        severity: AlarmSeverity.major,
        element: 'eNodeB-Site-15',
        description: 'High call drop rate - Interference detected',
        status: AlarmStatus.acknowledged,
        acknowledgedAt: now.subtract(const Duration(minutes: 28)),
        acknowledgedBy: 'Mike Chen',
        impact: 'Medium - Quality issues',
        affectedServices: ['Voice Quality'],
      ),
      NOCAlarm(
        id: 'ALM006',
        timestamp: now.subtract(const Duration(hours: 1)),
        domain: AlarmDomain.ip,
        severity: AlarmSeverity.major,
        element: 'Edge-Router-03',
        description: 'High CPU utilization - 92% sustained',
        status: AlarmStatus.active,
        impact: 'Medium - Performance impact',
        affectedServices: ['Routing Performance'],
      ),
      NOCAlarm(
        id: 'ALM007',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 15)),
        domain: AlarmDomain.transport,
        severity: AlarmSeverity.major,
        element: 'OTN-Link-05',
        description: 'Fiber link degradation - High BER',
        status: AlarmStatus.active,
        impact: 'Medium - Link quality',
        affectedServices: ['Transport Capacity'],
      ),

      // Minor Alarms
      NOCAlarm(
        id: 'ALM008',
        timestamp: now.subtract(const Duration(hours: 2)),
        domain: AlarmDomain.ran,
        severity: AlarmSeverity.minor,
        element: 'eNodeB-Site-23',
        description: 'VSWR alarm - Antenna performance degraded',
        status: AlarmStatus.active,
        impact: 'Low - Minor coverage impact',
        affectedServices: ['Coverage'],
      ),
      NOCAlarm(
        id: 'ALM009',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 30)),
        domain: AlarmDomain.core,
        severity: AlarmSeverity.minor,
        element: 'PGW-Gateway-01',
        description: 'Memory utilization warning - 78%',
        status: AlarmStatus.acknowledged,
        acknowledgedAt: now.subtract(const Duration(hours: 2, minutes: 20)),
        acknowledgedBy: 'Lisa Wong',
        impact: 'Low - Monitoring',
        affectedServices: ['Gateway Performance'],
      ),
      NOCAlarm(
        id: 'ALM010',
        timestamp: now.subtract(const Duration(hours: 3)),
        domain: AlarmDomain.ip,
        severity: AlarmSeverity.minor,
        element: 'Access-SW-08',
        description: 'Port flapping detected on interface Gi0/12',
        status: AlarmStatus.active,
        impact: 'Low - Single port',
        affectedServices: ['Access Network'],
      ),

      // Warning Alarms
      NOCAlarm(
        id: 'ALM011',
        timestamp: now.subtract(const Duration(hours: 4)),
        domain: AlarmDomain.core,
        severity: AlarmSeverity.warning,
        element: 'PCRF-Server-02',
        description: 'Disk space warning - 85% used',
        status: AlarmStatus.active,
        impact: 'Low - Preventive',
        affectedServices: ['Policy Control'],
      ),
      NOCAlarm(
        id: 'ALM012',
        timestamp: now.subtract(const Duration(hours: 5)),
        domain: AlarmDomain.ran,
        severity: AlarmSeverity.warning,
        element: 'eNodeB-Site-67',
        description: 'Temperature warning - Cooling system alert',
        status: AlarmStatus.resolved,
        resolvedAt: now.subtract(const Duration(hours: 4, minutes: 30)),
        resolvedBy: 'Tom Anderson',
        impact: 'Low - Environmental',
        affectedServices: ['Site Environment'],
      ),

      // More historical alarms for statistics
      NOCAlarm(
        id: 'ALM013',
        timestamp: now.subtract(const Duration(hours: 6)),
        domain: AlarmDomain.security,
        severity: AlarmSeverity.major,
        element: 'Firewall-DMZ-01',
        description:
            'Intrusion attempt detected - Multiple failed login attempts',
        status: AlarmStatus.resolved,
        resolvedAt: now.subtract(const Duration(hours: 5, minutes: 45)),
        resolvedBy: 'Security Team',
        impact: 'Medium - Security threat',
        affectedServices: ['Network Security'],
      ),
      NOCAlarm(
        id: 'ALM014',
        timestamp: now.subtract(const Duration(hours: 8)),
        domain: AlarmDomain.application,
        severity: AlarmSeverity.minor,
        element: 'VoLTE-App-Server',
        description: 'API response time degradation',
        status: AlarmStatus.resolved,
        resolvedAt: now.subtract(const Duration(hours: 7, minutes: 30)),
        resolvedBy: 'App Team',
        impact: 'Low - Performance',
        affectedServices: ['VoLTE Services'],
      ),
      NOCAlarm(
        id: 'ALM015',
        timestamp: now.subtract(const Duration(hours: 12)),
        domain: AlarmDomain.core,
        severity: AlarmSeverity.critical,
        element: 'SGW-Gateway-03',
        description: 'Gateway overload - Packet loss detected',
        status: AlarmStatus.resolved,
        resolvedAt: now.subtract(const Duration(hours: 11)),
        resolvedBy: 'Network Team',
        impact: 'High - Service impact',
        affectedServices: ['Data Services'],
      ),
    ];
  }

  AlarmStatistics _generateMockStatistics() {
    final activeAlarms = _alarms
        .where((a) => a.status == AlarmStatus.active)
        .length;
    final acknowledgedAlarms = _alarms
        .where(
          (a) =>
              a.status == AlarmStatus.acknowledged ||
              a.status == AlarmStatus.inProgress,
        )
        .length;
    final resolvedAlarms = _alarms
        .where((a) => a.status == AlarmStatus.resolved)
        .length;

    final byDomain = <AlarmDomain, int>{};
    for (var domain in AlarmDomain.values) {
      byDomain[domain] = _alarms
          .where((a) => a.domain == domain && a.status != AlarmStatus.resolved)
          .length;
    }

    final bySeverity = <AlarmSeverity, int>{};
    for (var severity in AlarmSeverity.values) {
      bySeverity[severity] = _alarms
          .where(
            (a) => a.severity == severity && a.status != AlarmStatus.resolved,
          )
          .length;
    }

    final now = DateTime.now();
    final trends = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return DailyAlarmTrend(
        date: date,
        critical: 2 + (index % 3),
        major: 4 + (index % 4),
        minor: 6 + (index % 5),
        warning: 3 + (index % 2),
      );
    });

    final topElements = [
      TopAffectedElement(
        elementName: 'eNodeB-Site-42',
        alarmCount: 8,
        domain: AlarmDomain.ran,
      ),
      TopAffectedElement(
        elementName: 'MME-Core-01',
        alarmCount: 6,
        domain: AlarmDomain.core,
      ),
      TopAffectedElement(
        elementName: 'Core-Router-01',
        alarmCount: 5,
        domain: AlarmDomain.ip,
      ),
      TopAffectedElement(
        elementName: 'HSS-Database-02',
        alarmCount: 4,
        domain: AlarmDomain.core,
      ),
      TopAffectedElement(
        elementName: 'Edge-Router-03',
        alarmCount: 3,
        domain: AlarmDomain.ip,
      ),
    ];

    return AlarmStatistics(
      totalActive: activeAlarms,
      totalAcknowledged: acknowledgedAlarms,
      totalResolved: resolvedAlarms,
      byDomain: byDomain,
      bySeverity: bySeverity,
      trends: trends,
      avgAcknowledgeTime: 8.5,
      avgResolveTime: 45.2,
      topElements: topElements,
    );
  }
}
