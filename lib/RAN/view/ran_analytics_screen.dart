import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../controller/ran_controller.dart';
import '../model/bts_model.dart';
import '../model/alert_model.dart';
import 'dart:math' as math;

class RANAnalyticsScreen extends StatefulWidget {
  const RANAnalyticsScreen({super.key});

  @override
  State<RANAnalyticsScreen> createState() => _RANAnalyticsScreenState();
}

class _RANAnalyticsScreenState extends State<RANAnalyticsScreen>
    with TickerProviderStateMixin {
  String _selectedTimeRange = '24h';
  String _selectedMetric = 'RSRP';
  String? _selectedCity;
  late AnimationController _chartAnimationController;

  final List<String> _timeRanges = ['1h', '6h', '12h', '24h', '7d', '30d'];
  final List<String> _metrics = ['RSRP', 'RSRQ', 'SINR', 'Capacity', 'Users'];

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
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: Consumer<RANController>(
        builder: (context, ranController, child) {
          return Column(
            children: [
              _buildAppBar(context, ranController),
              _buildFilterBar(ranController),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKPICards(ranController),
                      const SizedBox(height: 24),
                      _buildSignalQualityChart(ranController),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildCapacityTrends(ranController),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildStatusDistribution(ranController),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildCityPerformance(ranController)),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildTechnologyDistribution(ranController),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildAlertsTimeline(ranController),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, RANController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF131823),
        border: Border(bottom: BorderSide(color: Color(0xFF1e293b))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0ea5e9).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: Color(0xFF0ea5e9),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'RAN Analytics',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          _buildStatChip(
            'Avg Signal',
            '${controller.averageSignalQuality.toStringAsFixed(1)}%',
            const Color(0xFF10b981),
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            'Network Health',
            _getNetworkHealthLabel(controller),
            _getNetworkHealthColor(controller),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () {
              _chartAnimationController.reset();
              _chartAnimationController.forward();
            },
          ),
        ],
      ),
    );
  }

  String _getNetworkHealthLabel(RANController controller) {
    final health = controller.averageSignalQuality;
    if (health >= 90) return 'Excellent';
    if (health >= 75) return 'Good';
    if (health >= 60) return 'Fair';
    return 'Poor';
  }

  Color _getNetworkHealthColor(RANController controller) {
    final health = controller.averageSignalQuality;
    if (health >= 90) return const Color(0xFF10b981);
    if (health >= 75) return const Color(0xFF3b82f6);
    if (health >= 60) return const Color(0xFFf59e0b);
    return const Color(0xFFef4444);
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(RANController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF131823),
        border: Border(bottom: BorderSide(color: Color(0xFF1e293b))),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Text(
            'Filters:',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 16),
          _buildTimeRangeSelector(),
          const SizedBox(width: 12),
          _buildMetricSelector(),
          const SizedBox(width: 12),
          _buildCityFilter(controller),
          const Spacer(),
          if (_selectedCity != null)
            TextButton.icon(
              onPressed: () => setState(() => _selectedCity = null),
              icon: const Icon(Icons.clear, size: 16),
              label: Text(
                'Clear Filters',
                style: GoogleFonts.inter(fontSize: 13),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0ea5e9),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1e293b)),
      ),
      child: DropdownButton<String>(
        value: _selectedTimeRange,
        dropdownColor: const Color(0xFF0F172A),
        underline: const SizedBox(),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.white60,
          size: 20,
        ),
        style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
        items: _timeRanges.map((String range) {
          return DropdownMenuItem<String>(value: range, child: Text(range));
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedTimeRange = value!);
        },
      ),
    );
  }

  Widget _buildMetricSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1e293b)),
      ),
      child: DropdownButton<String>(
        value: _selectedMetric,
        dropdownColor: const Color(0xFF0F172A),
        underline: const SizedBox(),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.white60,
          size: 20,
        ),
        style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
        items: _metrics.map((String metric) {
          return DropdownMenuItem<String>(value: metric, child: Text(metric));
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedMetric = value!);
        },
      ),
    );
  }

  Widget _buildCityFilter(RANController controller) {
    final cities = <String>[
      'All Cities',
      ...controller.btsList.map((b) => b.city).toSet().toList()..sort(),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1e293b)),
      ),
      child: DropdownButton<String>(
        value: _selectedCity ?? 'All Cities',
        dropdownColor: const Color(0xFF0F172A),
        underline: const SizedBox(),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.white60,
          size: 20,
        ),
        style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
        items: cities.map((String city) {
          return DropdownMenuItem<String>(value: city, child: Text(city));
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedCity = value == 'All Cities' ? null : value);
        },
      ),
    );
  }

  Widget _buildKPICards(RANController controller) {
    final filteredBTS = _selectedCity != null
        ? controller.btsList.where((b) => b.city == _selectedCity).toList()
        : controller.btsList;

    final avgRSRP = filteredBTS.isEmpty
        ? 0.0
        : filteredBTS.map((b) => b.rsrp).reduce((a, b) => a + b) /
              filteredBTS.length;
    final avgRSRQ = filteredBTS.isEmpty
        ? 0.0
        : filteredBTS.map((b) => b.rsrq).reduce((a, b) => a + b) /
              filteredBTS.length;
    final avgSINR = filteredBTS.isEmpty
        ? 0.0
        : filteredBTS.map((b) => b.sinr).reduce((a, b) => a + b) /
              filteredBTS.length;
    final avgCapacity = filteredBTS.isEmpty
        ? 0.0
        : filteredBTS
                  .map((b) => b.capacityUtilization)
                  .reduce((a, b) => a + b) /
              filteredBTS.length;

    return Row(
      children: [
        Expanded(
          child: FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: _buildKPICard(
              'Avg RSRP',
              '${avgRSRP.toStringAsFixed(1)} dBm',
              Icons.signal_cellular_alt,
              const Color(0xFF10b981),
              avgRSRP >= -80 ? 'Excellent' : 'Good',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: _buildKPICard(
              'Avg RSRQ',
              '${avgRSRQ.toStringAsFixed(1)} dB',
              Icons.network_check,
              const Color(0xFF3b82f6),
              avgRSRQ >= -10 ? 'Excellent' : 'Good',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FadeInUp(
            duration: const Duration(milliseconds: 700),
            child: _buildKPICard(
              'Avg SINR',
              '${avgSINR.toStringAsFixed(1)} dB',
              Icons.waves,
              const Color(0xFFf59e0b),
              avgSINR >= 20 ? 'Excellent' : 'Good',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FadeInUp(
            duration: const Duration(milliseconds: 800),
            child: _buildKPICard(
              'Avg Capacity',
              '${avgCapacity.toStringAsFixed(1)}%',
              Icons.speed,
              avgCapacity > 85
                  ? const Color(0xFFef4444)
                  : const Color(0xFF10b981),
              avgCapacity > 85 ? 'High' : 'Normal',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKPICard(
    String title,
    String value,
    IconData icon,
    Color color,
    String status,
  ) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white60),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalQualityChart(RANController controller) {
    return FadeInUp(
      duration: const Duration(milliseconds: 900),
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
                Text(
                  'Signal Quality Trends',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0ea5e9).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedTimeRange,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0ea5e9),
                    ),
                  ),
                ),
                const Spacer(),
                _buildChartLegend('RSRP', const Color(0xFF10b981)),
                const SizedBox(width: 16),
                _buildChartLegend('RSRQ', const Color(0xFF3b82f6)),
                const SizedBox(width: 16),
                _buildChartLegend('SINR', const Color(0xFFf59e0b)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: AnimatedBuilder(
                animation: _chartAnimationController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(double.infinity, 300),
                    painter: LineChartPainter(
                      controller: controller,
                      animation: _chartAnimationController,
                      selectedCity: _selectedCity,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildCapacityTrends(RANController controller) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
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
              'Capacity Utilization by BTS',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: ListView.builder(
                itemCount: controller.btsList.take(6).length,
                itemBuilder: (context, index) {
                  final bts = controller.btsList[index];
                  return _buildCapacityBar(bts, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacityBar(BTSModel bts, int index) {
    final percentage = bts.capacityUtilization;
    Color barColor;
    if (percentage > 85) {
      barColor = const Color(0xFFef4444);
    } else if (percentage > 70) {
      barColor = const Color(0xFFf59e0b);
    } else {
      barColor = const Color(0xFF10b981);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Expanded(
                child: Text(
                  bts.name,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 800 + (index * 100)),
              curve: Curves.easeOutCubic,
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
        ],
      ),
    );
  }

  Widget _buildStatusDistribution(RANController controller) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1100),
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
              'BTS Status Distribution',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: CustomPaint(
                size: const Size(200, 200),
                painter: DonutChartPainter(
                  active: controller.activeBTS,
                  inactive: controller.inactiveBTS,
                  degraded: controller.degradedBTS,
                  maintenance: controller.btsList
                      .where((b) => b.status == BTSStatus.maintenance)
                      .length,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildStatusItem(
              'Active',
              controller.activeBTS,
              BTSStatus.active.color,
            ),
            const SizedBox(height: 12),
            _buildStatusItem(
              'Inactive',
              controller.inactiveBTS,
              BTSStatus.inactive.color,
            ),
            const SizedBox(height: 12),
            _buildStatusItem(
              'Degraded',
              controller.degradedBTS,
              BTSStatus.degraded.color,
            ),
            const SizedBox(height: 12),
            _buildStatusItem(
              'Maintenance',
              controller.btsList
                  .where((b) => b.status == BTSStatus.maintenance)
                  .length,
              BTSStatus.maintenance.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
        ),
        const Spacer(),
        Text(
          count.toString(),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCityPerformance(RANController controller) {
    final cityData = <String, Map<String, dynamic>>{};
    for (var bts in controller.btsList) {
      if (!cityData.containsKey(bts.city)) {
        cityData[bts.city] = {'count': 0, 'avgSignal': 0.0, 'active': 0};
      }
      cityData[bts.city]!['count']++;
      cityData[bts.city]!['avgSignal'] += bts.rsrp;
      if (bts.status == BTSStatus.active) {
        cityData[bts.city]!['active']++;
      }
    }

    cityData.forEach((city, data) {
      data['avgSignal'] = data['avgSignal'] / data['count'];
    });

    final sortedCities = cityData.entries.toList()
      ..sort((a, b) => b.value['count'].compareTo(a.value['count']));

    return FadeInUp(
      duration: const Duration(milliseconds: 1200),
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
              'Performance by City',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ...sortedCities.take(5).map((entry) {
              return _buildCityItem(
                entry.key,
                entry.value['count'],
                entry.value['active'],
                entry.value['avgSignal'],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCityItem(String city, int total, int active, double avgSignal) {
    final percentage = (active / total * 100);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1e293b)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_city,
                  size: 16,
                  color: const Color(0xFF0ea5e9),
                ),
                const SizedBox(width: 8),
                Text(
                  city,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '$active/$total',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Uptime',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white38,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10b981),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Avg Signal',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white38,
                        ),
                      ),
                      Text(
                        '${avgSignal.toStringAsFixed(1)} dBm',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3b82f6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnologyDistribution(RANController controller) {
    final techData = <String, int>{};
    for (var bts in controller.btsList) {
      techData[bts.technology] = (techData[bts.technology] ?? 0) + 1;
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 1300),
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
              'Technology Distribution',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ...techData.entries.map((entry) {
              return _buildTechItem(
                entry.key,
                entry.value,
                controller.totalBTS,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTechItem(String tech, int count, int total) {
    final percentage = (count / total * 100);
    final colors = {
      '5G': const Color(0xFF10b981),
      '4G LTE': const Color(0xFF3b82f6),
      '4G': const Color(0xFFf59e0b),
    };
    final color = colors[tech] ?? const Color(0xFF6366f1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tech,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$count towers',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF1e293b),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsTimeline(RANController controller) {
    final allAlerts = controller.btsList
        .expand(
          (bts) => bts.alerts.map(
            (msg) => AlertModel(
              id: '${bts.id}_${msg.hashCode}',
              btsId: bts.id,
              btsName: bts.name,
              title: 'Alert',
              description: msg,
              severity: AlertSeverity.critical,
              status: AlertStatus.active,
              timestamp: DateTime.now().subtract(
                Duration(hours: bts.alerts.indexOf(msg) * 2),
              ),
              location: bts.location,
              alertType: 'SIGNAL_DEGRADATION',
            ),
          ),
        )
        .toList();
    final recentAlerts = allAlerts.take(8).toList();

    return FadeInUp(
      duration: const Duration(milliseconds: 1400),
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
                Text(
                  'Recent Alerts Timeline',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFef4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${controller.criticalAlerts} Critical',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFef4444),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...recentAlerts.map(
              (alert) => _buildAlertItem(alert, recentAlerts),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(AlertModel alert, List<AlertModel> allAlerts) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: alert.severity.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: alert.severity.color.withOpacity(0.3),
                    width: 3,
                  ),
                ),
              ),
              if (alert != allAlerts.last)
                Container(width: 2, height: 40, color: const Color(0xFF1e293b)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: alert.severity.color.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: alert.severity.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          alert.severity.displayName.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: alert.severity.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '2h ago',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    alert.description,
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'BTS ID: ${alert.btsId}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white60,
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

// Custom Painter for Line Chart
class LineChartPainter extends CustomPainter {
  final RANController controller;
  final Animation<double> animation;
  final String? selectedCity;

  LineChartPainter({
    required this.controller,
    required this.animation,
    this.selectedCity,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final filteredBTS = selectedCity != null
        ? controller.btsList.where((b) => b.city == selectedCity).toList()
        : controller.btsList;

    if (filteredBTS.isEmpty) return;

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

    // Generate sample data with variation
    final rsrpData = List.generate(dataPoints, (i) {
      final baseValue = filteredBTS.first.rsrp;
      return baseValue + (math.Random().nextDouble() * 4 - 2);
    });

    final rsrqData = List.generate(dataPoints, (i) {
      final baseValue = filteredBTS.first.rsrq;
      return baseValue + (math.Random().nextDouble() * 2 - 1);
    });

    final sinrData = List.generate(dataPoints, (i) {
      final baseValue = filteredBTS.first.sinr;
      return baseValue + (math.Random().nextDouble() * 3 - 1.5);
    });

    // Normalize and draw RSRP line
    paint.color = const Color(0xFF10b981);
    _drawLine(canvas, size, rsrpData, paint, -120, -60);

    // Draw RSRQ line
    paint.color = const Color(0xFF3b82f6);
    _drawLine(canvas, size, rsrqData, paint, -20, -3);

    // Draw SINR line
    paint.color = const Color(0xFFf59e0b);
    _drawLine(canvas, size, sinrData, paint, 0, 30);
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<double> data,
    Paint paint,
    double minValue,
    double maxValue,
  ) {
    final path = Path();
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

// Custom Painter for Donut Chart
class DonutChartPainter extends CustomPainter {
  final int active;
  final int inactive;
  final int degraded;
  final int maintenance;

  DonutChartPainter({
    required this.active,
    required this.inactive,
    required this.degraded,
    required this.maintenance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final innerRadius = radius * 0.6;

    final total = active + inactive + degraded + maintenance;
    if (total == 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius - innerRadius;

    double startAngle = -math.pi / 2;

    // Draw active segment
    final activeSweep = (active / total) * 2 * math.pi;
    paint.color = BTSStatus.active.color;
    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: innerRadius + paint.strokeWidth / 2,
      ),
      startAngle,
      activeSweep,
      false,
      paint,
    );
    startAngle += activeSweep;

    // Draw degraded segment
    final degradedSweep = (degraded / total) * 2 * math.pi;
    paint.color = BTSStatus.degraded.color;
    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: innerRadius + paint.strokeWidth / 2,
      ),
      startAngle,
      degradedSweep,
      false,
      paint,
    );
    startAngle += degradedSweep;

    // Draw inactive segment
    final inactiveSweep = (inactive / total) * 2 * math.pi;
    paint.color = BTSStatus.inactive.color;
    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: innerRadius + paint.strokeWidth / 2,
      ),
      startAngle,
      inactiveSweep,
      false,
      paint,
    );
    startAngle += inactiveSweep;

    // Draw maintenance segment
    final maintenanceSweep = (maintenance / total) * 2 * math.pi;
    paint.color = BTSStatus.maintenance.color;
    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: innerRadius + paint.strokeWidth / 2,
      ),
      startAngle,
      maintenanceSweep,
      false,
      paint,
    );

    // Draw center text
    final textPainter = TextPainter(
      text: TextSpan(
        text: total.toString(),
        style: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
