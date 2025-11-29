class BandwidthMetricsModel {
  final int totalCapacityGbps;
  final double currentUtilizationPercent;
  final int availableBandwidthGbps;
  final String peakUtilizationTime;
  final double peakUtilizationPercent;
  final List<BandwidthDataPoint> hourlyData;

  BandwidthMetricsModel({
    required this.totalCapacityGbps,
    required this.currentUtilizationPercent,
    required this.availableBandwidthGbps,
    required this.peakUtilizationTime,
    required this.peakUtilizationPercent,
    required this.hourlyData,
  });

  int get currentBandwidthGbps {
    return ((totalCapacityGbps * currentUtilizationPercent) / 100).round();
  }

  BandwidthMetricsModel.empty()
    : totalCapacityGbps = 0,
      currentUtilizationPercent = 0,
      availableBandwidthGbps = 0,
      peakUtilizationTime = 'N/A',
      peakUtilizationPercent = 0,
      hourlyData = [];
}

class BandwidthDataPoint {
  final DateTime timestamp;
  final double utilizationPercent;

  BandwidthDataPoint({
    required this.timestamp,
    required this.utilizationPercent,
  });
}
