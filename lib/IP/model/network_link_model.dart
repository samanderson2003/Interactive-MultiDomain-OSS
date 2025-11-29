import 'package:flutter/material.dart';
import 'link_status_model.dart';

class NetworkLinkModel {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  final String fromNodeName;
  final String toNodeName;
  final int capacityGbps;
  final double utilizationPercent;
  final LinkStatus status;
  final double latencyMs;
  final double packetLossPercent;
  final DateTime lastUpdated;

  NetworkLinkModel({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.fromNodeName,
    required this.toNodeName,
    required this.capacityGbps,
    required this.utilizationPercent,
    required this.status,
    required this.latencyMs,
    required this.packetLossPercent,
    required this.lastUpdated,
  });

  Color get utilizationColor {
    if (utilizationPercent >= 80) {
      return Colors.red;
    } else if (utilizationPercent >= 60) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Color get statusColor {
    switch (status) {
      case LinkStatus.operational:
        return Colors.green;
      case LinkStatus.degraded:
        return Colors.orange;
      case LinkStatus.failed:
        return Colors.red;
    }
  }

  String get statusLabel {
    switch (status) {
      case LinkStatus.operational:
        return 'Operational';
      case LinkStatus.degraded:
        return 'Degraded';
      case LinkStatus.failed:
        return 'Failed';
    }
  }

  bool get hasAlert {
    return utilizationPercent >= 80 ||
        status != LinkStatus.operational ||
        packetLossPercent > 0.1;
  }
}
