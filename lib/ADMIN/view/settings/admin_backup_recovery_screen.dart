import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminBackupRecoveryScreen extends StatefulWidget {
  const AdminBackupRecoveryScreen({super.key});

  @override
  State<AdminBackupRecoveryScreen> createState() =>
      _AdminBackupRecoveryScreenState();
}

class _AdminBackupRecoveryScreenState extends State<AdminBackupRecoveryScreen> {
  String _backupType = 'Full';
  String _schedule = 'Daily';
  bool _autoBackup = true;
  int _retentionDays = 30;

  final List<Map<String, dynamic>> _backupHistory = [
    {
      'id': 'BKP-001',
      'type': 'Full',
      'date': '2025-11-29 02:00 AM',
      'size': '2.4 GB',
      'duration': '12m 34s',
      'status': 'Success',
      'location': '/backups/full_20251129_020000.zip',
    },
    {
      'id': 'BKP-002',
      'type': 'Incremental',
      'date': '2025-11-28 02:00 AM',
      'size': '456 MB',
      'duration': '3m 18s',
      'status': 'Success',
      'location': '/backups/incr_20251128_020000.zip',
    },
    {
      'id': 'BKP-003',
      'type': 'Full',
      'date': '2025-11-27 02:00 AM',
      'size': '2.3 GB',
      'duration': '11m 56s',
      'status': 'Success',
      'location': '/backups/full_20251127_020000.zip',
    },
    {
      'id': 'BKP-004',
      'type': 'Incremental',
      'date': '2025-11-26 02:00 AM',
      'size': '512 MB',
      'duration': '3m 45s',
      'status': 'Success',
      'location': '/backups/incr_20251126_020000.zip',
    },
    {
      'id': 'BKP-005',
      'type': 'Full',
      'date': '2025-11-25 02:00 AM',
      'size': '2.2 GB',
      'duration': '12m 08s',
      'status': 'Failed',
      'location': 'N/A',
      'error': 'Insufficient storage space',
    },
  ];

  final Map<String, dynamic> _backupConfig = {
    'totalBackups': 45,
    'totalSize': '128 GB',
    'lastBackup': '2 hours ago',
    'nextScheduled': 'Tomorrow at 2:00 AM',
    'successRate': 96,
    'storageUsed': 78,
  };

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
            _buildStatsCards(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildBackupHistory()),
                const SizedBox(width: 16),
                Expanded(child: _buildBackupSettings()),
              ],
            ),
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
                'Backup & Recovery',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage system backups and recovery options',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Create manual backup
          },
          icon: const Icon(Icons.backup, size: 18),
          label: Text(
            'Create Backup Now',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10b981),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Backups',
            _backupConfig['totalBackups'].toString(),
            Icons.folder_copy,
            const Color(0xFF3b82f6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Size',
            _backupConfig['totalSize'],
            Icons.storage,
            const Color(0xFF8b5cf6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Success Rate',
            '${_backupConfig['successRate']}%',
            Icons.check_circle,
            const Color(0xFF10b981),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Last Backup',
            _backupConfig['lastBackup'],
            Icons.schedule,
            const Color(0xFFf59e0b),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupHistory() {
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
            'Backup History',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _backupHistory.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Color(0xFF21262d), height: 24),
            itemBuilder: (context, index) {
              final backup = _backupHistory[index];
              final isSuccess = backup['status'] == 'Success';
              final statusColor = isSuccess
                  ? const Color(0xFF10b981)
                  : const Color(0xFFef4444);

              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isSuccess ? Icons.folder_zip : Icons.error,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              backup['id'],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3b82f6).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF3b82f6),
                                ),
                              ),
                              child: Text(
                                backup['type'],
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3b82f6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          backup['date'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                        if (!isSuccess && backup.containsKey('error')) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Error: ${backup['error']}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFFef4444),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          backup['status'],
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isSuccess) ...[
                        Text(
                          backup['size'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          backup['duration'],
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(width: 12),
                  if (isSuccess)
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white60,
                        size: 20,
                      ),
                      color: const Color(0xFF161b22),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'restore',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.restore,
                                color: Color(0xFF3b82f6),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Restore',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'download',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.download,
                                color: Color(0xFF10b981),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Download',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete,
                                color: Color(0xFFef4444),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackupSettings() {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3b82f6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Color(0xFF3b82f6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Backup Settings',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDropdown(
            'Backup Type',
            _backupType,
            ['Full', 'Incremental', 'Differential'],
            (val) {
              setState(() => _backupType = val!);
            },
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            'Schedule',
            _schedule,
            ['Hourly', 'Daily', 'Weekly', 'Monthly'],
            (val) {
              setState(() => _schedule = val!);
            },
          ),
          const SizedBox(height: 20),
          _buildSwitchTile(
            'Automatic Backup',
            'Enable scheduled automatic backups',
            _autoBackup,
            (val) {
              setState(() => _autoBackup = val);
            },
          ),
          const SizedBox(height: 20),
          _buildSliderTile(
            'Retention Period',
            '$_retentionDays days',
            _retentionDays,
            7,
            90,
            (val) {
              setState(() => _retentionDays = val.round());
            },
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFF21262d)),
          const SizedBox(height: 24),
          Text(
            'Storage Information',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Next Scheduled', _backupConfig['nextScheduled']),
          const SizedBox(height: 12),
          _buildInfoRow('Storage Location', '/var/backups/'),
          const SizedBox(height: 12),
          _buildInfoRow('Storage Used', '${_backupConfig['storageUsed']}%'),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _backupConfig['storageUsed'] / 100,
              backgroundColor: const Color(0xFF21262d),
              valueColor: AlwaysStoppedAnimation<Color>(
                _backupConfig['storageUsed'] > 80
                    ? const Color(0xFFef4444)
                    : const Color(0xFF3b82f6),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Save backup settings
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3b82f6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save Settings',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF161b22),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF21262d)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF161b22),
              style: GoogleFonts.poppins(color: Colors.white),
              items: items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF3b82f6),
        ),
      ],
    );
  }

  Widget _buildSliderTile(
    String title,
    String value,
    int currentValue,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3b82f6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3b82f6),
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: currentValue.toDouble(),
          min: min,
          max: max,
          activeColor: const Color(0xFF3b82f6),
          inactiveColor: const Color(0xFF21262d),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white60),
        ),
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
