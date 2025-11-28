import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/core_element_model.dart';

class CoreElementDetailScreen extends StatelessWidget {
  const CoreElementDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final element = ModalRoute.of(context)!.settings.arguments as CoreElementModel;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131823),
        title: Text(
          element.name,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(element),
            const SizedBox(height: 24),
            _buildInfoSection(element),
            const SizedBox(height: 24),
            _buildPerformanceSection(element),
            const SizedBox(height: 24),
            _buildMetricsSection(element),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CoreElementModel element) {
    final statusColor = element.status == 'Active' ? Colors.green : Colors.orange;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0ea5e9).withOpacity(0.2),
            const Color(0xFF131823),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0ea5e9).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0ea5e9).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getIconForType(element.type),
              color: const Color(0xFF0ea5e9),
              size: 40,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  element.typeString,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  element.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              element.status,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(CoreElementModel element) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0ea5e9).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Information',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Location', element.location),
          _buildInfoRow('IP Address', element.ipAddress),
          _buildInfoRow('Version', element.version),
          _buildInfoRow('Last Update', _formatDateTime(element.lastUpdate)),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(CoreElementModel element) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0ea5e9).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildMetricBar('CPU Usage', element.cpu, 80),
          const SizedBox(height: 16),
          _buildMetricBar('Memory Usage', element.memory, 85),
          const SizedBox(height: 16),
          _buildMetricBar('Capacity Usage', element.capacityUsage, 90),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(CoreElementModel element) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0ea5e9).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Metrics',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (element.subscribers != null)
            _buildMetricCard('Subscribers', element.subscribers.toString(), Icons.people),
          if (element.activeConnections != null)
            _buildMetricCard('Active Connections', element.activeConnections.toString(), Icons.link),
          if (element.throughput != null)
            _buildMetricCard('Throughput', '${element.throughput!.toStringAsFixed(1)} Gbps', Icons.speed),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBar(String label, double value, double threshold) {
    final isHealthy = value < threshold;
    final color = isHealthy ? Colors.green : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.white24,
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0a0e1a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0ea5e9), size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(CoreElementType type) {
    switch (type) {
      case CoreElementType.hlr:
        return Icons.storage;
      case CoreElementType.epc:
        return Icons.hub;
      case CoreElementType.mme:
        return Icons.router;
      case CoreElementType.sgw:
        return Icons.network_cell;
      case CoreElementType.pgw:
        return Icons.cloud;
      case CoreElementType.hss:
        return Icons.dns;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
