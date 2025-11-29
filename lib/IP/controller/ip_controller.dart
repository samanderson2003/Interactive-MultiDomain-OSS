import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../model/router_node_model.dart';
import '../model/network_link_model.dart';
import '../model/link_status_model.dart';
import '../model/bandwidth_metrics_model.dart';
import '../model/threshold_alert_model.dart';

class IPController with ChangeNotifier {
  List<RouterNodeModel> _routers = [];
  List<NetworkLinkModel> _links = [];
  BandwidthMetricsModel? _metrics;
  List<ThresholdAlertModel> _alerts = [];
  bool _isLoading = false;
  Timer? _updateTimer;

  // Getters
  List<RouterNodeModel> get routers => _routers;
  List<NetworkLinkModel> get links => _links;
  BandwidthMetricsModel get metrics =>
      _metrics ?? BandwidthMetricsModel.empty();
  List<ThresholdAlertModel> get alerts => _alerts;
  bool get isLoading => _isLoading;

  // Filter getters
  List<NetworkLinkModel> get criticalLinks =>
      _links.where((link) => link.utilizationPercent >= 80).toList();
  List<NetworkLinkModel> get failedLinks =>
      _links.where((link) => link.status == LinkStatus.failed).toList();
  List<ThresholdAlertModel> get unacknowledgedAlerts =>
      _alerts.where((alert) => !alert.acknowledged).toList();

  IPController() {
    loadDashboardData();
    _startRealTimeUpdates();
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _routers = _generateMockRouters();
    _links = _generateMockLinks();
    _metrics = _generateMockMetrics();
    _alerts = _generateMockAlerts();

    _isLoading = false;
    notifyListeners();
  }

