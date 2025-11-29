import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controller/ip_controller.dart';
import '../model/router_node_model.dart';
import '../model/network_link_model.dart';

class IPTopologyScreen extends StatefulWidget {
  const IPTopologyScreen({super.key});

  @override
  State<IPTopologyScreen> createState() => _IPTopologyScreenState();
}

class _IPTopologyScreenState extends State<IPTopologyScreen> {
  String? _selectedRouterId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131823),
        title: Text(
          'Network Topology',
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
          return Stack(
            children: [
              InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(100),
                minScale: 0.5,
                maxScale: 3.0,
                child: Center(
                  child: CustomPaint(
                    painter: TopologyPainter(
                      routers: controller.routers,
                      links: controller.links,
                      selectedRouterId: _selectedRouterId,
                    ),
                    child: GestureDetector(
                      onTapUp: (details) {
                        _handleTap(details.localPosition, controller);
                      },
                      child: Container(
                        width: 1000,
                        height: 600,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
              if (_selectedRouterId != null) _buildNodeDetailPanel(controller),
            ],
          );
        },
      ),
    );
  }

  void _handleTap(Offset position, IPController controller) {
    for (final router in controller.routers) {
      final distance = (router.position - position).distance;
      if (distance < router.nodeSize) {
        setState(() {
          _selectedRouterId = router.id;
        });
        return;
      }
    }
    setState(() {
      _selectedRouterId = null;
    });
  }

  Widget _buildNodeDetailPanel(IPController controller) {
    final router = controller.routers.firstWhere(
      (r) => r.id == _selectedRouterId,
    );

    final connectedLinks = controller.links
        .where((l) => l.fromNodeId == router.id || l.toNodeId == router.id)
        .toList();

    return Positioned(
      right: 16,
      top: 16,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131823),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFf59e0b).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    router.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => setState(() => _selectedRouterId = null),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Type',
              router.type.toString().split('.').last.toUpperCase(),
            ),
            _buildDetailRow('IP', router.ipAddress),
            _buildDetailRow('Location', router.location),
            const SizedBox(height: 12),
            Text(
              'Connected Links (${connectedLinks.length})',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ...connectedLinks.map((link) => _buildLinkItem(link)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(NetworkLinkModel link) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0a0e1a),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${link.fromNodeName} → ${link.toNodeName}',
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${link.utilizationPercent.toStringAsFixed(0)}%',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: link.utilizationColor,
            ),
          ),
        ],
      ),
    );
  }
}

class TopologyPainter extends CustomPainter {
  final List<RouterNodeModel> routers;
  final List<NetworkLinkModel> links;
  final String? selectedRouterId;

  TopologyPainter({
    required this.routers,
    required this.links,
    this.selectedRouterId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);

    // Draw links first
    for (final link in links) {
      _drawLink(canvas, link);
    }

    // Draw routers on top
    for (final router in routers) {
      _drawRouter(canvas, router, router.id == selectedRouterId);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    // Draw grid pattern
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    const spacing = 50.0;

    // Vertical lines
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal lines
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw center crosshairs
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final crosshairPaint = Paint()
      ..color = const Color(0xFFf59e0b).withOpacity(0.1)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      crosshairPaint,
    );
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      crosshairPaint,
    );
  }

  void _drawLink(Canvas canvas, NetworkLinkModel link) {
    final fromRouter = routers.firstWhere((r) => r.id == link.fromNodeId);
    final toRouter = routers.firstWhere((r) => r.id == link.toNodeId);

    final paint = Paint()
      ..color = link.utilizationColor.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw glow effect for high utilization
    if (link.utilizationPercent >= 80) {
      final glowPaint = Paint()
        ..color = link.utilizationColor.withOpacity(0.3)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawLine(fromRouter.position, toRouter.position, glowPaint);
    }

    canvas.drawLine(fromRouter.position, toRouter.position, paint);

    // Draw utilization label
    final midPoint = Offset(
      (fromRouter.position.dx + toRouter.position.dx) / 2,
      (fromRouter.position.dy + toRouter.position.dy) / 2,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '${link.utilizationPercent.toStringAsFixed(0)}%',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          backgroundColor: const Color(0xFF0a0e1a).withOpacity(0.8),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        midPoint.dx - textPainter.width / 2,
        midPoint.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawRouter(Canvas canvas, RouterNodeModel router, bool isSelected) {
    final color = _getRouterColor(router.type);

    // Draw glow for selected or core routers
    if (isSelected || router.type == RouterType.core) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(router.position, router.nodeSize + 8, glowPaint);
    }

    // Draw outer circle
    final bgPaint = Paint()
      ..color = const Color(0xFF131823)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(router.position, router.nodeSize, bgPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = color
      ..strokeWidth = isSelected ? 4 : 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(router.position, router.nodeSize, borderPaint);

    // Draw inner circle
    final innerPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(router.position, router.nodeSize * 0.5, innerPaint);

    // Draw center dot
    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(router.position, router.nodeSize * 0.2, centerPaint);

    // Draw label
    final textPainter = TextPainter(
      text: TextSpan(
        text: router.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        router.position.dx - textPainter.width / 2,
        router.position.dy + router.nodeSize + 8,
      ),
    );
  }

  Color _getRouterColor(RouterType type) {
    switch (type) {
      case RouterType.core:
        return const Color(0xFFf59e0b); // Orange
      case RouterType.edge:
        return const Color(0xFF0ea5e9); // Blue
      case RouterType.access:
        return const Color(0xFF8b5cf6); // Purple
    }
  }

  @override
  bool shouldRepaint(TopologyPainter oldDelegate) => true;
}
