import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../auth/controller/auth_controller.dart';
import 'dashboard/admin_overview_dashboard.dart';
import 'dashboard/admin_advanced_analytics.dart';
import 'users/admin_users_list_screen.dart';
import 'users/admin_roles_permissions_screen.dart';
import 'users/admin_active_sessions_screen.dart';
import 'users/admin_activity_logs_screen.dart';
import 'network/admin_network_topology_screen.dart';
import 'network/admin_alarms_incidents_screen.dart';
import 'network/admin_network_elements_screen.dart';
import 'network/admin_domain_overview_screen.dart';
import 'network/admin_configuration_screen.dart';
import 'analytics/admin_performance_metrics_screen.dart';
import 'analytics/admin_reports_center_screen.dart';
import 'analytics/admin_data_export_screen.dart';
import 'system/admin_system_health_screen.dart';
import 'system/admin_resource_utilization_screen.dart';
import 'system/admin_service_status_screen.dart';
import 'system/admin_system_logs_screen.dart';
import 'settings/admin_system_settings_screen.dart';
import 'settings/admin_integrations_screen.dart';
import 'settings/admin_notifications_screen.dart';
import 'settings/admin_backup_recovery_screen.dart';
import 'settings/admin_audit_compliance_screen.dart';
import 'communication/admin_announcements_screen.dart';
import 'communication/admin_support_tickets_screen.dart';
import 'communication/admin_knowledge_base_screen.dart';
import 'profile/admin_profile_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  bool _isExpanded = true;
  String _currentPage = 'overview';

  final Map<String, Widget> _pages = {
    'overview': const AdminOverviewDashboard(),
    'advanced-analytics': const AdminAdvancedAnalytics(),
    'users': const AdminUsersListScreen(),
    'roles-permissions': const AdminRolesPermissionsScreen(),
    'active-sessions': const AdminActiveSessionsScreen(),
    'activity-logs': const AdminActivityLogsScreen(),
    'network-topology': const AdminNetworkTopologyScreen(),
    'alarms-incidents': const AdminAlarmsIncidentsScreen(),
    'network-elements': const AdminNetworkElementsScreen(),
    'domain-overview': const AdminDomainOverviewScreen(),
    'network-configuration': const AdminConfigurationScreen(),
    'performance-metrics': const AdminPerformanceMetricsScreen(),
    'reports-center': const AdminReportsCenterScreen(),
    'data-export': const AdminDataExportScreen(),
    'health': const AdminSystemHealthScreen(),
    'resources': const AdminResourceUtilizationScreen(),
    'services': const AdminServiceStatusScreen(),
    'system-logs': const AdminSystemLogsScreen(),
    'settings': const AdminSystemSettingsScreen(),
    'integrations': const AdminIntegrationsScreen(),
    'notifications': const AdminNotificationsScreen(),
    'backup': const AdminBackupRecoveryScreen(),
    'audit-compliance': const AdminAuditComplianceScreen(),
    'announcements': const AdminAnnouncementsScreen(),
    'support-tickets': const AdminSupportTicketsScreen(),
    'knowledge-base': const AdminKnowledgeBaseScreen(),
    'profile': const AdminProfileScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: _pages[_currentPage] ?? const AdminOverviewDashboard(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isExpanded ? 260 : 70,
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Column(
        children: [
          _buildSidebarHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildNavSection('DASHBOARD', [
                    _buildNavItem(
                      icon: Icons.dashboard_outlined,
                      label: 'Overview',
                      page: 'overview',
                    ),
                    _buildNavItem(
                      icon: Icons.analytics_outlined,
                      label: 'Advanced Analytics',
                      page: 'advanced-analytics',
                    ),
                  ]),
                  _buildNavSection('USER MANAGEMENT', [
                    _buildNavItem(
                      icon: Icons.people_outline,
                      label: 'All Users',
                      page: 'users',
                    ),
                    _buildNavItem(
                      icon: Icons.shield_outlined,
                      label: 'Roles & Permissions',
                      page: 'roles-permissions',
                    ),
                    _buildNavItem(
                      icon: Icons.history_outlined,
                      label: 'Activity Logs',
                      page: 'activity-logs',
                    ),
                  ]),
                  _buildNavSection('NETWORK', [
                    _buildNavItem(
                      icon: Icons.hub_outlined,
                      label: 'Topology',
                      page: 'network-topology',
                    ),
                    _buildNavItem(
                      icon: Icons.warning_amber_outlined,
                      label: 'Alarms & Incidents',
                      page: 'alarms-incidents',
                    ),
                    _buildNavItem(
                      icon: Icons.router_outlined,
                      label: 'Network Elements',
                      page: 'network-elements',
                    ),
                    _buildNavItem(
                      icon: Icons.domain_outlined,
                      label: 'Domain Overview',
                      page: 'domain-overview',
                    ),
                  ]),
                  _buildNavSection('SYSTEM', [
                    _buildNavItem(
                      icon: Icons.health_and_safety_outlined,
                      label: 'System Health',
                      page: 'health',
                    ),
                    _buildNavItem(
                      icon: Icons.memory_outlined,
                      label: 'Resource Usage',
                      page: 'resources',
                    ),
                    _buildNavItem(
                      icon: Icons.dns_outlined,
                      label: 'Service Status',
                      page: 'services',
                    ),
                  ]),
                  _buildNavSection('SETTINGS', [
                    _buildNavItem(
                      icon: Icons.settings_outlined,
                      label: 'System Settings',
                      page: 'settings',
                    ),
                    _buildNavItem(
                      icon: Icons.integration_instructions_outlined,
                      label: 'Integrations',
                      page: 'integrations',
                    ),
                    _buildNavItem(
                      icon: Icons.backup_outlined,
                      label: 'Backup & Recovery',
                      page: 'backup',
                    ),
                  ]),
                ],
              ),
            ),
          ),
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 16 : 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: !_isExpanded
          ? Center(
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                tooltip: 'Expand',
              ),
            )
          : Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFef4444), Color(0xFFdc2626)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Panel',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        'System Administrator',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: const Icon(
                    Icons.menu_open,
                    color: Colors.white,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Collapse',
                ),
              ],
            ),
    );
  }

  Widget _buildNavSection(String title, List<Widget> items) {
    if (!_isExpanded) {
      return Column(children: items);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String page,
  }) {
    final isActive = _currentPage == page;

    return Tooltip(
      message: _isExpanded ? '' : label,
      child: InkWell(
        onTap: () {
          setState(() {
            _currentPage = page;
          });
        },
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: _isExpanded ? 8 : 11,
            vertical: 2,
          ),
          padding: EdgeInsets.all(_isExpanded ? 12 : 6),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFef4444).withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? const Color(0xFFef4444).withOpacity(0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: _isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive
                    ? const Color(0xFFef4444)
                    : Colors.white.withOpacity(0.6),
                size: 20,
              ),
              if (_isExpanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: EdgeInsets.all(_isExpanded ? 16 : 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Consumer<AuthController>(
        builder: (context, authController, _) {
          final user = authController.currentUser;
          if (user == null) return const SizedBox.shrink();

          if (!_isExpanded) {
            return Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFef4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }

          return InkWell(
            onTap: () {
              // Navigate to profile
            },
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFef4444),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        user.email,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
