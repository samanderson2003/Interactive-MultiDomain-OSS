import 'package:flutter/material.dart';

enum AlertSeverity { critical, major, minor, warning, info }

extension AlertSeverityExtension on AlertSeverity {
  String get displayName {
    switch (this) {
      case AlertSeverity.critical:
        return 'Critical';
      case AlertSeverity.major:
        return 'Major';
      case AlertSeverity.minor:
        return 'Minor';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.info:
        return 'Info';
    }
  }

  Color get color {
    switch (this) {
      case AlertSeverity.critical:
        return const Color(0xFFef4444); // Red
      case AlertSeverity.major:
        return const Color(0xFFf97316); // Orange
      case AlertSeverity.minor:
        return const Color(0xFFfbbf24); // Yellow
      case AlertSeverity.warning:
        return const Color(0xFFf59e0b); // Amber
      case AlertSeverity.info:
        return const Color(0xFF06b6d4); // Cyan
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AlertSeverity.critical:
        return const Color(0xFFef4444).withOpacity(0.1);
      case AlertSeverity.major:
        return const Color(0xFFf97316).withOpacity(0.1);
      case AlertSeverity.minor:
        return const Color(0xFFfbbf24).withOpacity(0.1);
      case AlertSeverity.warning:
        return const Color(0xFFf59e0b).withOpacity(0.1);
      case AlertSeverity.info:
        return const Color(0xFF06b6d4).withOpacity(0.1);
    }
  }

  IconData get icon {
    switch (this) {
      case AlertSeverity.critical:
        return Icons.error;
      case AlertSeverity.major:
        return Icons.warning_amber;
      case AlertSeverity.minor:
        return Icons.info_outline;
      case AlertSeverity.warning:
        return Icons.warning;
      case AlertSeverity.info:
        return Icons.info;
    }
  }

  int get priority {
    switch (this) {
      case AlertSeverity.critical:
        return 5;
      case AlertSeverity.major:
        return 4;
      case AlertSeverity.minor:
        return 3;
      case AlertSeverity.warning:
        return 2;
      case AlertSeverity.info:
        return 1;
    }
  }
}

enum AlertStatus { active, acknowledged, resolved, ignored }

extension AlertStatusExtension on AlertStatus {
  String get displayName {
    switch (this) {
      case AlertStatus.active:
        return 'Active';
      case AlertStatus.acknowledged:
        return 'Acknowledged';
      case AlertStatus.resolved:
        return 'Resolved';
      case AlertStatus.ignored:
        return 'Ignored';
    }
  }

  Color get color {
    switch (this) {
      case AlertStatus.active:
        return const Color(0xFFef4444);
      case AlertStatus.acknowledged:
        return const Color(0xFFf59e0b);
      case AlertStatus.resolved:
        return const Color(0xFF10b981);
      case AlertStatus.ignored:
        return const Color(0xFF64748b);
    }
  }
}

class AlertModel {
  final String id;
  final String btsId;
  final String btsName;
  final String title;
  final String description;
  final AlertSeverity severity;
  final AlertStatus status;
  final DateTime timestamp;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;
  final String? acknowledgedBy;
  final String? resolvedBy;
  final String location;
  final String
  alertType; // BTS_DOWN, SIGNAL_DEGRADATION, CAPACITY_EXCEEDED, etc.
  final Map<String, dynamic> metadata;

  AlertModel({
    required this.id,
    required this.btsId,
    required this.btsName,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.timestamp,
    this.acknowledgedAt,
    this.resolvedAt,
    this.acknowledgedBy,
    this.resolvedBy,
    required this.location,
    required this.alertType,
    this.metadata = const {},
  });

  // Duration since alert was raised
  Duration get duration => DateTime.now().difference(timestamp);

  String get durationText {
    final duration = this.duration;
    if (duration.inDays > 0) {
      return '${duration.inDays}d ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool get isActive => status == AlertStatus.active;
  bool get isCritical => severity == AlertSeverity.critical;
  bool get requiresAttention =>
      isActive && (isCritical || severity == AlertSeverity.major);

  AlertModel copyWith({
    String? id,
    String? btsId,
    String? btsName,
    String? title,
    String? description,
    AlertSeverity? severity,
    AlertStatus? status,
    DateTime? timestamp,
    DateTime? acknowledgedAt,
    DateTime? resolvedAt,
    String? acknowledgedBy,
    String? resolvedBy,
    String? location,
    String? alertType,
    Map<String, dynamic>? metadata,
  }) {
    return AlertModel(
      id: id ?? this.id,
      btsId: btsId ?? this.btsId,
      btsName: btsName ?? this.btsName,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      location: location ?? this.location,
      alertType: alertType ?? this.alertType,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'btsId': btsId,
      'btsName': btsName,
      'title': title,
      'description': description,
      'severity': severity.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'acknowledgedAt': acknowledgedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'acknowledgedBy': acknowledgedBy,
      'resolvedBy': resolvedBy,
      'location': location,
      'alertType': alertType,
      'metadata': metadata,
    };
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'],
      btsId: json['btsId'],
      btsName: json['btsName'],
      title: json['title'],
      description: json['description'],
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AlertSeverity.info,
      ),
      status: AlertStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AlertStatus.active,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      acknowledgedAt: json['acknowledgedAt'] != null
          ? DateTime.parse(json['acknowledgedAt'])
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      acknowledgedBy: json['acknowledgedBy'],
      resolvedBy: json['resolvedBy'],
      location: json['location'],
      alertType: json['alertType'],
      metadata: json['metadata'] ?? {},
    );
  }
}
