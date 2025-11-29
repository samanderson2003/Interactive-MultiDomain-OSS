import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/admin_analytics_controller.dart';

class AdminPerformanceMetricsScreen extends StatefulWidget {
  const AdminPerformanceMetricsScreen({super.key});

  @override
  State<AdminPerformanceMetricsScreen> createState() =>
      _AdminPerformanceMetricsScreenState();
}

class _AdminPerformanceMetricsScreenState
    extends State<AdminPerformanceMetricsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminAnalyticsController>().loadPerformanceMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: Consumer<AdminAnalyticsController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final metrics = controller.performanceMetrics;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance Metrics',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                _buildMetricsGrid(metrics),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> metrics) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildMetricCard(
          'Avg Response Time',
          '${metrics['avgResponseTime'] ?? 0}ms',
          Icons.speed,
          const Color(0xFF3b82f6),
        ),
        _buildMetricCard(
          'Total Requests',
          '${metrics['totalRequests'] ?? 0}',
          Icons.api,
          const Color(0xFF10b981),
        ),
        _buildMetricCard(
          'Success Rate',
          '${metrics['successRate'] ?? 0}%',
          Icons.check_circle,
          const Color(0xFF10b981),
        ),
        _buildMetricCard(
          'CPU Usage',
          '${metrics['avgCpuUsage'] ?? 0}%',
          Icons.memory,
          const Color(0xFFf59e0b),
        ),
        _buildMetricCard(
          'Memory Usage',
          '${metrics['avgMemoryUsage'] ?? 0}%',
          Icons.storage,
          const Color(0xFF8b5cf6),
        ),
        _buildMetricCard(
          'Network Throughput',
          '${metrics['networkThroughput'] ?? 0} Mbps',
          Icons.network_check,
          const Color(0xFF3b82f6),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: (MediaQuery.of(context).size.width - 80) / 3,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}
