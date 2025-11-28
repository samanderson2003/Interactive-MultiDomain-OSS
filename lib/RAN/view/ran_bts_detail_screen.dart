import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../model/bts_model.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class RANBTSDetailScreen extends StatefulWidget {
  const RANBTSDetailScreen({super.key});

  @override
  State<RANBTSDetailScreen> createState() => _RANBTSDetailScreenState();
}

class _RANBTSDetailScreenState extends State<RANBTSDetailScreen>
    with TickerProviderStateMixin {
  String _selectedTab = 'Overview';
  String _selectedTimeRange = '24h';
  late AnimationController _chartAnimationController;

  final List<String> _tabs = ['Overview', 'Performance', 'Alerts', 'Config'];
  final List<String> _timeRanges = ['1h', '6h', '12h', '24h', '7d', '30d'];

  @override
  void initState() {
    super.initState();
    _chartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bts = ModalRoute.of(context)!.settings.arguments as BTSModel;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: Column(
        children: [
          _buildAppBar(context, bts),
          _buildTabBar(),
          Expanded(child: _buildTabContent(bts)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, BTSModel bts) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF131823),
        border: Border(bottom: BorderSide(color: Color(0xFF1e293b))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bts.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: bts.status.color.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.cell_tower,
                  color: bts.status.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bts.name,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bts.id,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: bts.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: bts.status.color.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: bts.status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      bts.status.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: bts.status.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white70),
                color: const Color(0xFF131823),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'restart',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.refresh,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Restart BTS',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'maintenance',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.build,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Maintenance Mode',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.download,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Export Report',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  _handleMenuAction(value, bts);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, BTSModel bts) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Action "$action" triggered for ${bts.name}',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0ea5e9),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF131823),
        border: Border(bottom: BorderSide(color: Color(0xFF1e293b))),
      ),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTab = tab;
                _chartAnimationController.reset();
                _chartAnimationController.forward();
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0ea5e9).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0ea5e9)
                      : const Color(0xFF1e293b),
                ),
              ),
              child: Text(
                tab,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF0ea5e9) : Colors.white70,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(BTSModel bts) {
    switch (_selectedTab) {
      case 'Overview':
        return _buildOverviewTab(bts);
      case 'Performance':
        return _buildPerformanceTab(bts);
      case 'Alerts':
        return _buildAlertsTab(bts);
      case 'Config':
        return _buildConfigTab(bts);
      default:
        return const SizedBox();
    }
  }

  Widget _buildOverviewTab(BTSModel bts) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildLocationCard(bts),
                    const SizedBox(height: 16),
                    _buildSignalMetricsCard(bts),
                    const SizedBox(height: 16),
                    _buildCapacityCard(bts),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _buildQuickStatsCard(bts),
                    const SizedBox(height: 16),
                    _buildRecentAlertsCard(bts),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BTSModel bts) {
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF131823),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1e293b)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF0ea5e9),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Location',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 200,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(bts.latitude, bts.longitude),
                    initialZoom: 13,
                  ),
                  children: [
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.7),
                        BlendMode.darken,
                      ),
                      child: TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.interactive.app',
                      ),
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(bts.latitude, bts.longitude),
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.cell_tower,
                            color: bts.status.color,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_city, 'City', bts.city),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.place, 'Region', bts.region),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.map, 'Address', bts.location),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.gps_fixed,
              'Coordinates',
              '${bts.latitude.toStringAsFixed(6)}, ${bts.longitude.toStringAsFixed(6)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white60),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignalMetricsCard(BTSModel bts) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF131823),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1e293b)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.signal_cellular_alt,
                  color: Color(0xFF10b981),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Signal Quality',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSignalMetric('RSRP', bts.rsrp, 'dBm', bts.rsrpQuality),
            const SizedBox(height: 16),
            _buildSignalMetric('RSRQ', bts.rsrq, 'dB', bts.rsrqQuality),
            const SizedBox(height: 16),
            _buildSignalMetric('SINR', bts.sinr, 'dB', bts.sinrQuality),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalMetric(
    String label,
    double value,
    String unit,
    String quality,
  ) {
    Color qualityColor;
    if (quality == 'Excellent') {
      qualityColor = const Color(0xFF10b981);
    } else if (quality == 'Good') {
      qualityColor = const Color(0xFF3b82f6);
    } else if (quality == 'Fair') {
      qualityColor = const Color(0xFFf59e0b);
    } else {
      qualityColor = const Color(0xFFef4444);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1e293b)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white60),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      value.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: qualityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: qualityColor.withOpacity(0.3)),
            ),
            child: Text(
              quality,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: qualityColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityCard(BTSModel bts) {
    final percentage = bts.capacityUtilization;
    Color barColor;
    if (percentage > 85) {
      barColor = const Color(0xFFef4444);
    } else if (percentage > 70) {
      barColor = const Color(0xFFf59e0b);
    } else {
      barColor = const Color(0xFF10b981);
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF131823),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1e293b)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: Color(0xFFf59e0b), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Capacity & Users',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Utilization',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white60),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: barColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0, end: percentage / 100),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF1e293b),
                    valueColor: AlwaysStoppedAnimation(barColor),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Active Users',
                    bts.activeUsers.toString(),
                    Icons.people,
                    const Color(0xFF3b82f6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Max Capacity',
                    bts.maxCapacity.toString(),
                    Icons.people_outline,
                    Colors.white60,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1e293b)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsCard(BTSModel bts) {
    return FadeInUp(
      duration: const Duration(milliseconds: 700),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF131823),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1e293b)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Stats',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _buildQuickStatRow(
              'Technology',
              bts.technology,
              const Color(0xFF3b82f6),
            ),
            const Divider(color: Color(0xFF1e293b), height: 24),
            _buildQuickStatRow('Uptime', '99.8%', const Color(0xFF10b981)),
            const Divider(color: Color(0xFF1e293b), height: 24),
            _buildQuickStatRow(
              'Alerts',
              bts.alerts.length.toString(),
              const Color(0xFFf59e0b),
            ),
            const Divider(color: Color(0xFF1e293b), height: 24),
            _buildQuickStatRow('Last Check', '2 mins ago', Colors.white60),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white60),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAlertsCard(BTSModel bts) {
    final recentAlerts = bts.alerts.take(4).toList();

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF131823),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1e293b)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Alerts',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (bts.alerts.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFef4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      bts.alerts.length.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFef4444),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentAlerts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No alerts',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recentAlerts.map(
                (alert) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAlertItem(alert),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(String alert) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1e293b)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: alert.contains('High') || alert.contains('Critical')
                ? const Color(0xFFef4444)
                : const Color(0xFFf59e0b),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              alert,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(BTSModel bts) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTimeRangeSelector(),
          const SizedBox(height: 24),
          _buildPerformanceCharts(bts),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Row(
      children: [
        Text(
          'Time Range:',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(width: 12),
        ..._timeRanges.map((range) {
          final isSelected = _selectedTimeRange == range;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTimeRange = range;
                _chartAnimationController.reset();
                _chartAnimationController.forward();
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0ea5e9).withOpacity(0.1)
                    : const Color(0xFF131823),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0ea5e9)
                      : const Color(0xFF1e293b),
                ),
              ),
              child: Text(
                range,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF0ea5e9) : Colors.white70,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPerformanceCharts(BTSModel bts) {
    return Column(
      children: [
        FadeInUp(
          duration: const Duration(milliseconds: 400),
          child: _buildMetricChart('RSRP Trend', bts, 'RSRP'),
        ),
        const SizedBox(height: 24),
        FadeInUp(
          duration: const Duration(milliseconds: 500),
          child: _buildMetricChart('RSRQ Trend', bts, 'RSRQ'),
        ),
        const SizedBox(height: 24),
        FadeInUp(
          duration: const Duration(milliseconds: 600),
          child: _buildMetricChart('SINR Trend', bts, 'SINR'),
        ),
        const SizedBox(height: 24),
        FadeInUp(
          duration: const Duration(milliseconds: 700),
          child: _buildMetricChart('Capacity Utilization', bts, 'Capacity'),
        ),
      ],
    );
  }

  Widget _buildMetricChart(String title, BTSModel bts, String metric) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1e293b)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: MetricChartPainter(
                bts: bts,
                metric: metric,
                animation: _chartAnimationController,
              ),
              size: const Size(double.infinity, 200),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsTab(BTSModel bts) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (bts.alerts.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Active Alerts',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This BTS is operating normally',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            )
          else
            ...bts.alerts.asMap().entries.map((entry) {
              return FadeInUp(
                duration: Duration(milliseconds: 400 + (entry.key * 100)),
                child: _buildFullAlertCard(entry.value, entry.key),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildFullAlertCard(String alert, int index) {
    final isCritical = alert.contains('High') || alert.contains('Critical');
    final severity = isCritical ? 'Critical' : 'Warning';
    final color = isCritical
        ? const Color(0xFFef4444)
        : const Color(0xFFf59e0b);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCritical ? Icons.error : Icons.warning_amber_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            severity,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(index + 1) * 15} mins ago',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      alert,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(
                    'Acknowledge',
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF10b981),
                    side: const BorderSide(color: Color(0xFF10b981)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.build, size: 16),
                  label: Text(
                    'Resolve',
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0ea5e9),
                    side: const BorderSide(color: Color(0xFF0ea5e9)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigTab(BTSModel bts) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            child: _buildConfigSection('Hardware Configuration', [
              {'label': 'Manufacturer', 'value': 'Ericsson'},
              {'label': 'Model', 'value': 'RBS 6000'},
              {'label': 'Serial Number', 'value': bts.id},
              {'label': 'Installation Date', 'value': '2021-03-15'},
            ]),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: _buildConfigSection('Radio Configuration', [
              {'label': 'Technology', 'value': bts.technology},
              {'label': 'Frequency Band', 'value': '2100 MHz'},
              {'label': 'Bandwidth', 'value': '20 MHz'},
              {'label': 'TX Power', 'value': '43 dBm'},
              {'label': 'Antenna Type', 'value': '3-Sector'},
              {'label': 'Antenna Height', 'value': '45m'},
            ]),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: _buildConfigSection('Network Configuration', [
              {
                'label': 'IP Address',
                'value': '192.168.100.${45 + (bts.id.hashCode % 200)}',
              },
              {'label': 'Gateway', 'value': '192.168.100.1'},
              {'label': 'Subnet Mask', 'value': '255.255.255.0'},
              {'label': 'VLAN', 'value': '100'},
            ]),
          ),
          const SizedBox(height: 16),
          FadeInUp(
            duration: const Duration(milliseconds: 700),
            child: _buildConfigSection('Performance Thresholds', [
              {'label': 'Min RSRP', 'value': '-110 dBm'},
              {'label': 'Min RSRQ', 'value': '-15 dB'},
              {'label': 'Min SINR', 'value': '0 dB'},
              {'label': 'Max Capacity', 'value': '${bts.maxCapacity} users'},
              {'label': 'Alert Threshold', 'value': '85%'},
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSection(String title, List<Map<String, String>> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1e293b)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['label']!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white60,
                    ),
                  ),
                  Text(
                    item['value']!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Metric Charts
class MetricChartPainter extends CustomPainter {
  final BTSModel bts;
  final String metric;
  final Animation<double> animation;

  MetricChartPainter({
    required this.bts,
    required this.metric,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gridPaint = Paint()
      ..color = const Color(0xFF1e293b).withOpacity(0.3)
      ..strokeWidth = 1;

    // Draw grid
    for (int i = 0; i <= 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final dataPoints = 24;
    List<double> data;

    // Generate sample data based on metric
    switch (metric) {
      case 'RSRP':
        data = List.generate(dataPoints, (i) {
          return bts.rsrp + (math.Random().nextDouble() * 4 - 2);
        });
        paint.color = const Color(0xFF10b981);
        _drawLine(canvas, size, data, paint, -120, -60);
        break;
      case 'RSRQ':
        data = List.generate(dataPoints, (i) {
          return bts.rsrq + (math.Random().nextDouble() * 2 - 1);
        });
        paint.color = const Color(0xFF3b82f6);
        _drawLine(canvas, size, data, paint, -20, -3);
        break;
      case 'SINR':
        data = List.generate(dataPoints, (i) {
          return bts.sinr + (math.Random().nextDouble() * 3 - 1.5);
        });
        paint.color = const Color(0xFFf59e0b);
        _drawLine(canvas, size, data, paint, 0, 30);
        break;
      case 'Capacity':
        data = List.generate(dataPoints, (i) {
          return bts.capacityUtilization +
              (math.Random().nextDouble() * 10 - 5);
        });
        paint.color = const Color(0xFF8b5cf6);
        _drawLine(canvas, size, data, paint, 0, 100);
        break;
    }
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<double> data,
    Paint paint,
    double minValue,
    double maxValue,
  ) {
    final path = ui.Path();
    final animatedLength = data.length * animation.value;

    for (int i = 0; i < animatedLength.floor(); i++) {
      final x = size.width * i / (data.length - 1);
      final normalizedValue = (data[i] - minValue) / (maxValue - minValue);
      final y = size.height * (1 - normalizedValue.clamp(0, 1));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
