import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../model/bts_model.dart';
import '../model/alert_model.dart';

class RANController extends ChangeNotifier {
  List<BTSModel> _btsList = [];
  List<AlertModel> _alertsList = [];
  List<BTSMetricData> _metricsHistory = [];

  bool _isLoading = false;
  String? _selectedBTSId;
  Timer? _updateTimer;

  // Getters
  List<BTSModel> get btsList => _btsList;
  List<AlertModel> get alertsList => _alertsList;
  List<BTSMetricData> get metricsHistory => _metricsHistory;
  bool get isLoading => _isLoading;
  String? get selectedBTSId => _selectedBTSId;

  BTSModel? get selectedBTS {
    if (_selectedBTSId == null) return null;
    try {
      return _btsList.firstWhere((bts) => bts.id == _selectedBTSId);
    } catch (e) {
      return null;
    }
  }

  // Statistics
  int get totalBTS => _btsList.length;
  int get activeBTS =>
      _btsList.where((bts) => bts.status == BTSStatus.active).length;
  int get inactiveBTS =>
      _btsList.where((bts) => bts.status == BTSStatus.inactive).length;
  int get degradedBTS =>
      _btsList.where((bts) => bts.status == BTSStatus.degraded).length;

  double get averageSignalQuality {
    if (_btsList.isEmpty) return 0;
    final activeBTSList = _btsList
        .where((bts) => bts.status == BTSStatus.active)
        .toList();
    if (activeBTSList.isEmpty) return 0;
    return activeBTSList.map((bts) => bts.rsrp).reduce((a, b) => a + b) /
        activeBTSList.length;
  }

  double get averageCapacityUtilization {
    if (_btsList.isEmpty) return 0;
    return _btsList
            .map((bts) => bts.capacityUtilization)
            .reduce((a, b) => a + b) /
        _btsList.length;
  }

  int get criticalAlerts => _alertsList
      .where(
        (alert) =>
            alert.severity == AlertSeverity.critical &&
            alert.status == AlertStatus.active,
      )
      .length;

  int get majorAlerts => _alertsList
      .where(
        (alert) =>
            alert.severity == AlertSeverity.major &&
            alert.status == AlertStatus.active,
      )
      .length;

  int get minorAlerts => _alertsList
      .where(
        (alert) =>
            alert.severity == AlertSeverity.minor &&
            alert.status == AlertStatus.active,
      )
      .length;

  int get warningAlerts => _alertsList
      .where(
        (alert) =>
            alert.severity == AlertSeverity.warning &&
            alert.status == AlertStatus.active,
      )
      .length;

  // Initialize with static data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _btsList = _generateStaticBTSData();
    _alertsList = _generateStaticAlerts();
    _metricsHistory = _generateMetricsHistory();

    _isLoading = false;
    notifyListeners();

