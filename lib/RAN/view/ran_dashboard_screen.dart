import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import '../controller/ran_controller.dart';
import '../model/bts_model.dart';
import '../model/alert_model.dart';
import 'dart:math' as math;

class RANDashboardScreen extends StatefulWidget {
  const RANDashboardScreen({super.key});

  @override
  State<RANDashboardScreen> createState() => _RANDashboardScreenState();
}

class _RANDashboardScreenState extends State<RANDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    // Initialize RAN controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RANController>().initialize();
    });

    // Pulse animation for network health
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Particle animation for critical alerts
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: Stack(
        children: [
          Consumer<RANController>(
            builder: (context, ranController, child) {
              if (ranController.isLoading) {
                return _buildLoadingState();
              }

              return CustomScrollView(
                slivers: [
                  _buildAppBar(context, ranController),
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildStatsCards(ranController),
                        const SizedBox(height: 24),
                        _buildQuickAccessGrid(context),
                        const SizedBox(height: 24),
                        _buildRecentAlertsPanel(ranController),
                        const SizedBox(height: 24),
                        _buildMiniCharts(ranController),
                        const SizedBox(height: 120), // Space for bot
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
          _buildFloatingBotAnimation(context),
        ],
      ),
    );
  }

  Widget _buildFloatingBotAnimation(BuildContext context) {
    return Positioned(
      right: 24,
      bottom: 24,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/ran-bot');
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Lottie.asset(
            'assets/loading bot.json',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(const Color(0xFF0ea5e9)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading RAN Dashboard...',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, RANController ranController) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: const Color(0xFF131823),
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0ea5e9).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.cell_tower,
                color: Color(0xFF0ea5e9),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'RAN Dashboard',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF131823), const Color(0xFF0a0e1a)],
            ),
          ),
        ),
      ),
      actions: [
        _buildNetworkHealthIndicator(ranController),
        const SizedBox(width: 16),
        _buildNotificationBell(ranController),
        const SizedBox(width: 16),
        _buildUserProfile(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildNetworkHealthIndicator(RANController ranController) {
    final healthPercentage =
        (ranController.activeBTS / ranController.totalBTS) * 100;
    final isHealthy = healthPercentage > 80;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                (isHealthy ? const Color(0xFF10b981) : const Color(0xFFef4444))
                    .withOpacity(0.1 + _pulseController.value * 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isHealthy
                  ? const Color(0xFF10b981)
                  : const Color(0xFFef4444),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isHealthy
                      ? const Color(0xFF10b981)
                      : const Color(0xFFef4444),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isHealthy
                                  ? const Color(0xFF10b981)
                                  : const Color(0xFFef4444))
                              .withOpacity(0.5),
                      blurRadius: 8 + _pulseController.value * 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${healthPercentage.toStringAsFixed(0)}% Health',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationBell(RANController ranController) {
    final criticalCount = ranController.criticalAlerts;

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
          onPressed: () {
            Navigator.pushNamed(context, '/ran-alerts');
          },
        ),
        if (criticalCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFef4444),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFFef4444,
                        ).withOpacity(0.5 + _particleController.value * 0.3),
                        blurRadius: 8,
                        spreadRadius: _particleController.value * 2,
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      '$criticalCount',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildUserProfile() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/ran-profile');
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF0ea5e9), width: 2),
          ),
          child: const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF1a2030),
            child: Icon(Icons.person, color: Color(0xFF0ea5e9), size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(RANController ranController) {
    return Row(
      children: [
        Expanded(
          child: FadeInUp(
            duration: const Duration(milliseconds: 400),
            child: _buildStatCard(
              'Total BTS',
              ranController.totalBTS.toString(),
              Icons.cell_tower,
              const Color(0xFF0ea5e9),
              '${ranController.activeBTS} Active',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: _buildStatCard(
              'Active BTS',
              ranController.activeBTS.toString(),
              Icons.check_circle,
              const Color(0xFF10b981),
              '${((ranController.activeBTS / ranController.totalBTS) * 100).toStringAsFixed(1)}%',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: _buildStatCard(
              'Inactive',
              ranController.inactiveBTS.toString(),
              Icons.cancel,
              const Color(0xFFef4444),
              'Critical',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FadeInUp(
            duration: const Duration(milliseconds: 700),
            child: _buildStatCard(
              'Avg Signal',
              '${ranController.averageSignalQuality.toStringAsFixed(1)} dBm',
              Icons.signal_cellular_alt,
              const Color(0xFF8b5cf6),
              ranController.averageSignalQuality > -85 ? 'Good' : 'Fair',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF131823),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1e293b), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _buildQuickAccessCard(
          'Interactive Map',
          Icons.map_outlined,
          const Color(0xFF0ea5e9),
          () => Navigator.pushNamed(context, '/ran-map'),
        ),
        _buildQuickAccessCard(
          'Analytics',
          Icons.analytics_outlined,
          const Color(0xFF8b5cf6),
          () => Navigator.pushNamed(context, '/ran-analytics'),
        ),
        _buildQuickAccessCard(
          'BTS List',
          Icons.list_alt_outlined,
          const Color(0xFF10b981),
          () => Navigator.pushNamed(context, '/ran-bts-list'),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 36),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAlertsPanel(RANController ranController) {
    final activeAlerts = ranController.getActiveAlerts().take(5).toList();

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF131823),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1e293b)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFef4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFef4444),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Recent Alerts',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/ran-alerts');
                    },
                    child: Text(
                      'View All',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF0ea5e9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1e293b), height: 1),
            if (activeAlerts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF10b981),
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No active alerts',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...activeAlerts.map((alert) => _buildAlertItem(alert)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(AlertModel alert) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1e293b), width: 1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: alert.severity.backgroundColor,
                shape: BoxShape.circle,
                boxShadow: alert.isCritical
                    ? [
                        BoxShadow(
                          color: alert.severity.color.withOpacity(
                            0.3 + _particleController.value * 0.2,
                          ),
                          blurRadius: 12,
                          spreadRadius: _particleController.value * 2,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                alert.severity.icon,
                color: alert.severity.color,
                size: 20,
              ),
            );
          },
        ),
        title: Text(
          alert.title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              alert.description,
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${alert.btsName} • ${alert.durationText}',
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: alert.severity.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: alert.severity.color.withOpacity(0.3)),
          ),
          child: Text(
            alert.severity.displayName,
            style: GoogleFonts.inter(
              color: alert.severity.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniCharts(RANController ranController) {
    return Row(
      children: [
        Expanded(
          child: FadeInUp(
            duration: const Duration(milliseconds: 700),
            child: _buildCapacityGauge(ranController),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FadeInUp(
            duration: const Duration(milliseconds: 800),
            child: _buildAlertsSummary(ranController),
          ),
        ),
      ],
    );
  }

  Widget _buildCapacityGauge(RANController ranController) {
    final capacity = ranController.averageCapacityUtilization;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1e293b)),
      ),
      child: Column(
        children: [
          Text(
            'Average Capacity',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 150,
            height: 150,
            child: CustomPaint(
              painter: GaugePainter(
                value: capacity,
                color: capacity > 85
                    ? const Color(0xFFef4444)
                    : capacity > 70
                    ? const Color(0xFFf59e0b)
                    : const Color(0xFF10b981),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${capacity.toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Utilized',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSummary(RANController ranController) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1e293b)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alerts Summary',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildAlertSummaryRow(
            'Critical',
            ranController.criticalAlerts,
            const Color(0xFFef4444),
          ),
          const SizedBox(height: 12),
          _buildAlertSummaryRow(
            'Major',
            ranController.majorAlerts,
            const Color(0xFFf97316),
          ),
          const SizedBox(height: 12),
          _buildAlertSummaryRow(
            'Warning',
            ranController.warningAlerts,
            const Color(0xFFfbbf24),
          ),
          const SizedBox(height: 12),
          _buildAlertSummaryRow(
            'Minor',
            ranController.minorAlerts,
            const Color(0xFF06b6d4),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertSummaryRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: GoogleFonts.inter(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for gauge chart
class GaugePainter extends CustomPainter {
  final double value;
  final Color color;

  GaugePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Background arc
    final backgroundPaint = Paint()
      ..color = const Color(0xFF1e293b)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      backgroundPaint,
    );

    // Foreground arc (value)
    final foregroundPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.6)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (value / 100) * math.pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      math.pi * 0.75,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
