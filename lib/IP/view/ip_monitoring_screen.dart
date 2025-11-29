import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controller/ip_controller.dart';
import '../model/network_link_model.dart';

class IPMonitoringScreen extends StatelessWidget {
  const IPMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131823),
        title: Text(
          'Real-time Monitoring',
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
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBandwidthChart(
                          controller,
                          constraints.maxWidth - 32,
                        ),
                        const SizedBox(height: 24),
                        _buildLatencyHeatmap(
                          controller,
                          constraints.maxWidth - 32,
                        ),
                        const SizedBox(height: 24),
                        _buildPacketLossStats(
                          controller,
                          constraints.maxWidth - 32,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBandwidthChart(IPController controller, double maxWidth) {
    return Container(
      width: maxWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: maxWidth - 32,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Bandwidth Utilization (Last Hour)',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf59e0b).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFf59e0b).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${controller.metrics.currentUtilizationPercent.toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFf59e0b),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: maxWidth - 32,
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLegendItem('Peak', Colors.red),
                _buildLegendItem('Average', const Color(0xFFf59e0b)),
                _buildLegendItem('Current', Colors.green),
                Text(
                  'Total: ${controller.metrics.totalCapacityGbps} Gbps',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: maxWidth - 32,
            height: 200,
            child: CustomPaint(
              painter: BandwidthChartPainter(
                dataPoints: controller.metrics.hourlyData,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildLatencyHeatmap(IPController controller, double maxWidth) {
    return Container(
      width: maxWidth,
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
          ...controller.links.map(
            (link) => _buildLatencyBar(link, maxWidth - 32),
          ),
        ],
      ),
    );
  }

  Widget _buildLatencyBar(NetworkLinkModel link, double maxWidth) {
    final latencyPercent = (link.latencyMs / 100).clamp(0.0, 1.0);
    final color = latencyPercent > 0.5
        ? Colors.red
        : latencyPercent > 0.3
        ? Colors.orange
        : Colors.green;

    return Container(
      width: maxWidth,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: maxWidth,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${link.fromNodeName} → ${link.toNodeName}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                    ),
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
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: maxWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: latencyPercent,
                backgroundColor: const Color(0xFF0a0e1a),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPacketLossStats(IPController controller, double maxWidth) {
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
      width: maxWidth,
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
          SizedBox(
            width: maxWidth - 32,
            child: Row(
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
            ...criticalLinks.map(
              (link) => _buildPacketLossLinkItem(link, maxWidth - 32),
            ),
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

  Widget _buildPacketLossLinkItem(NetworkLinkModel link, double maxWidth) {
    return Container(
      width: maxWidth,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0a0e1a),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
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
}

class BandwidthChartPainter extends CustomPainter {
  final List<dynamic> dataPoints;

  BandwidthChartPainter({required this.dataPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty || size.width <= 0 || size.height <= 0) return;

    const leftPadding = 40.0;
    const rightPadding = 10.0;
    const topPadding = 10.0;
    const bottomPadding = 25.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = topPadding + (chartHeight * i / 4);
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(leftPadding + chartWidth, y),
        gridPaint,
      );
    }

    // Y-axis labels
    final yAxisStyle = TextStyle(
      color: Colors.white.withOpacity(0.5),
      fontSize: 10,
    );

    for (int i = 0; i <= 4; i++) {
      final y = topPadding + (chartHeight * i / 4);
      final label = '${100 - (i * 25)}%';
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: yAxisStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 5, y - textPainter.height / 2),
      );
    }

    // X-axis labels
    final xLabels = ['60m', '45m', '30m', '15m', 'Now'];
    for (int i = 0; i < xLabels.length; i++) {
      final x = leftPadding + (chartWidth * i / (xLabels.length - 1));
      final textPainter = TextPainter(
        text: TextSpan(text: xLabels[i], style: yAxisStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - bottomPadding + 5),
      );
    }

    // Threshold line at 80%
    final thresholdY = topPadding + (chartHeight * 0.2);
    canvas.drawLine(
      Offset(leftPadding, thresholdY),
      Offset(leftPadding + chartWidth, thresholdY),
      Paint()
        ..color = Colors.red.withOpacity(0.3)
        ..strokeWidth = 1.5,
    );

    // Data path
    final path = Path();
    final fillPath = Path();
    final linePaint = Paint()
      ..color = const Color(0xFFf59e0b)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final pointSpacing = chartWidth / (dataPoints.length - 1);

    var peakValue = 0.0;
    var peakIndex = 0;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = leftPadding + (i * pointSpacing);
      final utilization = dataPoints[i].utilization.clamp(0.0, 100.0);
      final y = topPadding + chartHeight - (utilization / 100 * chartHeight);

      if (dataPoints[i].utilization > peakValue) {
        peakValue = dataPoints[i].utilization;
        peakIndex = i;
      }

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, topPadding + chartHeight);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      // Data points
      canvas.drawCircle(
        Offset(x, y),
        2.5,
        Paint()..color = const Color(0xFFf59e0b),
      );
    }

    fillPath.lineTo(leftPadding + chartWidth, topPadding + chartHeight);
    fillPath.close();

    // Gradient fill
    final fillPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFf59e0b).withOpacity(0.3),
              const Color(0xFFf59e0b).withOpacity(0.05),
            ],
          ).createShader(
            Rect.fromLTWH(leftPadding, topPadding, chartWidth, chartHeight),
          )
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Peak indicator
    final peakX = leftPadding + (peakIndex * pointSpacing);
    final peakY = topPadding + chartHeight - (peakValue / 100 * chartHeight);

    canvas.drawLine(
      Offset(peakX, topPadding),
      Offset(peakX, topPadding + chartHeight),
      Paint()
        ..color = Colors.red.withOpacity(0.2)
        ..strokeWidth = 1,
    );

    canvas.drawCircle(Offset(peakX, peakY), 4, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(BandwidthChartPainter oldDelegate) => true;
}
