enum AlarmSeverity { critical, major, minor, warning, info }

extension AlarmSeverityExtension on AlarmSeverity {
  String get displayName {
    switch (this) {
      case AlarmSeverity.critical:
        return 'Critical';
      case AlarmSeverity.major:
        return 'Major';
      case AlarmSeverity.minor:
        return 'Minor';
      case AlarmSeverity.warning:
        return 'Warning';
      case AlarmSeverity.info:
        return 'Info';
    }
  }

  int get priority {
    switch (this) {
      case AlarmSeverity.critical:
        return 5;
      case AlarmSeverity.major:
        return 4;
      case AlarmSeverity.minor:
        return 3;
      case AlarmSeverity.warning:
        return 2;
      case AlarmSeverity.info:
        return 1;
    }
  }
}
