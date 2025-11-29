import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../controller/admin_controller.dart';
import '../../controller/admin_user_controller.dart';
import '../../controller/admin_network_controller.dart';
import '../../controller/admin_analytics_controller.dart';
import '../../controller/admin_system_controller.dart';

class AdminAdvancedAnalytics extends StatefulWidget {
  const AdminAdvancedAnalytics({super.key});

  @override
  State<AdminAdvancedAnalytics> createState() => _AdminAdvancedAnalyticsState();
}

class _AdminAdvancedAnalyticsState extends State<AdminAdvancedAnalytics> {
  String _selectedTimeRange = 'Last 7 Days';
  String _selectedMetric = 'Overview';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadDashboardStats();
      context.read<AdminUserController>().loadUsers();
      context.read<AdminNetworkController>().loadNetworkElements();
      context.read<AdminNetworkController>().loadAlarms();
      context.read<AdminAnalyticsController>().loadPerformanceMetrics();
      context.read<AdminSystemController>().loadSystemHealth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildKPICards(),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 900) {
                  // Stack vertically on narrow screens
                  return Column(
                    children: [
                      _buildPerformanceTrends(),
                      const SizedBox(height: 24),
                      _buildDomainComparison(),
                      const SizedBox(height: 24),
                      _buildNetworkMap(),
                      const SizedBox(height: 24),
                      _buildAlarmDistribution(),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: Column(
                        children: [
                          _buildPerformanceTrends(),
                          const SizedBox(height: 24),
                          _buildDomainComparison(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildNetworkMap(),
                          const SizedBox(height: 24),
                          _buildAlarmDistribution(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  return Column(
                    children: [
                      _buildUserActivityChart(),
                      const SizedBox(height: 24),
                      _buildSystemResourcesChart(),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: _buildUserActivityChart()),
                    const SizedBox(width: 24),
                    Expanded(child: _buildSystemResourcesChart()),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            _buildDetailedMetrics(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isNarrow ? 'Analytics' : 'Advanced Analytics',
                        style: GoogleFonts.poppins(
                          fontSize: isNarrow ? 20 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isNarrow) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Comprehensive insights across all domains',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white60,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isNarrow) ...[
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.file_download_outlined,
                      color: Colors.white60,
                    ),
                    tooltip: 'Export Report',
                  ),
                ],
              ],
            ),
            if (!isNarrow) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildFilterDropdown(
                    'Metric',
                    _selectedMetric,
                    ['Overview', 'Network', 'Users', 'System', 'Performance'],
                    (value) => setState(() => _selectedMetric = value!),
                  ),
                  _buildFilterDropdown(
                    'Time Range',
                    _selectedTimeRange,
                    [
                      'Last 24 Hours',
                      'Last 7 Days',
                      'Last 30 Days',
                      'Last 90 Days',
                    ],
                    (value) => setState(() => _selectedTimeRange = value!),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
          ),
          Flexible(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                dropdownColor: const Color(0xFF0d1117),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white60,
                  size: 20,
                ),
                items: items
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICards() {
    return Consumer4<
      AdminController,
      AdminUserController,
      AdminNetworkController,
      AdminSystemController
    >(
      builder: (context, adminCtrl, userCtrl, networkCtrl, systemCtrl, _) {
        final stats = adminCtrl.systemStats;
        return LayoutBuilder(
          builder: (context, constraints) {
            // Use wrap for very narrow screens
            if (constraints.maxWidth < 600) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: constraints.maxWidth,
                    child: _buildKPICard(
                      'Total Users',
                      '${stats.totalUsers}',
                      '${stats.activeUsers} active',
                      Icons.people_outline,
                      const Color(0xFF3b82f6),
                      '+12%',
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth,
                    child: _buildKPICard(
                      'Network Elements',
                      '${networkCtrl.networkElements.length}',
                      'Across all domains',
                      Icons.router_outlined,
                      const Color(0xFF10b981),
                      '+5%',
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth,
                    child: _buildKPICard(
                      'Active Alarms',
                      '${stats.criticalAlarms + stats.majorAlarms + stats.minorAlarms}',
                      '${stats.criticalAlarms} critical',
                      Icons.warning_amber_outlined,
                      const Color(0xFFef4444),
                      '-8%',
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth,
                    child: _buildKPICard(
                      'System Uptime',
                      '${stats.systemUptime.toStringAsFixed(2)}%',
                      'Last 30 days',
                      Icons.timer_outlined,
                      const Color(0xFF8b5cf6),
                      '+0.2%',
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _buildKPICard(
                    'Total Users',
                    '${stats.totalUsers}',
                    '${stats.activeUsers} active',
                    Icons.people_outline,
                    const Color(0xFF3b82f6),
                    '+12%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKPICard(
                    'Network Elements',
                    '${networkCtrl.networkElements.length}',
                    'Across all domains',
                    Icons.router_outlined,
                    const Color(0xFF10b981),
                    '+5%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKPICard(
                    'Active Alarms',
                    '${stats.criticalAlarms + stats.majorAlarms + stats.minorAlarms}',
                    '${stats.criticalAlarms} critical',
                    Icons.warning_amber_outlined,
                    const Color(0xFFef4444),
                    '-8%',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKPICard(
                    'System Uptime',
                    '${stats.systemUptime.toStringAsFixed(2)}%',
                    'Last 30 days',
                    Icons.timer_outlined,
                    const Color(0xFF8b5cf6),
                    '+0.2%',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildKPICard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    String change,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: '$title: $value\n$subtitle\nChange: $change',
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0d1117),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF21262d)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: change.startsWith('+')
                            ? const Color(0xFF10b981).withOpacity(0.1)
                            : const Color(0xFFef4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        change,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: change.startsWith('+')
                              ? const Color(0xFF10b981)
                              : const Color(0xFFef4444),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white60),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.white38),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceTrends() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Trends',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Network response time over time',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildLegendItem('Latency', const Color(0xFF3b82f6)),
                  const SizedBox(width: 16),
                  _buildLegendItem('Throughput', const Color(0xFF10b981)),
                  const SizedBox(width: 16),
                  _buildLegendItem('Packet Loss', const Color(0xFFf59e0b)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: _buildLineChart()),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return Consumer<AdminAnalyticsController>(
      builder: (context, controller, _) {
        final data = controller.networkPerformanceTrends;
        return CustomPaint(
          painter: LineChartPainter(data: data),
          child: Container(),
        );
      },
    );
  }

  Widget _buildDomainComparison() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Domain Performance Comparison',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'RAN, CORE, and IP transport metrics',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
          ),
          const SizedBox(height: 24),
          SizedBox(height: 250, child: _buildBarChart()),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return Consumer<AdminNetworkController>(
      builder: (context, controller, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBarGroup(
              'RAN',
              [85, 92, 78],
              ['Elements', 'Uptime', 'Performance'],
              const Color(0xFF3b82f6),
            ),
            _buildBarGroup(
              'CORE',
              [90, 88, 85],
              ['Elements', 'Uptime', 'Performance'],
              const Color(0xFF10b981),
            ),
            _buildBarGroup(
              'IP',
              [82, 95, 88],
              ['Elements', 'Uptime', 'Performance'],
              const Color(0xFFf59e0b),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBarGroup(
    String domain,
    List<int> values,
    List<String> labels,
    Color color,
  ) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Tooltip(
                message: '${labels[index]}: ${values[index]}%',
                child: Container(
                  width: 40,
                  height: values[index] * 2.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.6), color],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            domain,
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

  Widget _buildNetworkMap() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Network Distribution',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Geographic element spread',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
          ),
          const SizedBox(height: 24),
          AspectRatio(aspectRatio: 1, child: _buildMapVisualization()),
          const SizedBox(height: 16),
          _buildMapLegend(),
        ],
      ),
    );
  }

  Widget _buildMapVisualization() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161b22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Stack(
        children: [
          CustomPaint(painter: GridPainter(), size: Size.infinite),
          ...List.generate(8, (index) {
            final positions = [
              const Offset(0.2, 0.3),
              const Offset(0.7, 0.2),
              const Offset(0.5, 0.6),
              const Offset(0.3, 0.7),
              const Offset(0.8, 0.5),
              const Offset(0.6, 0.4),
              const Offset(0.4, 0.5),
              const Offset(0.65, 0.75),
            ];
            final colors = [
              const Color(0xFF3b82f6),
              const Color(0xFF10b981),
              const Color(0xFFf59e0b),
            ];
            return Positioned(
              left: positions[index].dx * 280,
              top: positions[index].dy * 280,
              child: Tooltip(
                message:
                    'Region ${index + 1}\n${20 + index * 5} elements\n${index % 2 == 0 ? 'Active' : 'Partial'}',
                child: Container(
                  width: 24 + (index % 3) * 8.0,
                  height: 24 + (index % 3) * 8.0,
                  decoration: BoxDecoration(
                    color: colors[index % 3].withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(color: colors[index % 3], width: 2),
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors[index % 3],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMapLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('RAN', const Color(0xFF3b82f6)),
        _buildLegendItem('CORE', const Color(0xFF10b981)),
        _buildLegendItem('IP', const Color(0xFFf59e0b)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildAlarmDistribution() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alarm Distribution',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'By severity level',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
          ),
          const SizedBox(height: 24),
          AspectRatio(aspectRatio: 1, child: _buildDonutChart()),
          const SizedBox(height: 16),
          _buildAlarmStats(),
        ],
      ),
    );
  }

  Widget _buildDonutChart() {
    return Consumer<AdminNetworkController>(
      builder: (context, controller, _) {
        var critical = controller.alarms
            .where((a) => a.severity == 'Critical')
            .length;
        var major = controller.alarms
            .where((a) => a.severity == 'Major')
            .length;
        var minor = controller.alarms
            .where((a) => a.severity == 'Minor')
            .length;

        // Use mock data if no alarms exist
        if (critical == 0 && major == 0 && minor == 0) {
          critical =
              23; // Critical: Link Down, CPU Threshold, Memory Exhaustion
          major = 47; // Major: High Latency, Packet Loss, Interface Errors
          minor = 89; // Minor: Config Warnings, Low Priority Events
        }

        return CustomPaint(
          painter: DonutChartPainter(
            critical: critical,
            major: major,
            minor: minor,
          ),
        );
      },
    );
  }

  Widget _buildAlarmStats() {
    return Consumer<AdminNetworkController>(
      builder: (context, controller, _) {
        var critical = controller.alarms
            .where((a) => a.severity == 'Critical')
            .length;
        var major = controller.alarms
            .where((a) => a.severity == 'Major')
            .length;
        var minor = controller.alarms
            .where((a) => a.severity == 'Minor')
            .length;

        // Use mock data if no alarms exist
        if (critical == 0 && major == 0 && minor == 0) {
          critical =
              23; // Critical: Link Down, CPU Threshold, Memory Exhaustion
          major = 47; // Major: High Latency, Packet Loss, Interface Errors
          minor = 89; // Minor: Config Warnings, Low Priority Events
        }

        return Column(
          children: [
            _buildStatRow(
              'Critical',
              critical,
              const Color(0xFFef4444),
              'Link Down, CPU >90%, Memory Fault',
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              'Major',
              major,
              const Color(0xFFf59e0b),
              'High Latency, Packet Loss >5%',
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              'Minor',
              minor,
              const Color(0xFFfbbf24),
              'Config Warnings, Threshold Events',
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(
    String label,
    int value,
    Color color, [
    String? description,
  ]) {
    return Tooltip(
      message: description ?? '$label: $value alarms',
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
            ),
          ),
          Text(
            '$value',
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

  Widget _buildUserActivityChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Activity',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Daily active users trend',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
          ),
          const SizedBox(height: 24),
          SizedBox(height: 150, child: _buildActivityBars()),
        ],
      ),
    );
  }

  Widget _buildActivityBars() {
    return Consumer<AdminAnalyticsController>(
      builder: (context, controller, _) {
        final data = controller.userActivityTrends;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final value = data.isNotEmpty
                ? (data[index % data.length]['count'] as int? ?? 0)
                : (20 + index * 5);
            return Tooltip(
              message: 'Day ${index + 1}: $value users',
              child: Container(
                width: 30,
                height: (value.toDouble() / 50) * 150,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3b82f6), Color(0xFF8b5cf6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSystemResourcesChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Resources',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current utilization levels',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
          ),
          const SizedBox(height: 24),
          _buildResourceMeters(),
        ],
      ),
    );
  }

  Widget _buildResourceMeters() {
    return Consumer<AdminSystemController>(
      builder: (context, controller, _) {
        final health = controller.systemHealth;
        return Column(
          children: [
            _buildMeterRow(
              'CPU',
              health['cpuUsage'] ?? 0,
              const Color(0xFF3b82f6),
            ),
            const SizedBox(height: 16),
            _buildMeterRow(
              'Memory',
              health['memoryUsage'] ?? 0,
              const Color(0xFF10b981),
            ),
            const SizedBox(height: 16),
            _buildMeterRow(
              'Disk',
              health['diskUsage'] ?? 0,
              const Color(0xFFf59e0b),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMeterRow(String label, num value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
            ),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 8,
            backgroundColor: const Color(0xFF21262d),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedMetrics() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Metrics',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Consumer4<
            AdminController,
            AdminUserController,
            AdminNetworkController,
            AdminAnalyticsController
          >(
            builder: (context, adminCtrl, userCtrl, networkCtrl, analyticsCtrl, _) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildMetricTile(
                    'Avg Response Time',
                    '${analyticsCtrl.performanceMetrics['avgResponseTime'] ?? 0}ms',
                    Icons.speed,
                    const Color(0xFF3b82f6),
                  ),
                  _buildMetricTile(
                    'Success Rate',
                    '${analyticsCtrl.performanceMetrics['successRate'] ?? 0}%',
                    Icons.check_circle,
                    const Color(0xFF10b981),
                  ),
                  _buildMetricTile(
                    'Total Requests',
                    '${analyticsCtrl.performanceMetrics['totalRequests'] ?? 0}',
                    Icons.api,
                    const Color(0xFF8b5cf6),
                  ),
                  _buildMetricTile(
                    'Network Throughput',
                    '${analyticsCtrl.performanceMetrics['networkThroughput'] ?? 0} Mbps',
                    Icons.network_check,
                    const Color(0xFFf59e0b),
                  ),
                  _buildMetricTile(
                    'Active Sessions',
                    '${adminCtrl.systemStats.activeSessions}',
                    Icons.desktop_windows,
                    const Color(0xFF06b6d4),
                  ),
                  _buildMetricTile(
                    'Incident Response',
                    '< 5 min',
                    Icons.timer,
                    const Color(0xFFec4899),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive width: aim for 3 tiles per row on normal screens
        final parentWidth = MediaQuery.of(context).size.width;
        final availableWidth = parentWidth - 120; // Account for padding
        final tileWidth = (availableWidth / 3).clamp(180.0, 300.0);

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Tooltip(
            message: title,
            child: Container(
              width: tileWidth,
              constraints: const BoxConstraints(minWidth: 180, maxWidth: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161b22),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF21262d)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  LineChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF3b82f6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final paint2 = Paint()
      ..color = const Color(0xFF10b981)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final paint3 = Paint()
      ..color = const Color(0xFFf59e0b)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const points = 30;
    final path1 = Path();
    final path2 = Path();
    final path3 = Path();

    for (int i = 0; i < points; i++) {
      final x = (size.width / (points - 1)) * i;
      final y1 =
          size.height -
          (size.height *
              (0.3 +
                  math.sin(i / 3) * 0.2 +
                  math.Random(i).nextDouble() * 0.1));
      final y2 =
          size.height -
          (size.height *
              (0.5 +
                  math.cos(i / 4) * 0.15 +
                  math.Random(i + 1).nextDouble() * 0.1));
      final y3 =
          size.height -
          (size.height *
              (0.2 +
                  math.sin(i / 5) * 0.1 +
                  math.Random(i + 2).nextDouble() * 0.05));

      if (i == 0) {
        path1.moveTo(x, y1);
        path2.moveTo(x, y2);
        path3.moveTo(x, y3);
      } else {
        path1.lineTo(x, y1);
        path2.lineTo(x, y2);
        path3.lineTo(x, y3);
      }
    }

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DonutChartPainter extends CustomPainter {
  final int critical;
  final int major;
  final int minor;

  DonutChartPainter({
    required this.critical,
    required this.major,
    required this.minor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final total = critical + major + minor;

    if (total == 0) return;

    final paint1 = Paint()
      ..color = const Color(0xFFef4444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30;
    final paint2 = Paint()
      ..color = const Color(0xFFf59e0b)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30;
    final paint3 = Paint()
      ..color = const Color(0xFFfbbf24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30;

    var startAngle = -math.pi / 2;
    final angle1 = (critical / total) * 2 * math.pi;
    final angle2 = (major / total) * 2 * math.pi;
    final angle3 = (minor / total) * 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 15),
      startAngle,
      angle1,
      false,
      paint1,
    );
    startAngle += angle1;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 15),
      startAngle,
      angle2,
      false,
      paint2,
    );
    startAngle += angle2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 15),
      startAngle,
      angle3,
      false,
      paint3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF21262d)
      ..strokeWidth = 1;
    for (double i = 0; i <= size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
