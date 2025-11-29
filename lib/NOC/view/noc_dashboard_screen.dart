import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'dart:math';

// Assuming these imports exist and are correct
import '../controller/noc_controller.dart';
import '../model/noc_alarm_model.dart';
import '../model/alarm_severity.dart';
import '../model/alarm_status.dart';
import '../model/alarm_domain.dart';
import '../model/alarm_statistics_model.dart';
import '../../utils/constants.dart';

// --- NOC DASHBOARD SCREEN ---

class NOCDashboardScreen extends StatefulWidget {
  const NOCDashboardScreen({super.key});

  @override
  State<NOCDashboardScreen> createState() => _NOCDashboardScreenState();
}

class _NOCDashboardScreenState extends State<NOCDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Assuming NOCController provides the statistics data
      context.read<NOCController>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildCompactAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildCompactPriorityCards(context),
                    const SizedBox(height: 12),
                    _buildCompactMetricsGrid(context),
                    const SizedBox(height: 12),
                    _buildChartsRow(context),
                    const SizedBox(height: 12),
                    _buildHeatmapsRow(context),
                    const SizedBox(height: 12),
                    _buildAlarmsTablePreview(context),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
          _buildFloatingBotAnimation(context),
        ],
      ),
    );
  }

  Widget _buildCompactAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 50,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF131823),
      title: Row(
        children: [
          Text(
            'NOC Alarm Management',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white, size: 20),
          onPressed: () => Navigator.pushNamed(context, '/noc-profile'),
          tooltip: 'Profile',
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
          onPressed: () => context.read<NOCController>().refresh(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCompactPriorityCards(BuildContext context) {
    return Consumer<NOCController>(
      builder: (context, controller, _) {
        final criticalCount = controller.criticalAlarms.length;
        final majorCount = controller.majorAlarms.length;
        final minorCount = controller.minorAlarms.length;

        return Row(
          children: [
            if (criticalCount > 0)
              Expanded(
                child: _buildCompactPriorityCard(
                  context: context,
                  label: 'CRITICAL',
                  count: criticalCount,
                  color: const Color(0xFFef4444),
                  icon: Icons.error,
                  onTap: () {
                    controller.setFilterSeverity(AlarmSeverity.critical);
                    controller.setFilterStatus(AlarmStatus.active);
                    Navigator.pushNamed(context, '/noc-alarm-table');
                  },
                ),
              ),
            if (criticalCount > 0 && (majorCount > 0 || minorCount > 0))
              const SizedBox(width: 8),
            if (majorCount > 0)
              Expanded(
                child: _buildCompactPriorityCard(
                  context: context,
                  label: 'MAJOR',
                  count: majorCount,
                  color: const Color(0xFFf59e0b),
                  icon: Icons.warning,
                  onTap: () {
                    controller.setFilterSeverity(AlarmSeverity.major);
                    controller.setFilterStatus(AlarmStatus.active);
                    Navigator.pushNamed(context, '/noc-alarm-table');
                  },
                ),
              ),
            if (majorCount > 0 && minorCount > 0) const SizedBox(width: 8),
            if (minorCount > 0)
              Expanded(
                child: _buildCompactPriorityCard(
                  context: context,
                  label: 'MINOR',
                  count: minorCount,
                  color: const Color(0xFFfbbf24),
                  icon: Icons.info,
                  onTap: () {
                    controller.setFilterSeverity(AlarmSeverity.minor);
                    controller.setFilterStatus(AlarmStatus.active);
                    Navigator.pushNamed(context, '/noc-alarm-table');
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCompactPriorityCard({
    required BuildContext context,
    required String label,
    required int count,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, color: color, size: 14),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$count',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Active Alarms',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactMetricsGrid(BuildContext context) {
    return Consumer<NOCController>(
      builder: (context, controller, _) {
        final criticalCount = controller.criticalAlarms.length;
        final majorCount = controller.majorAlarms.length;
        final minorCount = controller.minorAlarms.length;
        final activeCount = controller.alarms
            .where((a) => a.status == AlarmStatus.active)
            .length;
        final resolvedCount = controller.alarms
            .where((a) => a.status == AlarmStatus.resolved)
            .length;

        return Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Critical',
                criticalCount.toString(),
                const Color(0xFFef4444),
                Icons.error,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'Major',
                majorCount.toString(),
                const Color(0xFFf59e0b),
                Icons.warning,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'Minor',
                minorCount.toString(),
                const Color(0xFFfbbf24),
                Icons.info,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'Active',
                activeCount.toString(),
                DarkThemeColors.chartPink,
                Icons.notifications_active,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                'Resolved',
                resolvedCount.toString(),
                const Color(0xFF10b981),
                Icons.check_circle,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsRow(BuildContext context) {
    return Consumer<NOCController>(
      builder: (context, controller, _) {
        final stats = controller.statistics;
        if (stats == null) return const SizedBox.shrink();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Using the new StatefulWidget for Alarm Trends
            Expanded(flex: 2, child: AlarmTrendsCompact(stats)),
            const SizedBox(width: 12),
            // Using the new StatefulWidget for Domain Pie Chart
            Expanded(child: DomainPieChartCompact(stats)),
          ],
        );
      },
    );
  }

  Widget _buildHeatmapsRow(BuildContext context) {
    return Consumer<NOCController>(
      builder: (context, controller, _) {
        return Row(
          children: [
            Expanded(child: _buildAlarmHeatmap(controller)),
            const SizedBox(width: 12),
            Expanded(child: _buildTopAffectedElements(controller)),
          ],
        );
      },
    );
  }

  Widget _buildAlarmHeatmap(NOCController controller) {
    final alarms = controller.alarms.take(20).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DarkThemeColors.chartPink.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alarm Heatmap (Recent)',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: 100,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final hasAlarm = index < alarms.length;
                final color = hasAlarm
                    ? _getSeverityColor(alarms[index].severity)
                    : const Color(0xFF1a2030);
                return Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAffectedElements(NOCController controller) {
    final stats = controller.statistics;
    if (stats == null) return const SizedBox.shrink();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DarkThemeColors.chartPink.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Affected Elements',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: stats.topElements.length,
              itemBuilder: (context, index) {
                final element = stats.topElements[index];
                final percent = (element.alarmCount / stats.totalActive * 100)
                    .clamp(0, 100);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              element.elementName,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${element.alarmCount}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: DarkThemeColors.chartPink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percent / 100,
                        backgroundColor: const Color(0xFF1a2030),
                        valueColor: AlwaysStoppedAnimation(
                          _getDomainColor(element.domain.displayName),
                        ),
                        minHeight: 6,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmsTablePreview(BuildContext context) {
    return Consumer<NOCController>(
      builder: (context, controller, _) {
        final recentAlarms = controller.alarms.take(10).toList();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF131823),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: DarkThemeColors.chartPink.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Alarms',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/noc-alarm-table'),
                    child: Text(
                      'View All',
                      style: GoogleFonts.poppins(
                        color: DarkThemeColors.chartPink,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.2),
                  1: FlexColumnWidth(0.8),
                  2: FlexColumnWidth(0.8),
                  3: FlexColumnWidth(1.5),
                  4: FlexColumnWidth(2),
                  5: FlexColumnWidth(0.8),
                  6: FlexColumnWidth(1.2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1a2030),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    children: [
                      _buildTableHeader('Timestamp'),
                      _buildTableHeader('Domain'),
                      _buildTableHeader('Severity'),
                      _buildTableHeader('Element'),
                      _buildTableHeader('Description'),
                      _buildTableHeader('Status'),
                      _buildTableHeader('Action'),
                    ],
                  ),
                  ...recentAlarms.map(
                    (alarm) => _buildTableCell(alarm, controller, context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }

  TableRow _buildTableCell(
    NOCAlarm alarm,
    NOCController controller,
    BuildContext context,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            _formatTime(alarm.timestamp),
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getDomainColor(alarm.domain.displayName).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              alarm.domain.shortName,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _getDomainColor(alarm.domain.displayName),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getSeverityColor(alarm.severity).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              alarm.severity.displayName,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getSeverityColor(alarm.severity),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            alarm.element,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            alarm.description,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(alarm.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              alarm.status.displayName,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: _getStatusColor(alarm.status),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (alarm.status == AlarmStatus.active)
                Tooltip(
                  message: 'Acknowledge',
                  child: InkWell(
                    onTap: () =>
                        controller.acknowledgeAlarm(alarm.id, 'NOC Manager'),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: DarkThemeColors.chartPink,
                    ),
                  ),
                ),
              if (alarm.status == AlarmStatus.active) const SizedBox(width: 4),
              if (alarm.status == AlarmStatus.acknowledged ||
                  alarm.status == AlarmStatus.inProgress)
                Tooltip(
                  message: 'Assign to Engineer',
                  child: InkWell(
                    onTap: () {
                      _showAssignDialog(context, alarm, controller);
                    },
                    child: const Icon(
                      Icons.person_add,
                      size: 16,
                      color: Color(0xFF3b82f6),
                    ),
                  ),
                ),
              if (alarm.status == AlarmStatus.acknowledged ||
                  alarm.status == AlarmStatus.inProgress)
                const SizedBox(width: 4),
              Tooltip(
                message: 'View Details',
                child: InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/noc-alarm-detail',
                    arguments: alarm.id,
                  ),
                  child: const Icon(
                    Icons.visibility,
                    size: 16,
                    color: DarkThemeColors.chartPink,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: 'Add Comment',
                child: InkWell(
                  onTap: () {
                    _showCommentDialog(context, alarm, controller);
                  },
                  child: const Icon(
                    Icons.comment,
                    size: 16,
                    color: Color(0xFFfbbf24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAssignDialog(
    BuildContext context,
    NOCAlarm alarm,
    NOCController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131823),
        title: Text(
          'Assign Alarm',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Assign ${alarm.element} to:',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                'RAN Engineer',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward, color: Colors.white70),
              onTap: () {
                controller.assignAlarm(alarm.id, 'RAN Engineer');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'CORE Engineer',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward, color: Colors.white70),
              onTap: () {
                controller.assignAlarm(alarm.id, 'CORE Engineer');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'IP Engineer',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward, color: Colors.white70),
              onTap: () {
                controller.assignAlarm(alarm.id, 'IP Engineer');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentDialog(
    BuildContext context,
    NOCAlarm alarm,
    NOCController controller,
  ) {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131823),
        title: Text(
          'Add Comment',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: TextField(
          controller: commentController,
          style: GoogleFonts.poppins(color: Colors.white),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter your comment...',
            hintStyle: GoogleFonts.poppins(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF0a0e1a),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DarkThemeColors.chartPink,
            ),
            onPressed: () {
              if (commentController.text.isNotEmpty) {
                controller.addComment(
                  alarm.id,
                  'NOC Manager',
                  commentController.text,
                );
                Navigator.pop(context);
              }
            },
            child: Text('Add', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(AlarmSeverity severity) {
    switch (severity) {
      case AlarmSeverity.critical:
        return const Color(0xFFef4444);
      case AlarmSeverity.major:
        return const Color(0xFFf59e0b);
      case AlarmSeverity.minor:
        return const Color(0xFFfbbf24);
      case AlarmSeverity.warning:
        return const Color(0xFF3b82f6);
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Color _getDomainColor(String domain) {
    switch (domain) {
      case 'RAN':
        return const Color(0xFF10b981);
      case 'CORE':
        return const Color(0xFF3b82f6);
      case 'IP Transport':
        return const Color(0xFFf59e0b);
      case 'Transport':
        return const Color(0xFF8b5cf6);
      case 'Security':
        return const Color(0xFFef4444);
      case 'Application':
        return const Color(0xFFec4899);
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(AlarmStatus status) {
    switch (status) {
      case AlarmStatus.active:
        return const Color(0xFFef4444);
      case AlarmStatus.acknowledged:
        return const Color(0xFFf59e0b);
      case AlarmStatus.inProgress:
        return const Color(0xFF3b82f6);
      case AlarmStatus.resolved:
        return const Color(0xFF10b981);
      case AlarmStatus.closed:
        return Colors.grey;
    }
  }

  Widget _buildFloatingBotAnimation(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: GestureDetector(
        onTap: () => _showChatbotDialog(context),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Lottie.asset(
            'assets/loading bot.json',
            width: 70,
            height: 70,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  void _showChatbotDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => _ChatbotDialog());
  }
}

// -----------------------------------------------------------------------------
// --- NEW WIDGETS FOR CHART INTERACTIVITY (REPLACING OLD FUNCTIONS) ---
// -----------------------------------------------------------------------------

// --- Alarm Trends Line Chart (Stateful for Hover) ---

class AlarmTrendsCompact extends StatefulWidget {
  final AlarmStatistics stats;
  const AlarmTrendsCompact(this.stats, {super.key});

  @override
  State<AlarmTrendsCompact> createState() => _AlarmTrendsCompactState();
}

class _AlarmTrendsCompactState extends State<AlarmTrendsCompact> {
  int? _hoveredIndex;
  Offset? _hoverPosition;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DarkThemeColors.chartPink.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alarm Trends (7 Days)',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final dataLength = widget.stats.trends.length;
                return MouseRegion(
                  onHover: (event) {
                    setState(() {
                      _hoverPosition = event.localPosition;
                      _hoveredIndex = _calculateHoverIndex(
                        event.localPosition,
                        constraints.maxWidth,
                        dataLength,
                      );
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _hoveredIndex = null;
                      _hoverPosition = null;
                    });
                  },
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: AlarmTrendChartPainter(
                      widget.stats.trends,
                      hoveredIndex: _hoveredIndex,
                      hoverPosition: _hoverPosition,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int? _calculateHoverIndex(
    Offset localPosition,
    double chartWidth,
    int dataLength,
  ) {
    if (dataLength < 2) return null;
    const padding = 40.0;
    final contentWidth = chartWidth - padding * 2;
    if (contentWidth <= 0 ||
        localPosition.dx < padding ||
        localPosition.dx > contentWidth + padding) {
      return null;
    }
    final pointSpacing = contentWidth / (dataLength - 1);
    final x = localPosition.dx - padding;

    final index = (x / pointSpacing).round();
    return index.clamp(0, dataLength - 1);
  }
}

// --- Domain Pie Chart (Stateful for Hover) ---

class DomainPieChartCompact extends StatefulWidget {
  final AlarmStatistics stats;
  const DomainPieChartCompact(this.stats, {super.key});

  @override
  State<DomainPieChartCompact> createState() => _DomainPieChartCompactState();
}

class _DomainPieChartCompactState extends State<DomainPieChartCompact> {
  String? _hoveredDomain;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DarkThemeColors.chartPink.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'By Domain',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return MouseRegion(
                  onHover: (event) {
                    setState(() {
                      _hoveredDomain = _calculateHoverDomain(
                        event.localPosition,
                        constraints.biggest,
                      );
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _hoveredDomain = null;
                    });
                  },
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: DomainPieChartPainter(
                      widget.stats.byDomain,
                      hoveredDomain: _hoveredDomain,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String? _calculateHoverDomain(Offset localPosition, Size size) {
    const double pi = 3.1415926535897932;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height / 2 * 0.8;
    final centerRadius = radius * 0.5;

    final distanceSquared =
        (localPosition.dx - center.dx) * (localPosition.dx - center.dx) +
        (localPosition.dy - center.dy) * (localPosition.dy - center.dy);

    // Check if within the chart's outer radius and outside the center hole
    if (distanceSquared > radius * radius ||
        distanceSquared < centerRadius * centerRadius) {
      return null;
    }

    // Calculate angle of the cursor relative to the center
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    double angle = atan2(dy, dx); // atan2 gives angle from -pi to pi

    // Convert to 0 to 2*pi, where 0 is the positive X axis (3 o'clock)
    if (angle < 0) {
      angle += 2 * pi;
    }

    // Our painter starts drawing at -90 degrees (12 o'clock).
    // We adjust the mouse angle to match the painter's starting point.
    // The painter starts at pi/2 (90 degrees, positive Y axis).
    // The painter is drawing clockwise. We need to check the angle clockwise from the top.
    double adjustedAngle = (angle + pi / 2) % (2 * pi);

    final data = widget.stats.byDomain;
    final total = data.values.fold<int>(0, (sum, val) => sum + val);
    if (total == 0) return null;

    double cumulativeAngle = 0;
    for (final entry in data.entries) {
      final sweepAngle = (entry.value / total) * 2 * pi;
      cumulativeAngle += sweepAngle;

      if (adjustedAngle <= cumulativeAngle) {
        return entry.key.displayName;
      }
    }
    return null;
  }
}

// -----------------------------------------------------------------------------
// --- CUSTOM PAINTERS (MODIFIED FOR HOVER) ---
// -----------------------------------------------------------------------------

class DomainPieChartPainter extends CustomPainter {
  final Map<dynamic, int> data;
  final String? hoveredDomain;

  DomainPieChartPainter(this.data, {this.hoveredDomain});

  @override
  void paint(Canvas canvas, Size size) {
    const double pi = 3.1415926535897932;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.height / 2 * 0.8;

    final total = data.values.fold<int>(0, (sum, val) => sum + val);
    if (total == 0) return;

    double startAngle = -90 * pi / 180;

    final colors = [
      const Color(0xFF10b981), // RAN (Green)
      const Color(0xFF3b82f6), // CORE (Blue)
      const Color(0xFFf59e0b), // IP Transport (Orange)
      const Color(0xFF8b5cf6), // Transport (Purple)
      const Color(0xFFef4444), // Security (Red)
      const Color(0xFFec4899), // Application (Pink)
    ];

    int colorIndex = 0;
    data.forEach((key, value) {
      final sweepAngle = (value / total) * 2 * pi;
      final isHovered = key == hoveredDomain;

      final paint = Paint()
        ..color = isHovered
            ? colors[colorIndex % colors.length].withOpacity(0.8)
            : colors[colorIndex % colors.length]
        ..style = PaintingStyle.fill;

      // Slightly larger radius for hovered slice
      final drawRadius = isHovered ? radius * 1.05 : radius;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: drawRadius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
      colorIndex++;
    });

    // Draw center circle for donut effect
    final centerPaint = Paint()
      ..color = const Color(0xFF131823)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.5, centerPaint);

    // --- TOOLTIP DRAWING LOGIC (Centered Text) ---
    if (hoveredDomain != null) {
      final count = data[hoveredDomain] ?? 0;
      final percent = (count / total * 100).toStringAsFixed(1);

      final tooltipText = '$hoveredDomain\n$count Alarms ($percent%)';

      final textSpan = TextSpan(
        text: tooltipText,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      // Position the text in the center
      final textOffset = Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(DomainPieChartPainter oldDelegate) {
    return oldDelegate.hoveredDomain != hoveredDomain;
  }
}

class AlarmTrendChartPainter extends CustomPainter {
  final List<dynamic> trends;
  final int? hoveredIndex;
  final Offset? hoverPosition;

  AlarmTrendChartPainter(this.trends, {this.hoveredIndex, this.hoverPosition});

  @override
  void paint(Canvas canvas, Size size) {
    if (trends.isEmpty) return;

    final trendData = trends.cast<DailyAlarmTrend>();
    final maxValue = trendData
        .map((t) => t.total)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    const padding = 40.0;
    final chartHeight = size.height - padding * 2;
    final chartWidth = size.width - padding * 2;
    final pointSpacing = chartWidth / (trendData.length - 1);

    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = padding + (chartHeight / 4) * i;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        gridPaint,
      );
    }

    // Draw lines for each severity
    _drawLine(
      canvas,
      size,
      trendData.map((t) => t.critical.toDouble()).toList(),
      const Color(0xFFef4444),
      maxValue,
      padding,
      chartHeight,
      pointSpacing,
    );
    _drawLine(
      canvas,
      size,
      trendData.map((t) => t.major.toDouble()).toList(),
      const Color(0xFFf59e0b),
      maxValue,
      padding,
      chartHeight,
      pointSpacing,
    );
    _drawLine(
      canvas,
      size,
      trendData.map((t) => t.minor.toDouble()).toList(),
      const Color(0xFFfbbf24),
      maxValue,
      padding,
      chartHeight,
      pointSpacing,
    );

    // --- TOOLTIP DRAWING LOGIC ---
    if (hoveredIndex != null && hoverPosition != null) {
      final index = hoveredIndex!;
      final trend = trendData[index];

      final x = padding + pointSpacing * index;
      const yStart = padding;
      final yEnd = size.height - padding;

      // 1. Draw Hover Line
      final hoverLinePaint = Paint()
        ..color = DarkThemeColors.chartPink.withOpacity(0.7)
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(x, yStart), Offset(x, yEnd), hoverLinePaint);

      // 2. Prepare Tooltip Text
      final tooltipText =
          'Day ${index + 1}\nTotal: ${trend.total}\nCrit: ${trend.critical}\nMajor: ${trend.major}\nMinor: ${trend.minor}';

      final textSpan = TextSpan(
        text: tooltipText,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 9),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      // 3. Draw Tooltip Background
      const tooltipPadding = 8.0;
      double tooltipX = x + 5;
      // Adjust tooltip position if it goes off the right edge
      if (tooltipX + textPainter.width + tooltipPadding * 2 > size.width) {
        tooltipX = x - textPainter.width - tooltipPadding * 2 - 5;
      }

      final rect = Rect.fromLTWH(
        tooltipX,
        yStart + 5,
        textPainter.width + tooltipPadding * 2,
        textPainter.height + tooltipPadding * 2,
      );

      final tooltipPaint = Paint()
        ..color = const Color(0xFF1a2030).withOpacity(0.9);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        tooltipPaint,
      );

      // 4. Draw Tooltip Text
      textPainter.paint(
        canvas,
        Offset(rect.left + tooltipPadding, rect.top + tooltipPadding),
      );

      // 5. Draw Highlighted Dots
      _drawHighlightDot(
        canvas,
        x,
        size.height - padding - (trend.critical / maxValue * chartHeight),
        const Color(0xFFef4444),
      );
      _drawHighlightDot(
        canvas,
        x,
        size.height - padding - (trend.major / maxValue * chartHeight),
        const Color(0xFFf59e0b),
      );
      _drawHighlightDot(
        canvas,
        x,
        size.height - padding - (trend.minor / maxValue * chartHeight),
        const Color(0xFFfbbf24),
      );
    }
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<double> values,
    Color color,
    double maxValue,
    double padding,
    double chartHeight,
    double pointSpacing,
  ) {
    if (maxValue == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = padding + pointSpacing * i;
      final y = size.height - padding - (values[i] / maxValue * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw dots
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final x = padding + pointSpacing * i;
      final y = size.height - padding - (values[i] / maxValue * chartHeight);
      canvas.drawCircle(Offset(x, y), 2, dotPaint);
    }
  }

  void _drawHighlightDot(Canvas canvas, double x, double y, Color color) {
    final highlightPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 5, highlightPaint);
    final innerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 3, innerPaint);
  }

  @override
  bool shouldRepaint(AlarmTrendChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex;
  }
}

// -----------------------------------------------------------------------------
// --- CHATBOT WIDGETS (UNCHANGED) ---
// -----------------------------------------------------------------------------

class _ChatbotDialog extends StatefulWidget {
  @override
  State<_ChatbotDialog> createState() => _ChatbotDialogState();
}

class _ChatbotDialogState extends State<_ChatbotDialog> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      'Hello! I\'m your NOC Assistant. I can help you with:\n\n'
      '• Alarm analysis and troubleshooting\n'
      '• Network health status\n'
      '• Performance metrics\n'
      '• Historical trends\n'
      '• Best practices\n\n'
      'How can I assist you today?',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: const Color(0xFF131823),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DarkThemeColors.chartPink.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            _buildChatHeader(context),
            Expanded(child: _buildMessagesList()),
            if (_isTyping) _buildTypingIndicator(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DarkThemeColors.chartPink.withOpacity(0.2),
            const Color(0xFF131823),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: DarkThemeColors.chartPink,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.support_agent,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOC Assistant',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'AI-Powered Network Operations Support',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(false),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? DarkThemeColors.chartPink
                    : const Color(0xFF1a2030),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.text,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _buildAvatar(true),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF3b82f6) : DarkThemeColors.chartPink,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildAvatar(false),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1a2030),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, double value, child) {
        return Opacity(
          opacity: (value + index * 0.3) % 1,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a2030),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ask me anything about network operations...',
                hintStyle: GoogleFonts.poppins(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF131823),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: DarkThemeColors.chartPink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isTyping = false;
        _messages.add(
          ChatMessage(text: _generateResponse(userMessage), isUser: false),
        );
      });
      _scrollToBottom();
    });
  }

  String _generateResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('critical') || lowerMessage.contains('alarm')) {
      return 'I can see there are active critical alarms in the system. Let me help you prioritize:\n\n'
          '1. Check the alarm details in the dashboard\n'
          '2. Review the affected network elements\n'
          '3. Assign alarms to appropriate engineers\n'
          '4. Monitor resolution progress\n\n'
          'Would you like me to filter alarms by severity or domain?';
    } else if (lowerMessage.contains('trend') ||
        lowerMessage.contains('history')) {
      return 'Based on the alarm trends, I can provide insights:\n\n'
          '• The past 7 days show a pattern in alarm occurrences\n'
          '• Peak alarm times typically occur during network updates\n'
          '• Domain-specific trends indicate potential issues\n\n'
          'Would you like a detailed trend analysis for a specific domain?';
    } else if (lowerMessage.contains('help') || lowerMessage.contains('how')) {
      return 'I can assist you with:\n\n'
          '✓ Analyzing alarm patterns and root causes\n'
          '✓ Providing troubleshooting recommendations\n'
          '✓ Explaining network metrics and KPIs\n'
          '✓ Suggesting escalation procedures\n'
          '✓ Generating performance reports\n'
          'Just ask me about any specific topic!';
    } else if (lowerMessage.contains('status') ||
        lowerMessage.contains('health')) {
      return 'Current Network Health Status:\n\n'
          '🟢 Overall Status: Operational\n'
          '🔴 Critical Alarms: Require immediate attention\n'
          '🟡 Major Alarms: Being monitored\n'
          '⚪ Minor Alarms: Scheduled for review\n'
          'The system is functioning within acceptable parameters.';
    } else {
      return 'I understand you\'re asking about: "$userMessage"\n\n'
          'I can help you with network operations, alarm management, troubleshooting, and analytics. '
          'Could you provide more details about what you\'d like to know?';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
    });
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
