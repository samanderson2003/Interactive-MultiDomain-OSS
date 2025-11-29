import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminIntegrationsScreen extends StatefulWidget {
  const AdminIntegrationsScreen({super.key});

  @override
  State<AdminIntegrationsScreen> createState() =>
      _AdminIntegrationsScreenState();
}

class _AdminIntegrationsScreenState extends State<AdminIntegrationsScreen> {
  String _filterCategory = 'All';

  final List<Map<String, dynamic>> _integrations = [
    {
      'name': 'Slack',
      'category': 'Communication',
      'description': 'Send notifications and alerts to Slack channels',
      'status': 'Connected',
      'icon': Icons.chat_bubble,
      'color': Color(0xFF4A154B),
      'lastSync': '2 mins ago',
      'apiCalls': '1,234',
    },
    {
      'name': 'Microsoft Teams',
      'category': 'Communication',
      'description': 'Integrate with Microsoft Teams for collaboration',
      'status': 'Connected',
      'icon': Icons.groups,
      'color': Color(0xFF6264A7),
      'lastSync': '5 mins ago',
      'apiCalls': '892',
    },
    {
      'name': 'Jira',
      'category': 'Project Management',
      'description': 'Sync issues and tickets with Jira',
      'status': 'Connected',
      'icon': Icons.bug_report,
      'color': Color(0xFF0052CC),
      'lastSync': '10 mins ago',
      'apiCalls': '456',
    },
    {
      'name': 'GitHub',
      'category': 'Development',
      'description': 'Connect to GitHub repositories',
      'status': 'Connected',
      'icon': Icons.code,
      'color': Color(0xFF181717),
      'lastSync': '1 hour ago',
      'apiCalls': '2,345',
    },
    {
      'name': 'AWS CloudWatch',
      'category': 'Monitoring',
      'description': 'Monitor AWS resources and logs',
      'status': 'Connected',
      'icon': Icons.cloud,
      'color': Color(0xFFFF9900),
      'lastSync': '15 mins ago',
      'apiCalls': '5,678',
    },
    {
      'name': 'Datadog',
      'category': 'Monitoring',
      'description': 'Application performance monitoring',
      'status': 'Disconnected',
      'icon': Icons.analytics,
      'color': Color(0xFF632CA6),
      'lastSync': 'Never',
      'apiCalls': '0',
    },
    {
      'name': 'SendGrid',
      'category': 'Email',
      'description': 'Email delivery service',
      'status': 'Connected',
      'icon': Icons.email,
      'color': Color(0xFF1A82E2),
      'lastSync': '30 mins ago',
      'apiCalls': '789',
    },
    {
      'name': 'Twilio',
      'category': 'Communication',
      'description': 'SMS and voice communication',
      'status': 'Connected',
      'icon': Icons.sms,
      'color': Color(0xFFF22F46),
      'lastSync': '20 mins ago',
      'apiCalls': '234',
    },
    {
      'name': 'Grafana',
      'category': 'Monitoring',
      'description': 'Data visualization and monitoring',
      'status': 'Disconnected',
      'icon': Icons.dashboard,
      'color': Color(0xFFF46800),
      'lastSync': 'Never',
      'apiCalls': '0',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredIntegrations = _filterCategory == 'All'
        ? _integrations
        : _integrations.where((i) => i['category'] == _filterCategory).toList();

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
            _buildIntegrationsGrid(filteredIntegrations),
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
                'Integrations',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Connect external services and tools',
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
              value: _filterCategory,
              dropdownColor: const Color(0xFF161b22),
              style: GoogleFonts.poppins(color: Colors.white),
              items:
                  [
                    'All',
                    'Communication',
                    'Monitoring',
                    'Development',
                    'Project Management',
                    'Email',
                  ].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _filterCategory = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    final connected = _integrations
        .where((i) => i['status'] == 'Connected')
        .length;
    final disconnected = _integrations
        .where((i) => i['status'] == 'Disconnected')
        .length;
    final totalApiCalls = _integrations.fold<int>(
      0,
      (sum, i) =>
          sum + int.parse((i['apiCalls'] as String).replaceAll(',', '')),
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Integrations',
            '${_integrations.length}',
            Icons.extension,
            const Color(0xFF3b82f6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Connected',
            '$connected',
            Icons.check_circle,
            const Color(0xFF10b981),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Disconnected',
            '$disconnected',
            Icons.cancel,
            const Color(0xFFef4444),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'API Calls (24h)',
            '${(totalApiCalls / 1000).toStringAsFixed(1)}K',
            Icons.api,
            const Color(0xFF8b5cf6),
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
              fontSize: 24,
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

  Widget _buildIntegrationsGrid(List<Map<String, dynamic>> integrations) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: integrations.length,
      itemBuilder: (context, index) {
        final integration = integrations[index];
        return _buildIntegrationCard(integration);
      },
    );
  }

  Widget _buildIntegrationCard(Map<String, dynamic> integration) {
    final isConnected = integration['status'] == 'Connected';
    final statusColor = isConnected
        ? const Color(0xFF10b981)
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
                  color: (integration['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  integration['icon'] as IconData,
                  color: integration['color'] as Color,
                  size: 24,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(width: 6),
                    Text(
                      integration['status'],
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            integration['name'],
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            integration['category'],
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white60),
          ),
          const SizedBox(height: 8),
          Text(
            integration['description'],
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          const Divider(color: Color(0xFF21262d), height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Sync',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white60,
                    ),
                  ),
                  Text(
                    integration['lastSync'],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'API Calls',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.white60,
                    ),
                  ),
                  Text(
                    integration['apiCalls'],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Configure integration
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3b82f6),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Configure',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                color: const Color(0xFF3b82f6),
                onPressed: () {
                  // Test integration
                },
                tooltip: 'Test Connection',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
