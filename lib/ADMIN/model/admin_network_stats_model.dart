import 'package:cloud_firestore/cloud_firestore.dart';

class NetworkElement {
  final String id;
  final String name;
  final String domain;
  final String type;
  final String ipAddress;
  final String status;
  final String location;
  final DateTime lastSeen;
  final Map<String, dynamic> metrics;

  NetworkElement({
    required this.id,
    required this.name,
    required this.domain,
    required this.type,
    required this.ipAddress,
    required this.status,
    required this.location,
    required this.lastSeen,
    required this.metrics,
  });

  factory NetworkElement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NetworkElement(
      id: doc.id,
      name: data['name'] ?? '',
      domain: data['domain'] ?? '',
      type: data['type'] ?? '',
      ipAddress: data['ipAddress'] ?? '',
      status: data['status'] ?? '',
      location: data['location'] ?? '',
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metrics: data['metrics'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'domain': domain,
      'type': type,
      'ipAddress': ipAddress,
      'status': status,
      'location': location,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'metrics': metrics,
    };
  }
}

class NetworkAlarm {
  final String id;
  final String source;
  final String domain;
  final String severity;
  final String description;
  final String status;
  final DateTime timestamp;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;

  NetworkAlarm({
    required this.id,
    required this.source,
    required this.domain,
    required this.severity,
    required this.description,
    required this.status,
    required this.timestamp,
    this.acknowledgedBy,
    this.acknowledgedAt,
  });

  factory NetworkAlarm.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NetworkAlarm(
      id: doc.id,
      source: data['source'] ?? '',
      domain: data['domain'] ?? '',
      severity: data['severity'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      acknowledgedBy: data['acknowledgedBy'],
      acknowledgedAt: (data['acknowledgedAt'] as Timestamp?)?.toDate(),
    );
  }

  NetworkAlarm copyWith({
    String? status,
    String? acknowledgedBy,
    DateTime? acknowledgedAt,
  }) {
    return NetworkAlarm(
      id: id,
      source: source,
      domain: domain,
      severity: severity,
      description: description,
      status: status ?? this.status,
      timestamp: timestamp,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
    );
  }
}

class NetworkTopologyNode {
  final String id;
  final String name;
  final String domain;
  final String type;
  final double x;
  final double y;
  final List<String> connections;

  NetworkTopologyNode({
    required this.id,
    required this.name,
    required this.domain,
    required this.type,
    required this.x,
    required this.y,
    required this.connections,
  });

  factory NetworkTopologyNode.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NetworkTopologyNode(
      id: doc.id,
      name: data['name'] ?? '',
      domain: data['domain'] ?? '',
      type: data['type'] ?? '',
      x: (data['x'] ?? 0).toDouble(),
      y: (data['y'] ?? 0).toDouble(),
      connections: List<String>.from(data['connections'] ?? []),
    );
  }
}

class NetworkDomainSummary {
  final int ranElements;
  final int coreElements;
  final int ipElements;
  final int totalElements;
  final int activeElements;
  final int criticalAlarms;
  final int majorAlarms;
  final int minorAlarms;

  NetworkDomainSummary({
    required this.ranElements,
    required this.coreElements,
    required this.ipElements,
    required this.totalElements,
    required this.activeElements,
    required this.criticalAlarms,
    required this.majorAlarms,
    required this.minorAlarms,
  });

  int get totalAlarms => criticalAlarms + majorAlarms + minorAlarms;
  int get inactiveElements => totalElements - activeElements;
}
