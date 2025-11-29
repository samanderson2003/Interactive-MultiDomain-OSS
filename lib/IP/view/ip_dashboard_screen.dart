import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../controller/ip_controller.dart';
import '../model/network_link_model.dart';

class IPDashboardScreen extends StatefulWidget {
  const IPDashboardScreen({super.key});

  @override
  State<IPDashboardScreen> createState() => _IPDashboardScreenState();
}

class _IPDashboardScreenState extends State<IPDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IPController>().loadDashboardData();
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
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildBandwidthMetrics(context),
                    const SizedBox(height: 16),
                    _buildNetworkTopologyPreview(context),
                    const SizedBox(height: 16),
                    _buildCriticalLinks(context),
                    const SizedBox(height: 16),
                    _buildQuickStats(context),
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

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF131823),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'IP Transport',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFf59e0b).withOpacity(0.1),
                const Color(0xFF131823),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Consumer<IPController>(
          builder: (context, controller, _) {
            final alertCount = controller.alerts
                .where((a) => !a.acknowledged)
                .length;
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/ip-alerts'),
                ),
                if (alertCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        alertCount > 9 ? '9+' : alertCount.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => context.read<IPController>().refresh(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBandwidthMetrics(BuildContext context) {
    return Consumer<IPController>(
      builder: (context, controller, _) {
        final metrics = controller.metrics;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bandwidth Overview',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildMetricCard(
                  'Total Capacity',
                  '${metrics.totalCapacityGbps} Gbps',
                  Icons.storage,
                  Colors.blue,
                ),
                _buildMetricCard(
                  'Current Utilization',
                  '${metrics.currentUtilizationPercent.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.orange,
                ),
                _buildMetricCard(
                  'Available',
                  '${metrics.availableBandwidthGbps} Gbps',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildMetricCard(
                  'Peak Utilization',
                  '${metrics.peakUtilizationPercent.toStringAsFixed(1)}%',
                  Icons.schedule,
                  Colors.red,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return FadeIn(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131823),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalLinks(BuildContext context) {
    return Consumer<IPController>(
      builder: (context, controller, _) {
        final criticalLinks = controller.criticalLinks;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Critical Links (>80%)',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/ip-links'),
                  child: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFf59e0b),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (criticalLinks.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF131823),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'No critical links at this time',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ),
              )
            else
              ...criticalLinks.map((link) => _buildLinkCard(link)),
          ],
        );
      },
    );
  }

  Widget _buildLinkCard(NetworkLinkModel link) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131823),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: link.utilizationColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: link.utilizationColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${link.fromNodeName} → ${link.toNodeName}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${link.capacityGbps} Gbps • ${link.latencyMs.toStringAsFixed(1)}ms latency',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${link.utilizationPercent.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: link.utilizationColor,
                  ),
                ),
                Text(
                  link.statusLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: link.statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer<IPController>(
      builder: (context, controller, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLatencyHeatmap(controller),
            const SizedBox(height: 24),
            _buildPacketLossStats(controller),
          ],
        );
      },
    );
  }

  Widget _buildLatencyHeatmap(IPController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latency per Link',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...controller.links.map((link) => _buildLatencyBar(link)),
        ],
      ),
    );
  }

  Widget _buildLatencyBar(NetworkLinkModel link) {
    final latencyPercent = (link.latencyMs / 100).clamp(0.0, 1.0);
    final color = latencyPercent > 0.5
        ? Colors.red
        : latencyPercent > 0.3
        ? Colors.orange
        : Colors.green;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${link.fromNodeName} → ${link.toNodeName}',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${link.latencyMs.toStringAsFixed(1)} ms',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: latencyPercent,
              backgroundColor: const Color(0xFF0a0e1a),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPacketLossStats(IPController controller) {
    final criticalLinks = controller.links
        .where((l) => l.packetLossPercent > 1)
        .toList();
    final warningLinks = controller.links
        .where((l) => l.packetLossPercent > 0.5 && l.packetLossPercent <= 1)
        .toList();
    final healthyLinks = controller.links
        .where((l) => l.packetLossPercent <= 0.5)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Packet Loss Statistics',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPacketLossCard(
                  'Critical',
                  criticalLinks.length,
                  Colors.red,
                  '> 1%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPacketLossCard(
                  'Warning',
                  warningLinks.length,
                  Colors.orange,
                  '0.5-1%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPacketLossCard(
                  'Healthy',
                  healthyLinks.length,
                  Colors.green,
                  '< 0.5%',
                ),
              ),
            ],
          ),
          if (criticalLinks.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Critical Links',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            ...criticalLinks.map((link) => _buildPacketLossLinkItem(link)),
          ],
        ],
      ),
    );
  }

  Widget _buildPacketLossCard(
    String label,
    int count,
    Color color,
    String range,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            range,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPacketLossLinkItem(NetworkLinkModel link) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0a0e1a),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${link.fromNodeName} → ${link.toNodeName}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${link.packetLossPercent.toStringAsFixed(2)}%',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkTopologyPreview(BuildContext context) {
    return Consumer<IPController>(
      builder: (context, controller, _) {
        return FadeInUp(
          child: Container(
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFF131823),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFf59e0b).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Network Topology',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/ip-topology'),
                        icon: const Icon(Icons.open_in_full, size: 16),
                        label: const Text('View Full'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFf59e0b),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: MiniTopologyPainter(
                          routers: controller.routers,
                          links: controller.links,
                        ),
                        size: Size.infinite,
                      ),
                      Positioned(
                        bottom: 12,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0a0e1a).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFf59e0b).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '${controller.routers.length} Routers • ${controller.links.length} Links',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingBotAnimation(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/ip-bot');
        },
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
}

