import 'package:cloud_firestore/cloud_firestore.dart';

class AdminActivityLog {
  final String id;
  final String userId;
  final String userName;
  final String action;
  final String description;
  final DateTime timestamp;
  final String? ipAddress;
  final Map<String, dynamic>? metadata;

  AdminActivityLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.description,
    required this.timestamp,
    this.ipAddress,
    this.metadata,
  });

  factory AdminActivityLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminActivityLog(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      action: data['action'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      ipAddress: data['ipAddress'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'action': action,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'ipAddress': ipAddress,
      'metadata': metadata,
    };
  }
}
