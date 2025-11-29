import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSystemHealthScreen extends StatefulWidget {
  const AdminSystemHealthScreen({super.key});

  @override
  State<AdminSystemHealthScreen> createState() =>
      _AdminSystemHealthScreenState();
}

class _AdminSystemHealthScreenState extends State<AdminSystemHealthScreen> {
  String _timeFilter = '24h';

  // Static system health data
  final Map<String, dynamic> _systemHealth = {
    'overall': 'Healthy',
    'cpuUsage': 45,
    'memoryUsage': 62,
    'diskUsage': 38,
    'networkLatency': 12,
    'activeProcesses': 156,
    'uptime': '15d 6h 23m',
    'temperature': 52,
    'powerConsumption': 85,
  };

  final List<Map<String, dynamic>> _components = [
    {
      'name': 'Database Server',
      'status': 'Healthy',
      'uptime': '99.98%',
      'lastCheck': '2 mins ago',
      'metrics': {'cpu': 32, 'memory': 58, 'disk': 45},
    },
    {
      'name': 'Application Server',
      'status': 'Healthy',
      'uptime': '99.95%',
      'lastCheck': '1 min ago',
      'metrics': {'cpu': 48, 'memory': 72, 'disk': 35},
    },
    {
      'name': 'Web Server',
      'status': 'Warning',
      'uptime': '99.90%',
      'lastCheck': '3 mins ago',
      'metrics': {'cpu': 78, 'memory': 85, 'disk': 42},
    },
    {
      'name': 'Cache Server',
      'status': 'Healthy',
      'uptime': '99.99%',
      'lastCheck': '1 min ago',
      'metrics': {'cpu': 25, 'memory': 45, 'disk': 28},
    },
    {
      'name': 'Load Balancer',
      'status': 'Healthy',
      'uptime': '100%',
      'lastCheck': '2 mins ago',
      'metrics': {'cpu': 18, 'memory': 35, 'disk': 15},
    },
  ];

  final List<Map<String, dynamic>> _alerts = [
    {
      'severity': 'Warning',
      'message': 'High CPU usage detected on Web Server',
      'time': '5 mins ago',
      'component': 'Web Server',
    },
    {
      'severity': 'Info',
      'message': 'Scheduled maintenance completed successfully',
      'time': '1 hour ago',
      'component': 'Database Server',
    },
    {
      'severity': 'Info',
      'message': 'System backup completed',
      'time': '3 hours ago',
      'component': 'Backup Service',
    },
  ];

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
            _buildOverallHealthCard(),
            const SizedBox(height: 24),
            _buildMetricsGrid(),
            const SizedBox(height: 24),
            _buildComponentsSection(),
            const SizedBox(height: 24),
            _buildAlertsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Health',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitor system performance and component health',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
              ),
            ],
          ),
        ),
        _buildTimeFilter(),
      ],
    );
  }

  Widget _buildTimeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161b22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _timeFilter,
          dropdownColor: const Color(0xFF161b22),
          style: GoogleFonts.poppins(color: Colors.white),
          items: ['1h', '6h', '24h', '7d', '30d'].map((time) {
            return DropdownMenuItem(value: time, child: Text(time));
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _timeFilter = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildOverallHealthCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10b981).withOpacity(0.1),
            const Color(0xFF059669).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10b981)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10b981).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF10b981),
              size: 40,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Status: ${_systemHealth['overall']}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10b981),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All systems are operating normally',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
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
                'Uptime',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
              ),
              Text(
                _systemHealth['uptime'],
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 800
            ? 3
            : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(
              'CPU Usage',
              '${_systemHealth['cpuUsage']}%',
              _systemHealth['cpuUsage'],
              Icons.memory,
              const Color(0xFF3b82f6),
            ),
            _buildMetricCard(
              'Memory Usage',
              '${_systemHealth['memoryUsage']}%',
              _systemHealth['memoryUsage'],
              Icons.storage,
              const Color(0xFF8b5cf6),
            ),
            _buildMetricCard(
              'Disk Usage',
              '${_systemHealth['diskUsage']}%',
              _systemHealth['diskUsage'],
              Icons.save,
              const Color(0xFF10b981),
            ),
            _buildMetricCard(
              'Network',
              '${_systemHealth['networkLatency']}ms',
              (100 - _systemHealth['networkLatency'] as int),
              Icons.network_check,
              const Color(0xFFf59e0b),
            ),
            _buildMetricCard(
              'Processes',
              '${_systemHealth['activeProcesses']}',
              65,
              Icons.apps,
              const Color(0xFF06b6d4),
            ),
            _buildMetricCard(
              'Temperature',
              '${_systemHealth['temperature']}°C',
              _systemHealth['temperature'],
              Icons.thermostat,
              const Color(0xFFef4444),
            ),
            _buildMetricCard(
              'Power',
              '${_systemHealth['powerConsumption']}W',
              _systemHealth['powerConsumption'],
              Icons.bolt,
              const Color(0xFFfbbf24),
            ),
            _buildMetricCard(
              'Health Score',
              '98%',
              98,
              Icons.favorite,
              const Color(0xFFec4899),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    int percentage,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Icon(
                percentage > 75
                    ? Icons.trending_up
                    : percentage > 50
                    ? Icons.trending_flat
                    : Icons.trending_down,
                color: percentage > 75
                    ? const Color(0xFFef4444)
                    : percentage > 50
                    ? const Color(0xFFf59e0b)
                    : const Color(0xFF10b981),
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Component Health',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _components.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final component = _components[index];
            return _buildComponentCard(component);
          },
        ),
      ],
    );
  }

  Widget _buildComponentCard(Map<String, dynamic> component) {
    final status = component['status'] as String;
    final statusColor = status == 'Healthy'
        ? const Color(0xFF10b981)
        : status == 'Warning'
        ? const Color(0xFFf59e0b)
        : const Color(0xFFef4444);

    return Container(
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.dns, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      component['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last checked: ${component['lastCheck']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
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
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Uptime',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white60,
                    ),
                  ),
                  Text(
                    component['uptime'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetricBar(
                'CPU',
                component['metrics']['cpu'],
                const Color(0xFF3b82f6),
              ),
              const SizedBox(width: 16),
              _buildMetricBar(
                'Memory',
                component['metrics']['memory'],
                const Color(0xFF8b5cf6),
              ),
              const SizedBox(width: 16),
              _buildMetricBar(
                'Disk',
                component['metrics']['disk'],
                const Color(0xFF10b981),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBar(String label, int value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.white60),
              ),
              Text(
                '$value%',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Alerts',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0d1117),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF21262d)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _alerts.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Color(0xFF21262d), height: 1),
            itemBuilder: (context, index) {
              final alert = _alerts[index];
              return _buildAlertItem(alert);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    final severity = alert['severity'] as String;
    final severityColor = severity == 'Warning'
        ? const Color(0xFFf59e0b)
        : severity == 'Critical'
        ? const Color(0xFFef4444)
        : const Color(0xFF3b82f6);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              severity == 'Warning'
                  ? Icons.warning_amber
                  : severity == 'Critical'
                  ? Icons.error
                  : Icons.info,
              color: severityColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['message'],
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      alert['component'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                    Text(
                      ' • ',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                    Text(
                      alert['time'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: severityColor),
            ),
            child: Text(
              severity,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: severityColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
