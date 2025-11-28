import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controller/core_controller.dart';
import 'dart:math' as math;

class CoreAnalyticsScreen extends StatefulWidget {
  const CoreAnalyticsScreen({super.key});

  @override
  State<CoreAnalyticsScreen> createState() => _CoreAnalyticsScreenState();
}

class _CoreAnalyticsScreenState extends State<CoreAnalyticsScreen> {
  String _selectedTimeRange = '24h';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<CoreController>();
      if (controller.coreElements.isEmpty) {
        controller.loadDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131823),
        title: Text(
          'CORE Analytics',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          _buildTimeRangeSelector(),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<CoreController>().refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<CoreController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0ea5e9)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKPIMetrics(controller),
                const SizedBox(height: 24),
                _buildLatencyChart(),
                const SizedBox(height: 24),
                _buildThroughputChart(),
                const SizedBox(height: 24),
                _buildAttachDetachChart(),
                const SizedBox(height: 24),
                _buildElementTypeDistribution(controller),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return PopupMenuButton<String>(
      initialValue: _selectedTimeRange,
      icon: const Icon(Icons.access_time, color: Colors.white),
      color: const Color(0xFF131823),
      onSelected: (value) {
        setState(() {
          _selectedTimeRange = value;
        });
      },
      itemBuilder: (context) => [
        _buildMenuItem('1h', '1 Hour'),
        _buildMenuItem('24h', '24 Hours'),
        _buildMenuItem('7d', '7 Days'),
        _buildMenuItem('30d', '30 Days'),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: _selectedTimeRange == value
              ? const Color(0xFF0ea5e9)
              : Colors.white,
          fontWeight: _selectedTimeRange == value
              ? FontWeight.w600
              : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildKPIMetrics(CoreController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Attach Rate',
            '${(controller.kpis.attachSuccessRate * 100).toStringAsFixed(1)}%',
            Icons.link,
            Colors.green,
            '+2.3%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            'Avg Latency',
            '${controller.kpis.averageLatency.toStringAsFixed(0)}ms',
            Icons.speed,
            Colors.blue,
            '-5.1%',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String trend,
  ) {
    final isPositive = trend.startsWith('+');
    final trendColor = title.contains('Latency')
        ? (isPositive ? Colors.red : Colors.green)
        : (isPositive ? Colors.green : Colors.red);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trend,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: trendColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildLatencyChart() {
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
            'Latency Trends',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: LineChartPainter(
                data: _generateLatencyData(),
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThroughputChart() {
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
            'Throughput Analysis',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: AreaChartPainter(
                data: _generateThroughputData(),
                color: Colors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachDetachChart() {
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
            'Attach/Detach Rates',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: BarChartPainter(
                attachData: _generateAttachData(),
                detachData: _generateDetachData(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementTypeDistribution(CoreController controller) {
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
            'Element Distribution',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 180,
                  child: CustomPaint(
                    size: const Size(180, 180),
                    painter: PieChartPainter(
                      data: _getElementDistribution(controller),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(child: _buildLegend(controller)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(CoreController controller) {
    final distribution = _getElementDistribution(controller);
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.green,
      Colors.pink,
      Colors.cyan,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(distribution.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  distribution.keys.elementAt(index),
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                ),
              ),
              Text(
                distribution.values.elementAt(index).toString(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  List<double> _generateLatencyData() {
    return List.generate(
      24,
      (i) => 60 + math.Random().nextDouble() * 40 + math.sin(i / 4) * 20,
    );
  }

  List<double> _generateThroughputData() {
    return List.generate(
      24,
      (i) => 400 + math.Random().nextDouble() * 300 + math.cos(i / 3) * 100,
    );
  }

  List<double> _generateAttachData() {
    return List.generate(12, (i) => 80 + math.Random().nextDouble() * 20);
  }

  List<double> _generateDetachData() {
    return List.generate(12, (i) => 30 + math.Random().nextDouble() * 20);
  }

  Map<String, int> _getElementDistribution(CoreController controller) {
    final distribution = <String, int>{};
    for (final element in controller.coreElements) {
      final type = element.typeString;
      distribution[type] = (distribution[type] ?? 0) + 1;
    }
    return distribution;
  }
}

// Custom Painters for Charts
class LineChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  LineChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (data.length - 1);
    final maxY = data.reduce(math.max);
    final minY = data.reduce(math.min);
    final rangeY = maxY - minY;

    path.moveTo(0, size.height - (data[0] - minY) / rangeY * size.height);

    for (var i = 1; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] - minY) / rangeY * size.height;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Draw points
    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] - minY) / rangeY * size.height;
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) => false;
}

class AreaChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  AreaChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final areaPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    final areaPath = Path();
    final stepX = size.width / (data.length - 1);
    final maxY = data.reduce(math.max);
    final minY = data.reduce(math.min);
    final rangeY = maxY - minY;

    path.moveTo(0, size.height - (data[0] - minY) / rangeY * size.height);
    areaPath.moveTo(0, size.height);
    areaPath.lineTo(0, size.height - (data[0] - minY) / rangeY * size.height);

    for (var i = 1; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i] - minY) / rangeY * size.height;
      path.lineTo(x, y);
      areaPath.lineTo(x, y);
    }

    areaPath.lineTo(size.width, size.height);
    areaPath.close();

    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(AreaChartPainter oldDelegate) => false;
}

class BarChartPainter extends CustomPainter {
  final List<double> attachData;
  final List<double> detachData;

  BarChartPainter({required this.attachData, required this.detachData});

  @override
  void paint(Canvas canvas, Size size) {
    if (attachData.isEmpty || detachData.isEmpty) return;

    final barWidth = size.width / (attachData.length * 3);
    final maxValue = math.max(
      attachData.reduce(math.max),
      detachData.reduce(math.max),
    );

    for (var i = 0; i < attachData.length; i++) {
      // Attach bar
      final attachHeight = (attachData[i] / maxValue) * size.height;
      final attachRect = Rect.fromLTWH(
        i * barWidth * 3,
        size.height - attachHeight,
        barWidth,
        attachHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(attachRect, const Radius.circular(4)),
        Paint()..color = Colors.green,
      );

      // Detach bar
      final detachHeight = (detachData[i] / maxValue) * size.height;
      final detachRect = Rect.fromLTWH(
        i * barWidth * 3 + barWidth * 1.2,
        size.height - detachHeight,
        barWidth,
        detachHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(detachRect, const Radius.circular(4)),
        Paint()..color = Colors.orange,
      );
    }
  }

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) => false;
}

class PieChartPainter extends CustomPainter {
  final Map<String, int> data;

  PieChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final total = data.values.reduce((a, b) => a + b).toDouble();
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.green,
      Colors.pink,
      Colors.cyan,
    ];

    double startAngle = -math.pi / 2;

    data.values.toList().asMap().forEach((index, value) {
      final sweepAngle = (value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[index % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    });

    // Draw inner circle for donut effect
    canvas.drawCircle(
      center,
      radius * 0.6,
      Paint()..color = const Color(0xFF131823),
    );
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) => false;
}
