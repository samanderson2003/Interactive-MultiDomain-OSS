import 'package:flutter/material.dart';
import 'core_element_model.dart';

class TopologyNodeModel {
  final String id;
  final String name;
  final CoreElementType type;
  final Offset position;
  final List<String> connections;

  TopologyNodeModel({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    required this.connections,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'position': {'dx': position.dx, 'dy': position.dy},
      'connections': connections,
    };
  }

  factory TopologyNodeModel.fromJson(Map<String, dynamic> json) {
    return TopologyNodeModel(
      id: json['id'],
      name: json['name'],
      type: CoreElementType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      position: Offset(
        json['position']['dx'].toDouble(),
        json['position']['dy'].toDouble(),
      ),
      connections: List<String>.from(json['connections']),
    );
  }
}
