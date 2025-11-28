import 'package:flutter/material.dart';

enum BTSStatus { active, inactive, degraded, maintenance }

extension BTSStatusExtension on BTSStatus {
  String get displayName {
    switch (this) {
      case BTSStatus.active:
        return 'Active';
      case BTSStatus.inactive:
        return 'Inactive';
      case BTSStatus.degraded:
        return 'Degraded';
      case BTSStatus.maintenance:
        return 'Maintenance';
    }
  }

  Color get color {
    switch (this) {
      case BTSStatus.active:
        return const Color(0xFF10b981); // Green
      case BTSStatus.inactive:
        return const Color(0xFFef4444); // Red
      case BTSStatus.degraded:
        return const Color(0xFFf59e0b); // Orange
      case BTSStatus.maintenance:
        return const Color(0xFF06b6d4); // Cyan
    }
  }

  IconData get icon {
    switch (this) {
      case BTSStatus.active:
        return Icons.check_circle;
      case BTSStatus.inactive:
        return Icons.cancel;
      case BTSStatus.degraded:
        return Icons.warning;
      case BTSStatus.maintenance:
        return Icons.build_circle;
    }
  }
}

class BTSModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String location;
  final String city;
  final String region;
  final BTSStatus status;
  final double rsrp; // Reference Signal Received Power (dBm) -44 to -140
  final double rsrq; // Reference Signal Received Quality (dB) -3 to -19.5
  final double sinr; // Signal to Interference plus Noise Ratio (dB) -20 to +30
  final double capacityUtilization; // Percentage 0-100
  final int activeUsers;
  final int maxCapacity;
  final DateTime lastUpdated;
  final List<String> alerts;
  final String technology; // 4G, 5G
  final int frequency; // MHz
  final double bandwidth; // MHz
  final double txPower; // dBm

  BTSModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.city,
    required this.region,
    required this.status,
    required this.rsrp,
    required this.rsrq,
    required this.sinr,
    required this.capacityUtilization,
    required this.activeUsers,
    required this.maxCapacity,
    required this.lastUpdated,
    required this.alerts,
    required this.technology,
    required this.frequency,
    required this.bandwidth,
    required this.txPower,
  });

  // Signal quality assessment
  String get rsrpQuality {
    if (rsrp >= -80) return 'Excellent';
    if (rsrp >= -90) return 'Good';
    if (rsrp >= -100) return 'Fair';
    return 'Poor';
  }

  String get rsrqQuality {
    if (rsrq >= -10) return 'Excellent';
    if (rsrq >= -15) return 'Good';
    if (rsrq >= -20) return 'Fair';
    return 'Poor';
  }

  String get sinrQuality {
    if (sinr >= 20) return 'Excellent';
    if (sinr >= 13) return 'Good';
    if (sinr >= 0) return 'Fair';
    return 'Poor';
  }

  Color get healthColor {
    if (status == BTSStatus.inactive) return const Color(0xFFef4444);
    if (status == BTSStatus.degraded) return const Color(0xFFf59e0b);
    if (capacityUtilization > 85) return const Color(0xFFf59e0b);
    if (rsrp < -100 || rsrq < -15 || sinr < 0) {
      return const Color(0xFFf59e0b);
    }
    return const Color(0xFF10b981);
  }

  int get alertCount => alerts.length;

  bool get hasCriticalIssues =>
      status == BTSStatus.inactive || capacityUtilization > 90;

  bool get hasWarnings =>
      status == BTSStatus.degraded ||
      capacityUtilization > 75 ||
      rsrp < -100 ||
      rsrq < -15;

  // Copy with method for updates
  BTSModel copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? location,
    String? city,
    String? region,
    BTSStatus? status,
    double? rsrp,
    double? rsrq,
    double? sinr,
    double? capacityUtilization,
    int? activeUsers,
    int? maxCapacity,
    DateTime? lastUpdated,
    List<String>? alerts,
    String? technology,
    int? frequency,
    double? bandwidth,
    double? txPower,
  }) {
    return BTSModel(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      location: location ?? this.location,
      city: city ?? this.city,
      region: region ?? this.region,
      status: status ?? this.status,
      rsrp: rsrp ?? this.rsrp,
      rsrq: rsrq ?? this.rsrq,
      sinr: sinr ?? this.sinr,
      capacityUtilization: capacityUtilization ?? this.capacityUtilization,
      activeUsers: activeUsers ?? this.activeUsers,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      alerts: alerts ?? this.alerts,
      technology: technology ?? this.technology,
      frequency: frequency ?? this.frequency,
      bandwidth: bandwidth ?? this.bandwidth,
      txPower: txPower ?? this.txPower,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'city': city,
      'region': region,
      'status': status.name,
      'rsrp': rsrp,
      'rsrq': rsrq,
      'sinr': sinr,
      'capacityUtilization': capacityUtilization,
      'activeUsers': activeUsers,
      'maxCapacity': maxCapacity,
      'lastUpdated': lastUpdated.toIso8601String(),
      'alerts': alerts,
      'technology': technology,
      'frequency': frequency,
      'bandwidth': bandwidth,
      'txPower': txPower,
    };
  }

  factory BTSModel.fromJson(Map<String, dynamic> json) {
    return BTSModel(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      location: json['location'],
      city: json['city'],
      region: json['region'],
      status: BTSStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BTSStatus.active,
      ),
      rsrp: json['rsrp'],
      rsrq: json['rsrq'],
      sinr: json['sinr'],
      capacityUtilization: json['capacityUtilization'],
      activeUsers: json['activeUsers'],
      maxCapacity: json['maxCapacity'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      alerts: List<String>.from(json['alerts']),
      technology: json['technology'],
      frequency: json['frequency'],
      bandwidth: json['bandwidth'],
      txPower: json['txPower'],
    );
  }
}

// Time series data for charts
class BTSMetricData {
  final DateTime timestamp;
  final double rsrp;
  final double rsrq;
  final double sinr;
  final double capacity;

  BTSMetricData({
    required this.timestamp,
    required this.rsrp,
    required this.rsrq,
    required this.sinr,
    required this.capacity,
  });
}
