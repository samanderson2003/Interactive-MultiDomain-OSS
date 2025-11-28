class CoreKPIModel {
  final double attachSuccessRate;
  final double detachRate;
  final double averageLatency;
  final double totalThroughput;
  final int activeSubscribers;
  final int activeSessions;
  final DateTime timestamp;

  CoreKPIModel({
    required this.attachSuccessRate,
    required this.detachRate,
    required this.averageLatency,
    required this.totalThroughput,
    required this.activeSubscribers,
    required this.activeSessions,
    required this.timestamp,
  });

  factory CoreKPIModel.empty() {
    return CoreKPIModel(
      attachSuccessRate: 0.0,
      detachRate: 0.0,
      averageLatency: 0.0,
      totalThroughput: 0.0,
      activeSubscribers: 0,
      activeSessions: 0,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attachSuccessRate': attachSuccessRate,
      'detachRate': detachRate,
      'averageLatency': averageLatency,
      'totalThroughput': totalThroughput,
      'activeSubscribers': activeSubscribers,
      'activeSessions': activeSessions,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CoreKPIModel.fromJson(Map<String, dynamic> json) {
    return CoreKPIModel(
      attachSuccessRate: json['attachSuccessRate'].toDouble(),
      detachRate: json['detachRate'].toDouble(),
      averageLatency: json['averageLatency'].toDouble(),
      totalThroughput: json['totalThroughput'].toDouble(),
      activeSubscribers: json['activeSubscribers'],
      activeSessions: json['activeSessions'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
