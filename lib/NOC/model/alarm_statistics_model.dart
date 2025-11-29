import 'alarm_domain.dart';
import 'alarm_severity.dart';

class AlarmStatistics {
  final int totalActive;
  final int totalAcknowledged;
  final int totalResolved;
  final Map<AlarmDomain, int> byDomain;
  final Map<AlarmSeverity, int> bySeverity;
  final List<DailyAlarmTrend> trends;
  final double avgAcknowledgeTime; // in minutes
  final double avgResolveTime; // in minutes
  final List<TopAffectedElement> topElements;

  AlarmStatistics({
    required this.totalActive,
    required this.totalAcknowledged,
    required this.totalResolved,
    required this.byDomain,
    required this.bySeverity,
    required this.trends,
    required this.avgAcknowledgeTime,
    required this.avgResolveTime,
    required this.topElements,
  });

  int get totalAlarms => totalActive + totalAcknowledged + totalResolved;
}

class DailyAlarmTrend {
  final DateTime date;
  final int critical;
  final int major;
  final int minor;
  final int warning;

  DailyAlarmTrend({
    required this.date,
    required this.critical,
    required this.major,
    required this.minor,
    required this.warning,
  });

  int get total => critical + major + minor + warning;
}

class TopAffectedElement {
  final String elementName;
  final int alarmCount;
  final AlarmDomain domain;

  TopAffectedElement({
    required this.elementName,
    required this.alarmCount,
    required this.domain,
  });
}

class HourlyAlarmDistribution {
  final int hour;
  final int count;

  HourlyAlarmDistribution({required this.hour, required this.count});
}
