enum AlertSeverity { critical, warning, info }

class ThresholdAlertModel {
  final String id;
  final String title;
  final String description;
  final AlertSeverity severity;
  final DateTime timestamp;
  final String affectedLink;
  final bool acknowledged;

  ThresholdAlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
    required this.affectedLink,
    this.acknowledged = false,
  });

  String get severityLabel {
    switch (severity) {
      case AlertSeverity.critical:
        return 'Critical';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.info:
        return 'Info';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