    // Start real-time updates
    _startRealTimeUpdates();
  }

  // Generate static BTS data
  List<BTSModel> _generateStaticBTSData() {
    final Random random = Random();
    final List<BTSModel> btsList = [];

    final cities = [
      'Mumbai',
      'Delhi',
      'Bangalore',
      'Hyderabad',
      'Chennai',
      'Kolkata',
      'Pune',
      'Ahmedabad',
    ];
    final regions = ['North', 'South', 'East', 'West', 'Central'];
    final technologies = ['4G', '5G'];

    // Base coordinates for Indian cities
    final cityCoordinates = {
      'Mumbai': {'lat': 19.0760, 'lng': 72.8777},
      'Delhi': {'lat': 28.7041, 'lng': 77.1025},
      'Bangalore': {'lat': 12.9716, 'lng': 77.5946},
      'Hyderabad': {'lat': 17.3850, 'lng': 78.4867},
      'Chennai': {'lat': 13.0827, 'lng': 80.2707},
      'Kolkata': {'lat': 22.5726, 'lng': 88.3639},
      'Pune': {'lat': 18.5204, 'lng': 73.8567},
      'Ahmedabad': {'lat': 23.0225, 'lng': 72.5714},
    };

    for (int i = 0; i < 45; i++) {
      final city = cities[random.nextInt(cities.length)];
      final baseCoords = cityCoordinates[city]!;

      // Add some random offset to create multiple towers in same city
      final lat = baseCoords['lat']! + (random.nextDouble() - 0.5) * 0.1;
      final lng = baseCoords['lng']! + (random.nextDouble() - 0.5) * 0.1;

      final status = _randomStatus(random);
      final tech = technologies[random.nextInt(technologies.length)];

      btsList.add(
        BTSModel(
          id: 'BTS-${(i + 1).toString().padLeft(4, '0')}',
          name: 'Tower ${i + 1}',
          latitude: lat,
          longitude: lng,
          location: '${city} Sector ${random.nextInt(20) + 1}',
          city: city,
          region: regions[random.nextInt(regions.length)],
          status: status,
          rsrp: status == BTSStatus.inactive
              ? -120.0
              : -65.0 - random.nextDouble() * 30,
          rsrq: status == BTSStatus.inactive
              ? -20.0
              : -5.0 - random.nextDouble() * 12,
          sinr: status == BTSStatus.inactive
              ? -10.0
              : 5.0 + random.nextDouble() * 20,
          capacityUtilization: status == BTSStatus.inactive
              ? 0.0
              : random.nextDouble() * 100,
          activeUsers: status == BTSStatus.inactive ? 0 : random.nextInt(500),
          maxCapacity: 1000,
          lastUpdated: DateTime.now().subtract(
            Duration(seconds: random.nextInt(300)),
          ),
          alerts: _generateRandomAlerts(random, status),
          technology: tech,
          frequency: tech == '5G' ? 3500 : 1800,
          bandwidth: tech == '5G' ? 100.0 : 20.0,
          txPower: 40.0 + random.nextDouble() * 6,
        ),
      );
    }

    return btsList;
  }

  BTSStatus _randomStatus(Random random) {
    final rand = random.nextInt(100);
    if (rand < 70) return BTSStatus.active;
    if (rand < 80) return BTSStatus.degraded;
    if (rand < 90) return BTSStatus.inactive;
    return BTSStatus.maintenance;
  }

  List<String> _generateRandomAlerts(Random random, BTSStatus status) {
    final List<String> alerts = [];
    if (status == BTSStatus.inactive) {
      alerts.add('BTS Down');
    } else if (status == BTSStatus.degraded) {
      if (random.nextBool()) alerts.add('Signal Degradation');
      if (random.nextBool()) alerts.add('High Interference');
    }
    return alerts;
  }

  // Generate static alerts
  List<AlertModel> _generateStaticAlerts() {
    final List<AlertModel> alerts = [];
    final Random random = Random();

    final alertTypes = [
      {
        'type': 'BTS_DOWN',
        'title': 'BTS Tower Down',
        'severity': AlertSeverity.critical,
      },
      {
        'type': 'SIGNAL_DEGRADATION',
        'title': 'Signal Quality Degraded',
        'severity': AlertSeverity.major,
      },
      {
        'type': 'CAPACITY_EXCEEDED',
        'title': 'Capacity Threshold Exceeded',
        'severity': AlertSeverity.major,
      },
      {
        'type': 'HIGH_INTERFERENCE',
        'title': 'High Interference Detected',
        'severity': AlertSeverity.warning,
      },
      {
        'type': 'LOW_RSRP',
        'title': 'Low RSRP Values',
        'severity': AlertSeverity.warning,
      },
      {
        'type': 'MAINTENANCE_REQUIRED',
        'title': 'Maintenance Required',
        'severity': AlertSeverity.minor,
      },
    ];

    int alertId = 1;
    for (var bts in _btsList) {
      if (bts.status == BTSStatus.inactive) {
        alerts.add(
          AlertModel(
            id: 'ALERT-${alertId++}',
            btsId: bts.id,
            btsName: bts.name,
            title: 'BTS Tower Down',
            description:
                'Critical failure detected. Tower ${bts.name} at ${bts.location} is not responding.',
            severity: AlertSeverity.critical,
            status: AlertStatus.active,
            timestamp: DateTime.now().subtract(
              Duration(minutes: random.nextInt(120)),
            ),
            location: bts.location,
            alertType: 'BTS_DOWN',
            metadata: {'rsrp': bts.rsrp, 'city': bts.city},
          ),
        );
      } else if (bts.status == BTSStatus.degraded) {
        final alertType = alertTypes[1 + random.nextInt(alertTypes.length - 1)];
        alerts.add(
          AlertModel(
            id: 'ALERT-${alertId++}',
            btsId: bts.id,
            btsName: bts.name,
            title: alertType['title'] as String,
            description: 'Performance degradation detected at ${bts.location}',
            severity: alertType['severity'] as AlertSeverity,
            status: AlertStatus.active,
            timestamp: DateTime.now().subtract(
              Duration(minutes: random.nextInt(60)),
            ),
            location: bts.location,
            alertType: alertType['type'] as String,
            metadata: {'rsrp': bts.rsrp, 'rsrq': bts.rsrq, 'sinr': bts.sinr},
          ),
        );
      } else if (bts.capacityUtilization > 85) {
        alerts.add(
          AlertModel(
            id: 'ALERT-${alertId++}',
            btsId: bts.id,
            btsName: bts.name,
            title: 'High Capacity Utilization',
            description:
                'Capacity at ${bts.capacityUtilization.toStringAsFixed(1)}% for ${bts.location}',
            severity: AlertSeverity.warning,
            status: AlertStatus.active,
            timestamp: DateTime.now().subtract(
              Duration(minutes: random.nextInt(30)),
            ),
            location: bts.location,
            alertType: 'CAPACITY_EXCEEDED',
            metadata: {'capacity': bts.capacityUtilization},
          ),
        );
      }
    }

    // Add some resolved alerts
    for (int i = 0; i < 5; i++) {
      final bts = _btsList[random.nextInt(_btsList.length)];
      final alertType = alertTypes[random.nextInt(alertTypes.length)];
      alerts.add(
        AlertModel(
          id: 'ALERT-${alertId++}',
          btsId: bts.id,
          btsName: bts.name,
          title: alertType['title'] as String,
          description:
              'Issue was detected and has been resolved at ${bts.location}',
          severity: alertType['severity'] as AlertSeverity,
          status: AlertStatus.resolved,
          timestamp: DateTime.now().subtract(
            Duration(hours: random.nextInt(48)),
          ),
          resolvedAt: DateTime.now().subtract(
            Duration(hours: random.nextInt(24)),
          ),
          resolvedBy: 'System Admin',
          location: bts.location,
          alertType: alertType['type'] as String,
          metadata: {},
        ),
      );
    }

    return alerts..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Generate metrics history for charts
  List<BTSMetricData> _generateMetricsHistory() {
    final List<BTSMetricData> history = [];
    final Random random = Random();
    final now = DateTime.now();

    // Generate last 24 hours of data (every 5 minutes)
    for (int i = 288; i >= 0; i--) {
      history.add(
        BTSMetricData(
          timestamp: now.subtract(Duration(minutes: i * 5)),
          rsrp: -70.0 - random.nextDouble() * 15 + (i % 24) * 0.5,
          rsrq: -8.0 - random.nextDouble() * 6,
          sinr: 15.0 + random.nextDouble() * 10,
          capacity: 60.0 + random.nextDouble() * 30 + (i % 12) * 2,
        ),
      );
    }

    return history;
  }

  // Start real-time updates simulation
  void _startRealTimeUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _simulateRealTimeUpdates();
    });
  }

  // Simulate real-time metric updates
  void _simulateRealTimeUpdates() {
    final Random random = Random();

    // Update random BTS metrics
    for (var i = 0; i < _btsList.length; i++) {
      if (random.nextInt(10) < 3) {
        // 30% chance to update
        final bts = _btsList[i];
        if (bts.status == BTSStatus.active) {
          _btsList[i] = bts.copyWith(
            rsrp: max(
              -120.0,
              min(-44.0, bts.rsrp + (random.nextDouble() - 0.5) * 2),
            ),
            rsrq: max(
              -20.0,
              min(-3.0, bts.rsrq + (random.nextDouble() - 0.5) * 0.5),
            ),
            sinr: max(
              -10.0,
              min(30.0, bts.sinr + (random.nextDouble() - 0.5) * 2),
            ),
            capacityUtilization: max(
              0.0,
              min(
                100.0,
                bts.capacityUtilization + (random.nextDouble() - 0.5) * 5,
              ),
            ),
            lastUpdated: DateTime.now(),
          );
        }
      }
    }

    // Add new metric to history
    final activeBTS = _btsList
        .where((b) => b.status == BTSStatus.active)
        .toList();
    if (activeBTS.isNotEmpty) {
      final avgRsrp =
          activeBTS.map((b) => b.rsrp).reduce((a, b) => a + b) /
          activeBTS.length;
      final avgRsrq =
          activeBTS.map((b) => b.rsrq).reduce((a, b) => a + b) /
          activeBTS.length;
      final avgSinr =
          activeBTS.map((b) => b.sinr).reduce((a, b) => a + b) /
          activeBTS.length;
      final avgCapacity =
          _btsList.map((b) => b.capacityUtilization).reduce((a, b) => a + b) /
          _btsList.length;

      _metricsHistory.add(
        BTSMetricData(
          timestamp: DateTime.now(),
          rsrp: avgRsrp,
          rsrq: avgRsrq,
          sinr: avgSinr,
          capacity: avgCapacity,
        ),
      );

      // Keep only last 24 hours
      if (_metricsHistory.length > 288) {
        _metricsHistory.removeAt(0);
      }
    }

    notifyListeners();
  }

  // Filter methods
  List<BTSModel> filterByCity(String city) {
    return _btsList.where((bts) => bts.city == city).toList();
  }

  List<BTSModel> filterByRegion(String region) {
    return _btsList.where((bts) => bts.region == region).toList();
  }

  List<BTSModel> filterByStatus(BTSStatus status) {
    return _btsList.where((bts) => bts.status == status).toList();
  }

  List<AlertModel> filterAlertsBySeverity(AlertSeverity severity) {
    return _alertsList.where((alert) => alert.severity == severity).toList();
  }

  List<AlertModel> getActiveAlerts() {
    return _alertsList
        .where((alert) => alert.status == AlertStatus.active)
        .toList();
  }

  // Select BTS
  void selectBTS(String? btsId) {
    _selectedBTSId = btsId;
    notifyListeners();
  }

  // Acknowledge alert
  void acknowledgeAlert(String alertId, String userName) {
    final index = _alertsList.indexWhere((alert) => alert.id == alertId);
    if (index != -1) {
      _alertsList[index] = _alertsList[index].copyWith(
        status: AlertStatus.acknowledged,
        acknowledgedAt: DateTime.now(),
        acknowledgedBy: userName,
      );
      notifyListeners();
    }
  }

  // Resolve alert
  void resolveAlert(String alertId, String userName) {
    final index = _alertsList.indexWhere((alert) => alert.id == alertId);
    if (index != -1) {
      _alertsList[index] = _alertsList[index].copyWith(
        status: AlertStatus.resolved,
        resolvedAt: DateTime.now(),
        resolvedBy: userName,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
