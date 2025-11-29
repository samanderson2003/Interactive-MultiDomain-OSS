import 'alarm_severity.dart';
import 'alarm_status.dart';
import 'alarm_domain.dart';

class NOCAlarm {
  final String id;
  final DateTime timestamp;
  final AlarmDomain domain;
  final AlarmSeverity severity;
  final String element;
  final String description;
  final AlarmStatus status;
  final String? assignedTo;
  final List<AlarmComment> comments;
  final DateTime? acknowledgedAt;
  final DateTime? resolvedAt;
  final String? acknowledgedBy;
  final String? resolvedBy;
  final String impact;
  final List<String> affectedServices;

  NOCAlarm({
    required this.id,
    required this.timestamp,
    required this.domain,
    required this.severity,
    required this.element,
    required this.description,
    required this.status,
    this.assignedTo,
    this.comments = const [],
    this.acknowledgedAt,
    this.resolvedAt,
    this.acknowledgedBy,
    this.resolvedBy,
    required this.impact,
    this.affectedServices = const [],
  });

  NOCAlarm copyWith({
    String? id,
    DateTime? timestamp,
    AlarmDomain? domain,
    AlarmSeverity? severity,
    String? element,
    String? description,
    AlarmStatus? status,
    String? assignedTo,
    List<AlarmComment>? comments,
    DateTime? acknowledgedAt,
    DateTime? resolvedAt,
    String? acknowledgedBy,
    String? resolvedBy,
    String? impact,
    List<String>? affectedServices,
  }) {
    return NOCAlarm(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      domain: domain ?? this.domain,
      severity: severity ?? this.severity,
      element: element ?? this.element,
      description: description ?? this.description,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      comments: comments ?? this.comments,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      impact: impact ?? this.impact,
      affectedServices: affectedServices ?? this.affectedServices,
    );
  }

  Duration? get timeToAcknowledge {
    if (acknowledgedAt != null) {
      return acknowledgedAt!.difference(timestamp);
    }
    return null;
  }

  Duration? get timeToResolve {
    if (resolvedAt != null) {
      return resolvedAt!.difference(timestamp);
    }
    return null;
  }
}

class AlarmComment {
  final String id;
  final DateTime timestamp;
  final String user;
  final String comment;

  AlarmComment({
    required this.id,
    required this.timestamp,
    required this.user,
    required this.comment,
  });
}
