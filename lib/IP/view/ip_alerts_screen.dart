import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../controller/ip_controller.dart';
import '../model/threshold_alert_model.dart';

class IPAlertsScreen extends StatefulWidget {
  const IPAlertsScreen({super.key});

  @override
  State<IPAlertsScreen> createState() => _IPAlertsScreenState();
}

class _IPAlertsScreenState extends State<IPAlertsScreen> {
  String _filterSeverity = 'All';
  bool _showAcknowledged = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131823),
        title: Text(
          'Threshold Alerts',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<IPController>().refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<IPController>(
        builder: (context, controller, _) {
          final filteredAlerts = _getFilteredAlerts(controller.alerts);
          final criticalCount = controller.alerts
              .where(
                (a) => a.severity == AlertSeverity.critical && !a.acknowledged,
              )
              .length;
          final warningCount = controller.alerts
              .where(
                (a) => a.severity == AlertSeverity.warning && !a.acknowledged,
              )
              .length;

          return Column(
            children: [
              _buildSummaryBar(criticalCount, warningCount),
              _buildFilterBar(),
              Expanded(
                child: filteredAlerts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredAlerts.length,
                        itemBuilder: (context, index) {
                          return FadeInUp(
                            duration: Duration(
                              milliseconds: 300 + (index * 50),
                            ),
                            child: _buildAlertCard(
                              filteredAlerts[index],
                              controller,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryBar(int criticalCount, int warningCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF131823),
        border: Border(bottom: BorderSide(color: Color(0xFF1f2937))),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Critical',
              criticalCount,
              Colors.red,
              Icons.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Warning',
              warningCount,
              Colors.orange,
              Icons.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF131823),
        border: Border(bottom: BorderSide(color: Color(0xFF1f2937))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0a0e1a),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: _filterSeverity,
                isExpanded: true,
                dropdownColor: const Color(0xFF131823),
                underline: const SizedBox(),
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                items: ['All', 'Critical', 'Warning', 'Info']
                    .map(
                      (severity) => DropdownMenuItem(
                        value: severity,
                        child: Text(severity),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _filterSeverity = value!),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              Checkbox(
                value: _showAcknowledged,
                onChanged: (value) =>
                    setState(() => _showAcknowledged = value!),
                activeColor: const Color(0xFFf59e0b),
              ),
              Text(
                'Show Acknowledged',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(ThresholdAlertModel alert, IPController controller) {
    final color = _getSeverityColor(alert.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getSeverityIcon(alert.severity), color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            alert.severity
                                .toString()
                                .split('.')
                                .last
                                .toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          alert.timeAgo,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (alert.acknowledged)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0a0e1a),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.link, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Text(
                  alert.affectedLink,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (!alert.acknowledged) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.acknowledgeAlert(alert.id),
                icon: const Icon(Icons.check, size: 18),
                label: Text(
                  'Acknowledge',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf59e0b),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_off, size: 64, color: Colors.white38),
          const SizedBox(height: 16),
          Text(
            'No alerts found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Colors.red;
      case AlertSeverity.warning:
        return Colors.orange;
      case AlertSeverity.info:
        return Colors.blue;
    }
  }

  IconData _getSeverityIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Icons.error;
      case AlertSeverity.warning:
        return Icons.warning;
      case AlertSeverity.info:
        return Icons.info;
    }
  }

  List<ThresholdAlertModel> _getFilteredAlerts(
    List<ThresholdAlertModel> alerts,
  ) {
    return alerts.where((alert) {
      // Filter by severity
      if (_filterSeverity != 'All') {
        final severityMatch =
            alert.severity.toString().split('.').last.toLowerCase() ==
            _filterSeverity.toLowerCase();
        if (!severityMatch) return false;
      }

      // Filter by acknowledged status
      if (!_showAcknowledged && alert.acknowledged) {
        return false;
      }

      return true;
    }).toList();
  }
}
