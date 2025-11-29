enum AlarmStatus { active, acknowledged, inProgress, resolved, closed }

extension AlarmStatusExtension on AlarmStatus {
  String get displayName {
    switch (this) {
      case AlarmStatus.active:
        return 'Active';
      case AlarmStatus.acknowledged:
        return 'Acknowledged';
      case AlarmStatus.inProgress:
        return 'In Progress';
      case AlarmStatus.resolved:
        return 'Resolved';
      case AlarmStatus.closed:
        return 'Closed';
    }
  }
}
