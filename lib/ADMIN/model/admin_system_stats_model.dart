class AdminSystemStats {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int activeSessions;
  final int totalRANSites;
  final int totalCOREElements;
  final int totalIPNodes;
  final int criticalAlarms;
  final int majorAlarms;
  final int minorAlarms;
  final double systemUptime;
  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;
  final int totalNetworkElements;

  AdminSystemStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.activeSessions,
    required this.totalRANSites,
    required this.totalCOREElements,
    required this.totalIPNodes,
    required this.criticalAlarms,
    required this.majorAlarms,
    required this.minorAlarms,
    required this.systemUptime,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.totalNetworkElements,
  });

  factory AdminSystemStats.empty() {
    return AdminSystemStats(
      totalUsers: 0,
      activeUsers: 0,
      inactiveUsers: 0,
      activeSessions: 0,
      totalRANSites: 0,
      totalCOREElements: 0,
      totalIPNodes: 0,
      criticalAlarms: 0,
      majorAlarms: 0,
      minorAlarms: 0,
      systemUptime: 99.9,
      cpuUsage: 0.0,
      memoryUsage: 0.0,
      diskUsage: 0.0,
      totalNetworkElements: 0,
    );
  }
}

class UserRoleDistribution {
  final int adminCount;
  final int ranEngineerCount;
  final int coreEngineerCount;
  final int ipEngineerCount;
  final int nocManagerCount;

  UserRoleDistribution({
    required this.adminCount,
    required this.ranEngineerCount,
    required this.coreEngineerCount,
    required this.ipEngineerCount,
    required this.nocManagerCount,
  });

  int get total =>
      adminCount +
      ranEngineerCount +
      coreEngineerCount +
      ipEngineerCount +
      nocManagerCount;

  factory UserRoleDistribution.empty() {
    return UserRoleDistribution(
      adminCount: 0,
      ranEngineerCount: 0,
      coreEngineerCount: 0,
      ipEngineerCount: 0,
      nocManagerCount: 0,
    );
  }
}

class NetworkDomainStats {
  final String domain;
  final int totalElements;
  final int activeElements;
  final int inactiveElements;
  final int alarms;

  NetworkDomainStats({
    required this.domain,
    required this.totalElements,
    required this.activeElements,
    required this.inactiveElements,
    required this.alarms,
  });
}

class SystemHealthMetric {
  final DateTime timestamp;
  final double cpuUsage;
  final double memoryUsage;
  final double diskUsage;
  final int activeConnections;

  SystemHealthMetric({
    required this.timestamp,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.diskUsage,
    required this.activeConnections,
  });
}
