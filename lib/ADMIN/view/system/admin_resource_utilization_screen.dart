import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminResourceUtilizationScreen extends StatefulWidget {
  const AdminResourceUtilizationScreen({super.key});

  @override
  State<AdminResourceUtilizationScreen> createState() =>
      _AdminResourceUtilizationScreenState();
}

class _AdminResourceUtilizationScreenState
    extends State<AdminResourceUtilizationScreen> {
  String _selectedPeriod = 'Last 24 Hours';

  final List<Map<String, dynamic>> _cpuHistory = [
    {'time': '00:00', 'value': 35},
    {'time': '04:00', 'value': 28},
    {'time': '08:00', 'value': 52},
    {'time': '12:00', 'value': 68},
    {'time': '16:00', 'value': 45},
    {'time': '20:00', 'value': 38},
  ];

  final List<Map<String, dynamic>> _memoryHistory = [
    {'time': '00:00', 'value': 55},
    {'time': '04:00', 'value': 48},
    {'time': '08:00', 'value': 62},
    {'time': '12:00', 'value': 75},
    {'time': '16:00', 'value': 68},
    {'time': '20:00', 'value': 58},
  ];

  final List<Map<String, dynamic>> _resources = [
    {
      'name': 'CPU Cores',
      'total': 16,
      'used': 7,
      'available': 9,
      'percentage': 44,
      'icon': Icons.memory,
      'color': Color(0xFF3b82f6),
    },
    {
      'name': 'RAM Memory',
      'total': 64,
      'used': 40,
      'available': 24,
      'unit': 'GB',
      'percentage': 62,
      'icon': Icons.storage,
      'color': Color(0xFF8b5cf6),
    },
    {
      'name': 'Disk Storage',
      'total': 2048,
      'used': 778,
      'available': 1270,
      'unit': 'GB',
      'percentage': 38,
      'icon': Icons.save,
      'color': Color(0xFF10b981),
    },
    {
      'name': 'Network Bandwidth',
      'total': 10,
      'used': 3.2,
      'available': 6.8,
      'unit': 'Gbps',
      'percentage': 32,
      'icon': Icons.network_check,
      'color': Color(0xFFf59e0b),
    },
  ];

  final List<Map<String, dynamic>> _topProcesses = [
    {'name': 'Database Service', 'cpu': 28.5, 'memory': 4.2, 'pid': 1024},
    {'name': 'Web Server', 'cpu': 18.2, 'memory': 3.8, 'pid': 2048},
    {'name': 'Cache Service', 'cpu': 12.5, 'memory': 2.5, 'pid': 3072},
    {'name': 'API Gateway', 'cpu': 8.3, 'memory': 1.9, 'pid': 4096},
    {'name': 'Message Queue', 'cpu': 5.8, 'memory': 1.2, 'pid': 5120},
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
            _buildResourcesGrid(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildCPUChart()),
                const SizedBox(width: 16),
                Expanded(child: _buildMemoryChart()),
              ],
            ),
            const SizedBox(height: 24),
            _buildTopProcesses(),
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
                'Resource Usage',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitor system resources and utilization trends',
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
              value: _selectedPeriod,
              dropdownColor: const Color(0xFF161b22),
              style: GoogleFonts.poppins(color: Colors.white),
              items:
                  [
                    'Last Hour',
                    'Last 24 Hours',
                    'Last 7 Days',
                    'Last 30 Days',
                  ].map((period) {
                    return DropdownMenuItem(value: period, child: Text(period));
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPeriod = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResourcesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _resources.length,
      itemBuilder: (context, index) {
        final resource = _resources[index];
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
                      color: (resource['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      resource['icon'] as IconData,
                      color: resource['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${resource['percentage']}%',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                resource['name'],
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    '${resource['used']}',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    ' / ${resource['total']} ${resource['unit'] ?? ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: resource['percentage'] / 100,
                  backgroundColor: (resource['color'] as Color).withOpacity(
                    0.2,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    resource['color'] as Color,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCPUChart() {
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
          Text(
            'CPU Usage Trend',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _cpuHistory.map((data) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: (data['value'] as int) * 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                const Color(0xFF3b82f6),
                                const Color(0xFF3b82f6).withOpacity(0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['time'],
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryChart() {
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
          Text(
            'Memory Usage Trend',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _memoryHistory.map((data) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: (data['value'] as int) * 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                const Color(0xFF8b5cf6),
                                const Color(0xFF8b5cf6).withOpacity(0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['time'],
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProcesses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Resource Consumers',
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
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF21262d))),
                ),
                children: [
                  _buildTableHeader('Process Name'),
                  _buildTableHeader('CPU %'),
                  _buildTableHeader('Memory (GB)'),
                  _buildTableHeader('PID'),
                ],
              ),
              ..._topProcesses.map((process) {
                return TableRow(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF21262d)),
                    ),
                  ),
                  children: [
                    _buildTableCell(process['name']),
                    _buildTableCell('${process['cpu']}%'),
                    _buildTableCell('${process['memory']} GB'),
                    _buildTableCell('${process['pid']}'),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
      ),
    );
  }
}
