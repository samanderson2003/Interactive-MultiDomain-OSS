import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminNetworkTopologyScreen extends StatefulWidget {
  const AdminNetworkTopologyScreen({super.key});

  @override
  State<AdminNetworkTopologyScreen> createState() =>
      _AdminNetworkTopologyScreenState();
}

class _AdminNetworkTopologyScreenState
    extends State<AdminNetworkTopologyScreen> {
  String _selectedDomain = 'All Domains';

  final List<Map<String, dynamic>> _topologyNodes = [
    {
      'name': 'Core Router',
      'type': 'Router',
      'status': 'Active',
      'connections': 8,
      'domain': 'CORE',
    },
    {
      'name': 'Edge Switch 1',
      'type': 'Switch',
      'status': 'Active',
      'connections': 12,
      'domain': 'IP',
    },
    {
      'name': 'Edge Switch 2',
      'type': 'Switch',
      'status': 'Active',
      'connections': 10,
      'domain': 'IP',
    },
    {
      'name': 'RAN Gateway',
      'type': 'Gateway',
      'status': 'Active',
      'connections': 15,
      'domain': 'RAN',
    },
    {
      'name': 'MME Server',
      'type': 'Server',
      'status': 'Active',
      'connections': 6,
      'domain': 'CORE',
    },
    {
      'name': 'HSS Database',
      'type': 'Database',
      'status': 'Active',
      'connections': 4,
      'domain': 'CORE',
    },
    {
      'name': 'eNodeB-01',
      'type': 'Base Station',
      'status': 'Active',
      'connections': 3,
      'domain': 'RAN',
    },
    {
      'name': 'eNodeB-02',
      'type': 'Base Station',
      'status': 'Warning',
      'connections': 3,
      'domain': 'RAN',
    },
    {
      'name': 'Firewall',
      'type': 'Security',
      'status': 'Active',
      'connections': 5,
      'domain': 'IP',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

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
            _buildTopologyView(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Network Topology',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Visual representation of network infrastructure',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
            ),
          ],
        ),
        Row(
          children: [
            _buildDomainFilter(),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Topology refreshed',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: const Color(0xFF10b981),
                  ),
                );
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3b82f6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDomainFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDomain,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          dropdownColor: const Color(0xFF0d1117),
          items: ['All Domains', 'RAN', 'CORE', 'IP'].map((domain) {
            return DropdownMenuItem(
              value: domain,
              child: Text(domain, style: GoogleFonts.poppins()),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedDomain = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTopologyView() {
    final filteredNodes = _selectedDomain == 'All Domains'
        ? _topologyNodes
        : _topologyNodes
              .where((node) => node['domain'] == _selectedDomain)
              .toList();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatsCard(
                'Total Nodes',
                filteredNodes.length.toString(),
                Icons.device_hub,
                const Color(0xFF3b82f6),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatsCard(
                'Active',
                filteredNodes
                    .where((n) => n['status'] == 'Active')
                    .length
                    .toString(),
                Icons.check_circle,
                const Color(0xFF10b981),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatsCard(
                'Warning',
                filteredNodes
                    .where((n) => n['status'] == 'Warning')
                    .length
                    .toString(),
                Icons.warning,
                const Color(0xFFf59e0b),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatsCard(
                'Connections',
                filteredNodes
                    .fold<int>(0, (sum, n) => sum + (n['connections'] as int))
                    .toString(),
                Icons.link,
                const Color(0xFF8b5cf6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          height: 600,
          decoration: BoxDecoration(
            color: const Color(0xFF0d1117),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF21262d)),
          ),
          child: Stack(
            children: [
              // Grid background
              CustomPaint(size: Size.infinite, painter: GridPainter()),
              // Topology visualization
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_tree, size: 80, color: Colors.white24),
                    const SizedBox(height: 24),
                    Text(
                      'Network Topology Visualization',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Interactive topology diagram coming soon',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLegend(),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: filteredNodes.map((node) => _buildNodeCard(node)).toList(),
        ),
      ],
    );
  }

  Widget _buildStatsCard(
    String label,
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeCard(Map<String, dynamic> node) {
    final statusColor = node['status'] == 'Active'
        ? const Color(0xFF10b981)
        : const Color(0xFFf59e0b);

    return Container(
      width: 250,
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
              Icon(
                _getNodeIcon(node['type'].toString()),
                color: _getDomainColor(node['domain'].toString()),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  node['name'].toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNodeInfo('Type', node['type'].toString(), Icons.category),
          const SizedBox(height: 8),
          _buildNodeInfo('Domain', node['domain'].toString(), Icons.domain),
          const SizedBox(height: 8),
          _buildNodeInfo(
            'Connections',
            node['connections'].toString(),
            Icons.link,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  node['status'].toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white60),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white60),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  IconData _getNodeIcon(String type) {
    switch (type) {
      case 'Router':
        return Icons.router;
      case 'Switch':
        return Icons.switch_access_shortcut;
      case 'Gateway':
        return Icons.vpn_lock;
      case 'Server':
        return Icons.dns;
      case 'Database':
        return Icons.storage;
      case 'Base Station':
        return Icons.cell_tower;
      case 'Security':
        return Icons.security;
      default:
        return Icons.device_hub;
    }
  }

  Color _getDomainColor(String domain) {
    switch (domain) {
      case 'RAN':
        return const Color(0xFF3b82f6);
      case 'CORE':
        return const Color(0xFF10b981);
      case 'IP':
        return const Color(0xFFf59e0b);
      default:
        return Colors.white60;
    }
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161b22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendItem(Icons.cell_tower, 'RAN', const Color(0xFF3b82f6)),
          const SizedBox(width: 24),
          _buildLegendItem(Icons.hub, 'CORE', const Color(0xFF10b981)),
          const SizedBox(width: 24),
          _buildLegendItem(Icons.router, 'IP', const Color(0xFFf59e0b)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF21262d)
      ..strokeWidth = 1;

    const gridSpacing = 40.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
