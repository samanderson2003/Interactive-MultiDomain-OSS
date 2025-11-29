import 'package:flutter/material.dart';

enum RouterType { core, edge, access }

class RouterNodeModel {
  final String id;
  final String name;
  final RouterType type;
  final Offset position;
  final String location;
  final String ipAddress;
  final int connectedLinks;
  final double utilization;
  final String status;
  final DateTime lastUpdated;

  RouterNodeModel({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    required this.location,
    required this.ipAddress,
    required this.connectedLinks,
    required this.utilization,
    required this.status,
    required this.lastUpdated,
  });

  String get typeLabel {
    switch (type) {
      case RouterType.core:
        return 'Core Router';
      case RouterType.edge:
        return 'Edge Router';
      case RouterType.access:
        return 'Access Switch';
    }
  }

  double get nodeSize {
    switch (type) {
      case RouterType.core:
        return 60.0;
      case RouterType.edge:
        return 45.0;
      case RouterType.access:
        return 30.0;
    }
  }

  IconData get icon {
    switch (type) {
      case RouterType.core:
        return Icons.router;
      case RouterType.edge:
        return Icons.device_hub;
      case RouterType.access:
        return Icons.settings_input_hdmi;
    }
  }
}
