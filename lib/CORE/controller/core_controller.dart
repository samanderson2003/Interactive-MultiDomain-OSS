import 'package:flutter/material.dart';
import '../model/core_element_model.dart';
import '../model/core_kpi_model.dart';
import '../model/service_health_model.dart';
import '../model/topology_node_model.dart';

class CoreController with ChangeNotifier {
  List<CoreElementModel> _coreElements = [];
  CoreKPIModel? _kpis;
  List<ServiceHealthModel> _serviceHealthList = [];
  List<TopologyNodeModel> _topologyNodes = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CoreElementModel> get coreElements => _coreElements;
  CoreKPIModel get kpis => _kpis ?? CoreKPIModel.empty();
  List<ServiceHealthModel> get serviceHealthList => _serviceHealthList;
  List<TopologyNodeModel> get topologyNodes => _topologyNodes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load dashboard data
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call with delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Generate mock CORE elements
      _coreElements = _generateMockCoreElements();

      // Generate mock KPIs
      _kpis = _generateMockKPIs();

      // Generate mock service health
      _serviceHealthList = _generateMockServiceHealth();

      // Generate mock topology nodes
      _topologyNodes = _generateMockTopologyNodes();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get element by ID
  CoreElementModel? getElementById(String id) {
    try {
      return _coreElements.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

  // Filter elements by type
  List<CoreElementModel> getElementsByType(CoreElementType type) {
    return _coreElements.where((element) => element.type == type).toList();
  }

  // Filter elements by status
  List<CoreElementModel> getElementsByStatus(String status) {
    return _coreElements.where((element) => element.status == status).toList();
  }

  // Get service health by name
  ServiceHealthModel? getServiceByName(String name) {
    try {
      return _serviceHealthList.firstWhere((service) => service.name == name);
    } catch (e) {
      return null;
    }
  }

  // Mock data generators
  List<CoreElementModel> _generateMockCoreElements() {
    return [
      CoreElementModel(
        id: 'hlr-001',
        name: 'HLR-CENTRAL-01',
        type: CoreElementType.hlr,
        location: 'Data Center 1',
        ipAddress: '10.20.1.10',
        status: 'Active',
        version: 'v2.5.1',
        subscribers: 1250000,
        capacityUsage: 62.5,
        cpu: 45.2,
        memory: 68.5,
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      CoreElementModel(
        id: 'hlr-002',
        name: 'HLR-BACKUP-01',
        type: CoreElementType.hlr,
        location: 'Data Center 2',
        ipAddress: '10.20.1.11',
        status: 'Standby',
        version: 'v2.5.1',
        subscribers: 0,
        capacityUsage: 5.0,
        cpu: 12.5,
        memory: 25.3,
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      CoreElementModel(
        id: 'mme-001',
        name: 'MME-REGION-01',
        type: CoreElementType.mme,
        location: 'Region North',
        ipAddress: '10.20.2.10',
        status: 'Active',
        version: 'v3.2.0',
        activeConnections: 45000,
        capacityUsage: 75.0,
        cpu: 72.8,
        memory: 81.2,
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      CoreElementModel(
        id: 'mme-002',
        name: 'MME-REGION-02',
        type: CoreElementType.mme,
        location: 'Region South',
        ipAddress: '10.20.2.11',
        status: 'Active',
        version: 'v3.2.0',
        activeConnections: 38000,
        capacityUsage: 63.3,
        cpu: 65.5,
        memory: 70.8,
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      CoreElementModel(
        id: 'sgw-001',
        name: 'SGW-CORE-01',
        type: CoreElementType.sgw,
        location: 'Data Center 1',
        ipAddress: '10.20.3.10',
        status: 'Active',
        version: 'v4.1.2',
        throughput: 125.5,
        capacityUsage: 68.5,
        cpu: 58.3,
        memory: 72.1,
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      CoreElementModel(
        id: 'sgw-002',
        name: 'SGW-CORE-02',
        type: CoreElementType.sgw,
        location: 'Data Center 2',
        ipAddress: '10.20.3.11',
        status: 'Active',
        version: 'v4.1.2',
        throughput: 98.2,
        capacityUsage: 53.8,
        cpu: 48.7,
        memory: 61.5,
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      CoreElementModel(
        id: 'pgw-001',
        name: 'PGW-INTERNET-01',
        type: CoreElementType.pgw,
        location: 'Data Center 1',
        ipAddress: '10.20.4.10',
        status: 'Active',
        version: 'v4.3.1',
        throughput: 215.8,
        capacityUsage: 71.9,
        cpu: 68.5,
        memory: 75.2,
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
      CoreElementModel(
        id: 'pgw-002',
        name: 'PGW-INTERNET-02',
        type: CoreElementType.pgw,
        location: 'Data Center 2',
        ipAddress: '10.20.4.11',
        status: 'Active',
        version: 'v4.3.1',
        throughput: 185.3,
        capacityUsage: 61.8,
        cpu: 58.9,
        memory: 68.5,
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      CoreElementModel(
        id: 'hss-001',
        name: 'HSS-PRIMARY-01',
        type: CoreElementType.hss,
        location: 'Data Center 1',
        ipAddress: '10.20.5.10',
        status: 'Active',
        version: 'v3.5.0',
        subscribers: 2500000,
        capacityUsage: 83.3,
        cpu: 55.2,
        memory: 78.9,
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      CoreElementModel(
        id: 'epc-001',
        name: 'EPC-CORE-01',
        type: CoreElementType.epc,
        location: 'Data Center 1',
        ipAddress: '10.20.6.10',
        status: 'Active',
        version: 'v5.0.1',
        activeConnections: 125000,
        capacityUsage: 69.5,
        cpu: 62.8,
        memory: 71.3,
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ];
  }

  CoreKPIModel _generateMockKPIs() {
    return CoreKPIModel(
      attachSuccessRate: 0.978,
      detachRate: 42.5,
      averageLatency: 85.3,
      totalThroughput: 625.8,
      activeSubscribers: 3750000,
      activeSessions: 208000,
      timestamp: DateTime.now(),
    );
  }

  List<ServiceHealthModel> _generateMockServiceHealth() {
    return [
      ServiceHealthModel(
        id: 'svc-001',
        name: 'Voice Service',
        status: 'Operational',
        uptime: 99.85,
        lastIncident: DateTime.now().subtract(const Duration(days: 12)),
      ),
      ServiceHealthModel(
        id: 'svc-002',
        name: 'Data Service',
        status: 'Operational',
        uptime: 99.92,
        lastIncident: DateTime.now().subtract(const Duration(days: 8)),
      ),
      ServiceHealthModel(
        id: 'svc-003',
        name: 'SMS Service',
        status: 'Operational',
        uptime: 99.78,
        lastIncident: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ServiceHealthModel(
        id: 'svc-004',
        name: 'Location Service',
        status: 'Degraded',
        uptime: 98.45,
        lastIncident: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }

  List<TopologyNodeModel> _generateMockTopologyNodes() {
    return [
      TopologyNodeModel(
        id: 'node-hlr',
        name: 'HLR',
        type: CoreElementType.hlr,
        position: const Offset(100, 200),
        connections: ['node-mme', 'node-hss'],
      ),
      TopologyNodeModel(
        id: 'node-hss',
        name: 'HSS',
        type: CoreElementType.hss,
        position: const Offset(100, 400),
        connections: ['node-hlr', 'node-mme'],
      ),
      TopologyNodeModel(
        id: 'node-mme',
        name: 'MME',
        type: CoreElementType.mme,
        position: const Offset(300, 300),
        connections: ['node-hlr', 'node-hss', 'node-sgw'],
      ),
      TopologyNodeModel(
        id: 'node-sgw',
        name: 'SGW',
        type: CoreElementType.sgw,
        position: const Offset(500, 300),
        connections: ['node-mme', 'node-pgw'],
      ),
      TopologyNodeModel(
        id: 'node-pgw',
        name: 'PGW',
        type: CoreElementType.pgw,
        position: const Offset(700, 300),
        connections: ['node-sgw'],
      ),
      TopologyNodeModel(
        id: 'node-epc',
        name: 'EPC',
        type: CoreElementType.epc,
        position: const Offset(400, 150),
        connections: ['node-mme', 'node-sgw', 'node-pgw'],
      ),
    ];
  }

  // Refresh data
  Future<void> refresh() async {
    await loadDashboardData();
  }
}