class MiniTopologyPainter extends CustomPainter {
  final List<dynamic> routers;
  final List<dynamic> links;

  MiniTopologyPainter({required this.routers, required this.links});

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);

    const scale = 0.2;
    final offsetX = size.width / 2 - (500 * scale);
    final offsetY = size.height / 2 - (300 * scale);

    for (final link in links) {
      _drawMiniLink(canvas, link, scale, offsetX, offsetY);
    }

    for (final router in routers) {
      _drawMiniRouter(canvas, router, scale, offsetX, offsetY);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y <= size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawMiniLink(
    Canvas canvas,
    dynamic link,
    double scale,
    double offsetX,
    double offsetY,
  ) {
    final fromRouter = routers.firstWhere((r) => r.id == link.fromNodeId);
    final toRouter = routers.firstWhere((r) => r.id == link.toNodeId);

    final fromPos = Offset(
      fromRouter.position.dx * scale + offsetX,
      fromRouter.position.dy * scale + offsetY,
    );
    final toPos = Offset(
      toRouter.position.dx * scale + offsetX,
      toRouter.position.dy * scale + offsetY,
    );

    final paint = Paint()
      ..color = link.utilizationColor.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (link.utilizationPercent >= 80) {
      final glowPaint = Paint()
        ..color = link.utilizationColor.withOpacity(0.3)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawLine(fromPos, toPos, glowPaint);
    }

    canvas.drawLine(fromPos, toPos, paint);
  }

  void _drawMiniRouter(
    Canvas canvas,
    dynamic router,
    double scale,
    double offsetX,
    double offsetY,
  ) {
    final pos = Offset(
      router.position.dx * scale + offsetX,
      router.position.dy * scale + offsetY,
    );

    final size = router.nodeSize * scale * 0.5;

    if (router.type.toString().contains('core')) {
      final glowPaint = Paint()
        ..color = const Color(0xFFf59e0b).withOpacity(0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(pos, size + 4, glowPaint);
    }

    final bgPaint = Paint()
      ..color = const Color(0xFF131823)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, size, bgPaint);

    final borderPaint = Paint()
      ..color = _getRouterColor(router)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(pos, size, borderPaint);

    final centerPaint = Paint()
      ..color = _getRouterColor(router)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, size * 0.3, centerPaint);
  }

  Color _getRouterColor(dynamic router) {
    final type = router.type.toString().split('.').last;
    switch (type) {
      case 'core':
        return const Color(0xFFf59e0b);
      case 'edge':
        return const Color(0xFF0ea5e9);
      case 'access':
        return const Color(0xFF8b5cf6);
      default:
        return Colors.white;
    }
  }

  @override
  bool shouldRepaint(MiniTopologyPainter oldDelegate) => true;
}
