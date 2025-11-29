import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../controller/admin_controller.dart';

class AdminActivityLogsScreen extends StatefulWidget {
  const AdminActivityLogsScreen({super.key});

  @override
  State<AdminActivityLogsScreen> createState() =>
      _AdminActivityLogsScreenState();
}

class _AdminActivityLogsScreenState extends State<AdminActivityLogsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  String _searchQuery = '';

  // Static activity data for demonstration
  final List<Map<String, dynamic>> _staticActivities = [
    {
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'user': 'John Doe',
      'action': 'Login',
      'description': 'User logged in from Chrome browser',
      'ip': '192.168.1.101',
    },
    {
      'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
      'user': 'Jane Smith',
      'action': 'Update',
      'description': 'Updated network configuration for RAN domain',
      'ip': '192.168.1.102',
    },
    {
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'user': 'Mike Johnson',
      'action': 'Create',
      'description': 'Created new alarm rule for critical alerts',
      'ip': '192.168.1.103',
    },
    {
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'user': 'Sarah Williams',
      'action': 'Delete',
      'description': 'Deleted outdated user account',
      'ip': '192.168.1.104',
    },
    {
      'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
      'user': 'John Doe',
      'action': 'Edit',
      'description': 'Modified system settings for backup schedule',
      'ip': '192.168.1.101',
    },
    {
      'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
      'user': 'Emily Davis',
      'action': 'Login',
      'description': 'User logged in from Firefox browser',
      'ip': '192.168.1.105',
    },
    {
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'user': 'Mike Johnson',
      'action': 'Update',
      'description': 'Updated user permissions for NOC team',
      'ip': '192.168.1.103',
    },
    {
      'timestamp': DateTime.now().subtract(const Duration(hours: 6)),
      'user': 'Jane Smith',
      'action': 'Create',
      'description': 'Created new monitoring dashboard',
      'ip': '192.168.1.102',
    },
  ];

  // User activity stats for graph
  final Map<String, int> _userActivityStats = {
    'John Doe': 45,
    'Jane Smith': 38,
    'Mike Johnson': 32,
    'Sarah Williams': 28,
    'Emily Davis': 25,
    'David Brown': 20,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadDashboardStats();
    });
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
            _buildActivityStats(),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 24),
            _buildActivityTable(),
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
              'Activity Logs',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Track all user activities and system events',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _exportLogs(),
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Export'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10b981),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<AdminController>().loadDashboardStats(),
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
            flex: 2,
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search activities...',
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
          OutlinedButton.icon(
            onPressed: () => _selectDateRange(),
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(
              '${_startDate.day}/${_startDate.month} - ${_endDate.day}/${_endDate.month}',
              style: GoogleFonts.poppins(),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              side: const BorderSide(color: Color(0xFF21262d)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStats() {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildUserActivityChart()),
        const SizedBox(width: 24),
        Expanded(flex: 2, child: _buildActivitySummary()),
      ],
    );
  }

  Widget _buildUserActivityChart() {
    final maxActivity = _userActivityStats.values.reduce(math.max);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Activity Analysis',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Activities in the last 7 days',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
          ),
          const SizedBox(height: 24),
          ..._userActivityStats.entries.map((entry) {
            final percentage = (entry.value / maxActivity);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${entry.value} actions',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF3b82f6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 8,
                      backgroundColor: const Color(0xFF21262d),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.lerp(
                          const Color(0xFF3b82f6),
                          const Color(0xFF10b981),
                          percentage,
                        )!,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActivitySummary() {
    final totalActivities = _staticActivities.length;
    final loginCount = _staticActivities
        .where((a) => a['action'] == 'Login')
        .length;
    final updateCount = _staticActivities
        .where((a) => a['action'] == 'Update')
        .length;
    final createCount = _staticActivities
        .where((a) => a['action'] == 'Create')
        .length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Summary',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          _buildSummaryItem(
            'Total Activities',
            totalActivities.toString(),
            Icons.analytics,
            const Color(0xFF3b82f6),
          ),
          const SizedBox(height: 16),
          _buildSummaryItem(
            'Logins',
            loginCount.toString(),
            Icons.login,
            const Color(0xFF8b5cf6),
          ),
          const SizedBox(height: 16),
          _buildSummaryItem(
            'Updates',
            updateCount.toString(),
            Icons.update,
            const Color(0xFF10b981),
          ),
          const SizedBox(height: 16),
          _buildSummaryItem(
            'Created',
            createCount.toString(),
            Icons.add_circle,
            const Color(0xFFf59e0b),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTable() {
    final filteredActivities = _staticActivities.where((activity) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return activity['action'].toString().toLowerCase().contains(query) ||
            activity['description'].toString().toLowerCase().contains(query) ||
            activity['user'].toString().toLowerCase().contains(query);
      }
      return true;
    }).toList();

    if (filteredActivities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.history, size: 64, color: Colors.white24),
              const SizedBox(height: 16),
              Text(
                'No activity logs found',
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
          0: FlexColumnWidth(1.5),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(3),
          4: FlexColumnWidth(1.5),
        },
        children: [
          TableRow(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF21262d))),
            ),
            children: [
              _buildHeaderCell('Timestamp'),
              _buildHeaderCell('User'),
              _buildHeaderCell('Action'),
              _buildHeaderCell('Description'),
              _buildHeaderCell('IP Address'),
            ],
          ),
          ...filteredActivities.map((activity) {
            return TableRow(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFF21262d))),
              ),
              children: [
                _buildCell(
                  Text(
                    _formatDateTime(activity['timestamp'] as DateTime),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildCell(
                  Text(
                    activity['user'].toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getActionColor(
                        activity['action'].toString(),
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getActionColor(activity['action'].toString()),
                      ),
                    ),
                    child: Text(
                      activity['action'].toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: _getActionColor(activity['action'].toString()),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                _buildCell(
                  Text(
                    activity['description'].toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildCell(
                  Text(
                    activity['ip']?.toString() ?? 'N/A',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white60,
                    ),
                  ),
                ),
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

  Color _getActionColor(String action) {
    if (action.toLowerCase().contains('create') ||
        action.toLowerCase().contains('add')) {
      return const Color(0xFF10b981);
    } else if (action.toLowerCase().contains('delete') ||
        action.toLowerCase().contains('remove')) {
      return const Color(0xFFef4444);
    } else if (action.toLowerCase().contains('update') ||
        action.toLowerCase().contains('edit')) {
      return const Color(0xFF3b82f6);
    } else if (action.toLowerCase().contains('login')) {
      return const Color(0xFF8b5cf6);
    }
    return const Color(0xFFf59e0b);
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _exportLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exporting activity logs...',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF3b82f6),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