  void _startRealTimeUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateLinkUtilization();
      _updateMetrics();
      _checkForNewAlerts();
      notifyListeners();
    });
  }

  void _updateLinkUtilization() {
    final random = Random();
    for (int i = 0; i < _links.length; i++) {
      final currentUtil = _links[i].utilizationPercent;
      final change = (random.nextDouble() - 0.5) * 10;
      final newUtil = (currentUtil + change).clamp(5.0, 95.0);

      _links[i] = NetworkLinkModel(
        id: _links[i].id,
        fromNodeId: _links[i].fromNodeId,
        toNodeId: _links[i].toNodeId,
        fromNodeName: _links[i].fromNodeName,
        toNodeName: _links[i].toNodeName,
        capacityGbps: _links[i].capacityGbps,
        utilizationPercent: newUtil,
        status: newUtil >= 90 ? LinkStatus.degraded : _links[i].status,
        latencyMs: _links[i].latencyMs + (random.nextDouble() - 0.5),
        packetLossPercent: _links[i].packetLossPercent,
        lastUpdated: DateTime.now(),
      );
    }
  }

  void _updateMetrics() {
    if (_metrics == null) return;

    final random = Random();
    final currentUtil = _metrics!.currentUtilizationPercent;
    final newUtil = (currentUtil + (random.nextDouble() - 0.5) * 5).clamp(
      30.0,
      85.0,
    );

    final newDataPoint = BandwidthDataPoint(
      timestamp: DateTime.now(),
      utilizationPercent: newUtil,
    );

    final updatedHourlyData = [..._metrics!.hourlyData, newDataPoint];
    if (updatedHourlyData.length > 60) {
      updatedHourlyData.removeAt(0);
    }

    _metrics = BandwidthMetricsModel(
      totalCapacityGbps: _metrics!.totalCapacityGbps,
      currentUtilizationPercent: newUtil,
      availableBandwidthGbps:
          (_metrics!.totalCapacityGbps * (100 - newUtil) / 100).round(),
      peakUtilizationTime: _metrics!.peakUtilizationTime,
      peakUtilizationPercent: max(_metrics!.peakUtilizationPercent, newUtil),
      hourlyData: updatedHourlyData,
    );
  }

  void _checkForNewAlerts() {
    for (final link in _links) {
      if (link.utilizationPercent >= 80 &&
          !_alerts.any(
            (alert) =>
                alert.affectedLink == link.id &&
                alert.severity == AlertSeverity.warning,
          )) {
        _alerts.insert(
          0,
          ThresholdAlertModel(
            id: 'alert-${DateTime.now().millisecondsSinceEpoch}',
            title: 'High Utilization Detected',
            description:
                'Link ${link.fromNodeName} → ${link.toNodeName} is at ${link.utilizationPercent.toStringAsFixed(1)}% capacity',
            severity: AlertSeverity.warning,
            timestamp: DateTime.now(),
            affectedLink: link.id,
          ),
        );
      }
    }
  }

  void acknowledgeAlert(String alertId) {
    final index = _alerts.indexWhere((alert) => alert.id == alertId);
    if (index != -1) {
      _alerts[index] = ThresholdAlertModel(
        id: _alerts[index].id,
        title: _alerts[index].title,
        description: _alerts[index].description,
        severity: _alerts[index].severity,
        timestamp: _alerts[index].timestamp,
        affectedLink: _alerts[index].affectedLink,
        acknowledged: true,
      );
      notifyListeners();
    }
  }

  List<RouterNodeModel> _generateMockRouters() {
    return [
      // Core Routers (center)
      RouterNodeModel(
        id: 'core-01',
        name: 'Core-Router-01',
        type: RouterType.core,
        position: const Offset(400, 300),
        location: 'DataCenter-A',
        ipAddress: '10.0.1.1',
        connectedLinks: 8,
        utilization: 65.5,
        status: 'Operational',
        lastUpdated: DateTime.now(),
      ),
      RouterNodeModel(
        id: 'core-02',
        name: 'Core-Router-02',
        type: RouterType.core,
        position: const Offset(600, 300),
        location: 'DataCenter-B',
        ipAddress: '10.0.1.2',
        connectedLinks: 8,
        utilization: 72.3,
        status: 'Operational',
        lastUpdated: DateTime.now(),
      ),
      // Edge Routers
      RouterNodeModel(
        id: 'edge-01',
        name: 'Edge-Router-01',
        type: RouterType.edge,
        position: const Offset(250, 150),
        location: 'Site-North',
        ipAddress: '10.0.2.1',
        connectedLinks: 5,
        utilization: 58.2,
        status: 'Operational',
        lastUpdated: DateTime.now(),
      ),
      RouterNodeModel(
        id: 'edge-02',
        name: 'Edge-Router-02',
        type: RouterType.edge,
        position: const Offset(750, 150),
        location: 'Site-South',
        ipAddress: '10.0.2.2',
        connectedLinks: 5,
        utilization: 63.7,
        status: 'Operational',
        lastUpdated: DateTime.now(),
      ),
      RouterNodeModel(
        id: 'edge-03',
        name: 'Edge-Router-03',
        type: RouterType.edge,
        position: const Offset(250, 450),
        location: 'Site-East',
        ipAddress: '10.0.2.3',
        connectedLinks: 4,
        utilization: 45.9,
        status: 'Operational',
        lastUpdated: DateTime.now(),
      ),
      RouterNodeModel(
        id: 'edge-04',
        name: 'Edge-Router-04',
        type: RouterType.edge,
        position: const Offset(750, 450),
        location: 'Site-West',
        ipAddress: '10.0.2.4',
        connectedLinks: 4,
        utilization: 81.4,
        status: 'Degraded',
        lastUpdated: DateTime.now(),
      ),
      // Access Switches
      RouterNodeModel(
        id: 'access-01',
        name: 'Access-SW-01',
        type: RouterType.access,
        position: const Offset(150, 100),
        location: 'Branch-A',
        ipAddress: '10.0.3.1',
        connectedLinks: 2,
        utilization: 34.2,
        status: 'Operational',
        lastUpdated: DateTime.now(),
      ),
      RouterNodeModel(
        id: 'access-02',
        name: 'Access-SW-02',
        type: RouterType.access,
        position: const Offset(850, 100),
        location: 'Branch-B',
        ipAddress: '10.0.3.2',
        connectedLinks: 2,
        utilization: 42.8,
        status: 'Operational',
        lastUpdated: DateTime.now(),
      ),
    ];
  }

  List<NetworkLinkModel> _generateMockLinks() {
    return [
      // Core to Core
      NetworkLinkModel(
        id: 'link-01',
        fromNodeId: 'core-01',
        toNodeId: 'core-02',
        fromNodeName: 'Core-Router-01',
        toNodeName: 'Core-Router-02',
        capacityGbps: 100,
        utilizationPercent: 68.5,
        status: LinkStatus.operational,
        latencyMs: 2.3,
        packetLossPercent: 0.01,
        lastUpdated: DateTime.now(),
      ),
      // Core to Edge
      NetworkLinkModel(
        id: 'link-02',
        fromNodeId: 'core-01',
        toNodeId: 'edge-01',
        fromNodeName: 'Core-Router-01',
        toNodeName: 'Edge-Router-01',
        capacityGbps: 40,
        utilizationPercent: 55.2,
        status: LinkStatus.operational,
        latencyMs: 5.8,
        packetLossPercent: 0.02,
        lastUpdated: DateTime.now(),
      ),
      NetworkLinkModel(
        id: 'link-03',
        fromNodeId: 'core-02',
        toNodeId: 'edge-02',
        fromNodeName: 'Core-Router-02',
        toNodeName: 'Edge-Router-02',
        capacityGbps: 40,
        utilizationPercent: 62.8,
        status: LinkStatus.operational,
        latencyMs: 4.2,
        packetLossPercent: 0.01,
        lastUpdated: DateTime.now(),
      ),
      NetworkLinkModel(
        id: 'link-04',
        fromNodeId: 'core-01',
        toNodeId: 'edge-03',
        fromNodeName: 'Core-Router-01',
        toNodeName: 'Edge-Router-03',
        capacityGbps: 40,
        utilizationPercent: 43.5,
        status: LinkStatus.operational,
        latencyMs: 6.1,
        packetLossPercent: 0.03,
        lastUpdated: DateTime.now(),
      ),
      NetworkLinkModel(
        id: 'link-05',
        fromNodeId: 'core-02',
        toNodeId: 'edge-04',
        fromNodeName: 'Core-Router-02',
        toNodeName: 'Edge-Router-04',
        capacityGbps: 40,
        utilizationPercent: 85.7,
        status: LinkStatus.degraded,
        latencyMs: 8.9,
        packetLossPercent: 0.08,
        lastUpdated: DateTime.now(),
      ),
      // Edge to Access
      NetworkLinkModel(
        id: 'link-06',
        fromNodeId: 'edge-01',
        toNodeId: 'access-01',
        fromNodeName: 'Edge-Router-01',
        toNodeName: 'Access-SW-01',
        capacityGbps: 10,
        utilizationPercent: 38.4,
        status: LinkStatus.operational,
        latencyMs: 3.2,
        packetLossPercent: 0.02,
        lastUpdated: DateTime.now(),
      ),
      NetworkLinkModel(
        id: 'link-07',
        fromNodeId: 'edge-02',
        toNodeId: 'access-02',
        fromNodeName: 'Edge-Router-02',
        toNodeName: 'Access-SW-02',
        capacityGbps: 10,
        utilizationPercent: 47.9,
        status: LinkStatus.operational,
        latencyMs: 2.8,
        packetLossPercent: 0.01,
        lastUpdated: DateTime.now(),
      ),
    ];
  }

  BandwidthMetricsModel _generateMockMetrics() {
    final hourlyData = List.generate(60, (index) {
      return BandwidthDataPoint(
        timestamp: DateTime.now().subtract(Duration(minutes: 59 - index)),
        utilizationPercent: 40 + Random().nextDouble() * 40,
      );
    });

    return BandwidthMetricsModel(
      totalCapacityGbps: 480,
      currentUtilizationPercent: 64.2,
      availableBandwidthGbps: 172,
      peakUtilizationTime: '14:30',
      peakUtilizationPercent: 87.5,
      hourlyData: hourlyData,
    );
  }

  List<ThresholdAlertModel> _generateMockAlerts() {
    return [
      ThresholdAlertModel(
        id: 'alert-001',
        title: 'High Utilization Detected',
        description:
            'Link Core-Router-02 → Edge-Router-04 is at 85.7% capacity',
        severity: AlertSeverity.warning,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        affectedLink: 'link-05',
      ),
      ThresholdAlertModel(
        id: 'alert-002',
        title: 'Link Degraded',
        description: 'Edge-Router-04 showing degraded performance',
        severity: AlertSeverity.warning,
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        affectedLink: 'edge-04',
      ),
      ThresholdAlertModel(
        id: 'alert-003',
        title: 'High Latency Warning',
        description: 'Link Core-Router-02 → Edge-Router-04 latency exceeds 8ms',
        severity: AlertSeverity.info,
        timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
        affectedLink: 'link-05',
      ),
    ];
  }

  Future<void> refresh() async {
    await loadDashboardData();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
