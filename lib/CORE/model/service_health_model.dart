class ServiceHealthModel {
  final String id;
  final String name;
  final String status;
  final double uptime;
  final DateTime lastIncident;

  ServiceHealthModel({
    required this.id,
    required this.name,
    required this.status,
    required this.uptime,
    required this.lastIncident,
  });

  bool get isHealthy => status == 'Operational' && uptime > 99.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'uptime': uptime,
      'lastIncident': lastIncident.toIso8601String(),
    };
  }

  factory ServiceHealthModel.fromJson(Map<String, dynamic> json) {
    return ServiceHealthModel(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      uptime: json['uptime'].toDouble(),
      lastIncident: DateTime.parse(json['lastIncident']),
    );
  }
}
