import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../controller/admin_controller.dart';

class AdminOverviewDashboard extends StatefulWidget {
  const AdminOverviewDashboard({super.key});

  @override
  State<AdminOverviewDashboard> createState() => _AdminOverviewDashboardState();
}

class _AdminOverviewDashboardState extends State<AdminOverviewDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: Consumer<AdminController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFef4444)),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildKPICards(controller),
                    const SizedBox(height: 24),
                    _buildChartsRow(controller),
                    const SizedBox(height: 24),
                    _buildNetworkOverview(controller),
                    const SizedBox(height: 24),
                    _buildRecentActivity(controller),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0d1117),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          children: [
            Text(
              'Admin Dashboard',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFef4444).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFef4444).withOpacity(0.3),
                ),
              ),
              child: Text(
                'LIVE',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFef4444),
                ),
              ),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
      ),
      actions: [
        IconButton(
          onPressed: () {
            context.read<AdminController>().refresh();
          },
          icon: const Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildKPICards(AdminController controller) {
    final stats = controller.systemStats;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              _buildKPICard(
                title: 'Total Users',
                value: stats.totalUsers.toString(),
                subtitle: '+${stats.activeUsers} active',
                icon: Icons.people_outline,
                color: const Color(0xFF3b82f6),
                trend: '+12%',
              ),
              const SizedBox(height: 16),
              _buildKPICard(
                title: 'Active Sessions',
                value: stats.activeSessions.toString(),
                subtitle: 'Online now',
                icon: Icons.computer_outlined,
                color: const Color(0xFF10b981),
                trend: '+5%',
              ),
              const SizedBox(height: 16),
              _buildKPICard(
                title: 'Network Elements',
                value: stats.totalNetworkElements.toString(),
                subtitle: 'Across all domains',
                icon: Icons.router_outlined,
                color: const Color(0xFFf59e0b),
                trend: '+3%',
              ),
              const SizedBox(height: 16),
              _buildKPICard(
                title: 'System Uptime',
                value: '${stats.systemUptime.toStringAsFixed(2)}%',
                subtitle: 'Last 30 days',
                icon: Icons.trending_up_outlined,
                color: const Color(0xFF8b5cf6),
                trend: '+0.2%',
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildKPICard(
                title: 'Total Users',
                value: stats.totalUsers.toString(),
                subtitle: '+${stats.activeUsers} active',
                icon: Icons.people_outline,
                color: const Color(0xFF3b82f6),
                trend: '+12%',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                title: 'Active Sessions',
                value: stats.activeSessions.toString(),
                subtitle: 'Online now',
                icon: Icons.computer_outlined,
                color: const Color(0xFF10b981),
                trend: '+5%',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                title: 'Network Elements',
                value: stats.totalNetworkElements.toString(),
                subtitle: 'Across all domains',
                icon: Icons.router_outlined,
                color: const Color(0xFFf59e0b),
                trend: '+3%',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKPICard(
                title: 'System Uptime',
                value: '${stats.systemUptime.toStringAsFixed(2)}%',
                subtitle: 'Last 30 days',
                icon: Icons.trending_up_outlined,
                color: const Color(0xFF8b5cf6),
                trend: '+0.2%',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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
                    color: const Color(0xFF10b981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trend,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10b981),
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
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white.withOpacity(0.4),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsRow(AdminController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildAlarmsChart(controller)),
        const SizedBox(width: 24),
        Expanded(flex: 2, child: _buildRoleDistributionChart(controller)),
      ],
    );
  }

  Widget _buildAlarmsChart(AdminController controller) {
    final stats = controller.systemStats;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alarm Status',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Last 24 Hours',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildAlarmBar(
                  'Critical',
                  stats.criticalAlarms,
                  const Color(0xFFef4444),
                  stats.criticalAlarms + stats.majorAlarms + stats.minorAlarms,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAlarmBar(
                  'Major',
                  stats.majorAlarms,
                  const Color(0xFFf59e0b),
                  stats.criticalAlarms + stats.majorAlarms + stats.minorAlarms,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAlarmBar(
                  'Minor',
                  stats.minorAlarms,
                  const Color(0xFFfbbf24),
                  stats.criticalAlarms + stats.majorAlarms + stats.minorAlarms,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmBar(String label, int value, Color color, int total) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;

    return Column(
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                height: 150 * (percentage / 100),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color.withOpacity(0.8), color],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value.toString(),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleDistributionChart(AdminController controller) {
    final roleDistribution = controller.roleDistribution;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Roles',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: CustomPaint(
              size: const Size(150, 150),
              painter: DonutChartPainter(roleDistribution),
            ),
          ),
          const SizedBox(height: 24),
          _buildRoleLegendItem(
            'Admin',
            roleDistribution.adminCount,
            const Color(0xFFef4444),
          ),
          _buildRoleLegendItem(
            'RAN Engineer',
            roleDistribution.ranEngineerCount,
            const Color(0xFF3b82f6),
          ),
          _buildRoleLegendItem(
            'CORE Engineer',
            roleDistribution.coreEngineerCount,
            const Color(0xFF10b981),
          ),
          _buildRoleLegendItem(
            'IP Engineer',
            roleDistribution.ipEngineerCount,
            const Color(0xFFf59e0b),
          ),
          _buildRoleLegendItem(
            'NOC Manager',
            roleDistribution.nocManagerCount,
            const Color(0xFF8b5cf6),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleLegendItem(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            count.toString(),
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkOverview(AdminController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Network Domain Overview',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: controller.domainStats.map((domain) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildDomainCard(domain),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainCard(domain) {
    final colors = {
      'RAN': const Color(0xFF10b981),
      'CORE': const Color(0xFF3b82f6),
      'IP Transport': const Color(0xFFf59e0b),
    };

    final color = colors[domain.domain] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.router, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            domain.domain,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildDomainStat('Total', domain.totalElements),
          const SizedBox(height: 8),
          _buildDomainStat('Active', domain.activeElements, color),
          const SizedBox(height: 8),
          _buildDomainStat('Alarms', domain.alarms, const Color(0xFFef4444)),
        ],
      ),
    );
  }

  Widget _buildDomainStat(String label, int value, [Color? valueColor]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        Text(
          value.toString(),
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(AdminController controller) {
    final activities = controller.recentActivities.take(10).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Navigate to full activity logs
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View All'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFef4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (activities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No recent activities',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            )
          else
            ...activities.map((activity) => _buildActivityItem(activity)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(activity) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3b82f6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.history,
              color: Color(0xFF3b82f6),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${activity.userName} • ${_formatTimestamp(activity.timestamp)}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
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
}

// Custom Painter for Donut Chart
class DonutChartPainter extends CustomPainter {
  final roleDistribution;

  DonutChartPainter(this.roleDistribution);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final innerRadius = radius * 0.6;

    final total = roleDistribution.total;
    if (total == 0) return;

    double startAngle = -math.pi / 2;

    final colors = [
      const Color(0xFFef4444),
      const Color(0xFF3b82f6),
      const Color(0xFF10b981),
      const Color(0xFFf59e0b),
      const Color(0xFF8b5cf6),
    ];

    final values = [
      roleDistribution.adminCount,
      roleDistribution.ranEngineerCount,
      roleDistribution.coreEngineerCount,
      roleDistribution.ipEngineerCount,
      roleDistribution.nocManagerCount,
    ];

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius - innerRadius;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: (radius + innerRadius) / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) => true;
}
