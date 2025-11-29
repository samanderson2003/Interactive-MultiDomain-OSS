import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminAlarmsIncidentsScreen extends StatefulWidget {
  const AdminAlarmsIncidentsScreen({super.key});

  @override
  State<AdminAlarmsIncidentsScreen> createState() =>
      _AdminAlarmsIncidentsScreenState();
}

class _AdminAlarmsIncidentsScreenState
    extends State<AdminAlarmsIncidentsScreen> {
  String _severityFilter = 'All';
  String _domainFilter = 'All';

  final List<Map<String, dynamic>> _alarms = [
    {
      'id': 'ALM-001',
      'severity': 'Critical',
      'title': 'Network Link Down',
      'description': 'Primary fiber link disconnected on Core Router CR-01',
      'domain': 'CORE',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'status': 'Active',
      'source': 'CR-01',
    },
    {
      'id': 'ALM-002',
      'severity': 'Major',
      'title': 'High CPU Usage',
      'description': 'CPU utilization exceeds 85% threshold on eNodeB-05',
      'domain': 'RAN',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 32)),
      'status': 'Active',
      'source': 'eNodeB-05',
    },
    {
      'id': 'ALM-003',
      'severity': 'Critical',
      'title': 'Power Supply Failure',
      'description': 'Redundant power supply failed on Edge Switch ES-12',
      'domain': 'IP',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'status': 'Acknowledged',
      'source': 'ES-12',
    },
    {
      'id': 'ALM-004',
      'severity': 'Minor',
      'title': 'High Temperature',
      'description': 'Temperature sensor reports 68°C on Router R-08',
      'domain': 'IP',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'Active',
      'source': 'R-08',
    },
    {
      'id': 'ALM-005',
      'severity': 'Major',
      'title': 'Memory Threshold Exceeded',
      'description': 'Memory usage at 92% on MME Server',
      'domain': 'CORE',
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'status': 'Active',
      'source': 'MME-01',
    },
    {
      'id': 'ALM-006',
      'severity': 'Minor',
      'title': 'Configuration Mismatch',
      'description': 'VLAN configuration inconsistency detected',
      'domain': 'IP',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'status': 'Resolved',
      'source': 'SW-24',
    },
    {
      'id': 'ALM-007',
      'severity': 'Critical',
      'title': 'Database Connection Lost',
      'description': 'HSS database connectivity failure',
      'domain': 'CORE',
      'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
      'status': 'Acknowledged',
      'source': 'HSS-DB',
    },
    {
      'id': 'ALM-008',
      'severity': 'Major',
      'title': 'Packet Loss Detected',
      'description': 'Packet loss rate exceeds 5% on transmission path',
      'domain': 'RAN',
      'timestamp': DateTime.now().subtract(const Duration(hours: 8)),
      'status': 'Active',
      'source': 'eNodeB-12',
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
            _buildFilters(),
            const SizedBox(height: 24),
            _buildAlarmsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final critical = _alarms.where((a) => a['severity'] == 'Critical').length;
    final major = _alarms.where((a) => a['severity'] == 'Major').length;
    final minor = _alarms.where((a) => a['severity'] == 'Minor').length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alarms & Incidents',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time network alarm monitoring',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Alarms refreshed',
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
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Critical',
                critical.toString(),
                const Color(0xFFef4444),
                Icons.error,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Major',
                major.toString(),
                const Color(0xFFf59e0b),
                Icons.warning,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Minor',
                minor.toString(),
                const Color(0xFF3b82f6),
                Icons.info,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Total',
                _alarms.length.toString(),
                const Color(0xFF8b5cf6),
                Icons.list,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                // Search functionality can be added here if needed
              },
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search alarms...',
                hintStyle: GoogleFonts.poppins(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                filled: true,
                fillColor: const Color(0xFF161b22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildSeverityFilter(),
          const SizedBox(width: 12),
          _buildDomainFilter(),
        ],
      ),
    );
  }

  Widget _buildSeverityFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161b22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _severityFilter,
          dropdownColor: const Color(0xFF161b22),
          style: GoogleFonts.poppins(color: Colors.white),
          items: [
            DropdownMenuItem(value: 'All', child: Text('All Severities')),
            ...['Critical', 'Major', 'Minor'].map((severity) {
              return DropdownMenuItem(value: severity, child: Text(severity));
            }),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _severityFilter = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDomainFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161b22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _domainFilter,
          dropdownColor: const Color(0xFF161b22),
          style: GoogleFonts.poppins(color: Colors.white),
          items: [
            DropdownMenuItem(value: 'All', child: Text('All Domains')),
            ...['RAN', 'CORE', 'IP'].map((domain) {
              return DropdownMenuItem(value: domain, child: Text(domain));
            }),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _domainFilter = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildAlarmsTable() {
    // Filter alarms based on selected filters
    final filteredAlarms = _alarms.where((alarm) {
      final severityMatch =
          _severityFilter == 'All' || alarm['severity'] == _severityFilter;
      final domainMatch =
          _domainFilter == 'All' || alarm['domain'] == _domainFilter;
      return severityMatch && domainMatch;
    }).toList();

    if (filteredAlarms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.check_circle_outline, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              Text(
                'No alarms found',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white60),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(3),
          4: FlexColumnWidth(1),
          5: FlexColumnWidth(1.5),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF21262d))),
            ),
            children: [
              _buildHeaderCell('Severity'),
              _buildHeaderCell('Source'),
              _buildHeaderCell('Domain'),
              _buildHeaderCell('Description'),
              _buildHeaderCell('Status'),
              _buildHeaderCell('Actions'),
            ],
          ),
          ...filteredAlarms.map((alarm) {
            return TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF21262d))),
              ),
              children: [
                _buildCell(_buildSeverityBadge(alarm['severity'] as String)),
                _buildCell(
                  Text(
                    alarm['source'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildCell(
                  Text(
                    alarm['domain'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildCell(
                  Text(
                    alarm['description'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildCell(_buildStatusBadge(alarm['status'] as String)),
                _buildCell(_buildActions(alarm)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
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

  Widget _buildCell(Widget child) {
    return Padding(padding: const EdgeInsets.all(16), child: child);
  }

  Widget _buildSeverityBadge(String severity) {
    Color color;
    switch (severity) {
      case 'Critical':
        color = const Color(0xFFef4444);
        break;
      case 'Major':
        color = const Color(0xFFf59e0b);
        break;
      default:
        color = const Color(0xFFfbbf24);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        severity,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Acknowledged':
        color = const Color(0xFF3b82f6);
        break;
      case 'Cleared':
        color = const Color(0xFF10b981);
        break;
      default:
        color = const Color(0xFFef4444);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActions(Map<String, dynamic> alarm) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (alarm['status'] == 'Active')
          IconButton(
            icon: const Icon(Icons.check, size: 18),
            color: const Color(0xFF3b82f6),
            tooltip: 'Acknowledge',
            onPressed: () {
              // Acknowledge alarm action
            },
          ),
        if (alarm['status'] != 'Cleared')
          IconButton(
            icon: const Icon(Icons.clear, size: 18),
            color: const Color(0xFF10b981),
            tooltip: 'Clear',
            onPressed: () {
              // Clear alarm action
            },
          ),
      ],
    );
  }
}
