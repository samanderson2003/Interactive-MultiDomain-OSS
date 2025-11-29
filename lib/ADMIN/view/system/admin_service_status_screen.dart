import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminServiceStatusScreen extends StatefulWidget {
  const AdminServiceStatusScreen({super.key});

  @override
  State<AdminServiceStatusScreen> createState() =>
      _AdminServiceStatusScreenState();
}

class _AdminServiceStatusScreenState extends State<AdminServiceStatusScreen> {
  String _filterStatus = 'All';

  final List<Map<String, dynamic>> _services = [
    {
      'name': 'Authentication Service',
      'status': 'Running',
      'uptime': '15d 6h',
      'responseTime': '45ms',
      'requests': '1.2M',
      'version': 'v2.3.1',
      'port': 8080,
      'health': 98,
    },
    {
      'name': 'Database Service',
      'status': 'Running',
      'uptime': '15d 6h',
      'responseTime': '12ms',
      'requests': '3.8M',
      'version': 'v14.5',
      'port': 5432,
      'health': 99,
    },
    {
      'name': 'Cache Service',
      'status': 'Running',
      'uptime': '15d 6h',
      'responseTime': '3ms',
      'requests': '8.5M',
      'version': 'v7.0.2',
      'port': 6379,
      'health': 100,
    },
    {
      'name': 'API Gateway',
      'status': 'Running',
      'uptime': '15d 6h',
      'responseTime': '28ms',
      'requests': '4.2M',
      'version': 'v3.1.0',
      'port': 80,
      'health': 97,
    },
    {
      'name': 'Message Queue',
      'status': 'Running',
      'uptime': '15d 6h',
      'responseTime': '8ms',
      'requests': '2.1M',
      'version': 'v3.8.19',
      'port': 5672,
      'health': 99,
    },
    {
      'name': 'Email Service',
      'status': 'Running',
      'uptime': '15d 6h',
      'responseTime': '120ms',
      'requests': '45K',
      'version': 'v1.2.0',
      'port': 25,
      'health': 95,
    },
    {
      'name': 'File Storage',
      'status': 'Running',
      'uptime': '15d 6h',
      'responseTime': '55ms',
      'requests': '890K',
      'version': 'v4.1.2',
      'port': 9000,
      'health': 96,
    },
    {
      'name': 'Analytics Service',
      'status': 'Warning',
      'uptime': '2d 12h',
      'responseTime': '250ms',
      'requests': '320K',
      'version': 'v2.0.5',
      'port': 8888,
      'health': 78,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredServices = _filterStatus == 'All'
        ? _services
        : _services.where((s) => s['status'] == _filterStatus).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatsOverview(),
            const SizedBox(height: 24),
            _buildServicesGrid(filteredServices),
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
                'Service Status',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitor all system services and their health',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF161b22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF21262d)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _filterStatus,
              dropdownColor: const Color(0xFF161b22),
              style: GoogleFonts.poppins(color: Colors.white),
              items: ['All', 'Running', 'Stopped', 'Warning'].map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _filterStatus = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    final running = _services.where((s) => s['status'] == 'Running').length;
    final warning = _services.where((s) => s['status'] == 'Warning').length;
    final stopped = _services.where((s) => s['status'] == 'Stopped').length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Services',
            '${_services.length}',
            Icons.dns,
            const Color(0xFF3b82f6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Running',
            '$running',
            Icons.check_circle,
            const Color(0xFF10b981),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Warning',
            '$warning',
            Icons.warning,
            const Color(0xFFf59e0b),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Stopped',
            '$stopped',
            Icons.cancel,
            const Color(0xFFef4444),
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
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(List<Map<String, dynamic>> services) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildServiceCard(service);
      },
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final status = service['status'] as String;
    final statusColor = status == 'Running'
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  status == 'Running'
                      ? Icons.check_circle
                      : status == 'Warning'
                      ? Icons.warning
                      : Icons.cancel,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      service['version'],
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetricItem('Uptime', service['uptime'])),
              Expanded(child: _buildMetricItem('Port', ':${service['port']}')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem('Response', service['responseTime']),
              ),
              Expanded(
                child: _buildMetricItem('Requests', service['requests']),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Health',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white60,
                          ),
                        ),
                        Text(
                          '${service['health']}%',
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
                        value: service['health'] / 100,
                        backgroundColor: statusColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                color: const Color(0xFF3b82f6),
                onPressed: () {
                  // Restart service action
                },
                tooltip: 'Restart Service',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white60),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
