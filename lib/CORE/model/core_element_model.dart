enum CoreElementType {
  hlr, // Home Location Register
  epc, // Evolved Packet Core
  mme, // Mobility Management Entity
  sgw, // Serving Gateway
  pgw, // PDN Gateway
  hss, // Home Subscriber Server
}

class CoreElementModel {
  final String id;
  final String name;
  final CoreElementType type;
  final String location;
  final String ipAddress;
  final String status;
  final String version;
  final int? subscribers;
  final int? activeConnections;
  final double? throughput;
  final double capacityUsage;
  final double cpu;
  final double memory;
  final DateTime lastUpdate;

  CoreElementModel({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.ipAddress,
    required this.status,
    required this.version,
    this.subscribers,
    this.activeConnections,
    this.throughput,
    required this.capacityUsage,
    required this.cpu,
    required this.memory,
    required this.lastUpdate,
  });

  String get typeString {
    switch (type) {
      case CoreElementType.hlr:
        return 'HLR';
      case CoreElementType.epc:
        return 'EPC';
      case CoreElementType.mme:
        return 'MME';
      case CoreElementType.sgw:
        return 'SGW';
      case CoreElementType.pgw:
        return 'PGW';
      case CoreElementType.hss:
        return 'HSS';
    }
  }

  bool get isHealthy => status == 'Active' && cpu < 80 && memory < 85;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'location': location,
      'ipAddress': ipAddress,
      'status': status,
      'version': version,
      'subscribers': subscribers,
      'activeConnections': activeConnections,
      'throughput': throughput,
      'capacityUsage': capacityUsage,
      'cpu': cpu,
      'memory': memory,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }

  factory CoreElementModel.fromJson(Map<String, dynamic> json) {
    return CoreElementModel(
      id: json['id'],
      name: json['name'],
      type: CoreElementType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      location: json['location'],
      ipAddress: json['ipAddress'],
      status: json['status'],
      version: json['version'],
      subscribers: json['subscribers'],
      activeConnections: json['activeConnections'],
      throughput: json['throughput']?.toDouble(),
      capacityUsage: json['capacityUsage'].toDouble(),
      cpu: json['cpu'].toDouble(),
      memory: json['memory'].toDouble(),
      lastUpdate: DateTime.parse(json['lastUpdate']),
    );
  }
}
