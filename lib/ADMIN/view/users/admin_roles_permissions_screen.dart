import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/constants.dart';
import '../../controller/admin_user_controller.dart';

class AdminRolesPermissionsScreen extends StatefulWidget {
  const AdminRolesPermissionsScreen({super.key});

  @override
  State<AdminRolesPermissionsScreen> createState() =>
      _AdminRolesPermissionsScreenState();
}

class _AdminRolesPermissionsScreenState
    extends State<AdminRolesPermissionsScreen> {
  final List<Map<String, dynamic>> _roles = [
    {
      'role': UserRole.ADMIN,
      'permissions': [
        'Full System Access',
        'User Management',
        'System Configuration',
        'Security Settings',
        'Audit Logs',
        'Backup & Recovery',
      ],
    },
    {
      'role': UserRole.RAN_ENGINEER,
      'permissions': [
        'View RAN Dashboard',
        'Manage RAN Elements',
        'Configure RAN Settings',
        'View RAN Alarms',
      ],
    },
    {
      'role': UserRole.CORE_ENGINEER,
      'permissions': [
        'View CORE Dashboard',
        'Manage CORE Elements',
        'Configure CORE Settings',
        'View CORE Alarms',
      ],
    },
    {
      'role': UserRole.IP_ENGINEER,
      'permissions': [
        'View IP Dashboard',
        'Manage IP Elements',
        'Configure IP Settings',
        'View IP Alarms',
      ],
    },
    {
      'role': UserRole.NOC_MANAGER,
      'permissions': [
        'View NOC Dashboard',
        'Monitor All Alarms',
        'View Reports',
        'Manage Incidents',
      ],
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
            _buildRolesGrid(),
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
              'Roles & Permissions',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage role-based access control',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRolesGrid() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: _roles.map((roleData) => _buildRoleCard(roleData)).toList(),
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> roleData) {
    final role = roleData['role'] as UserRole;
    final permissions = roleData['permissions'] as List<String>;

    return Container(
      width: (MediaQuery.of(context).size.width - 80) / 2,
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getRoleColor(role).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getRoleIcon(role),
                  color: _getRoleColor(role),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Consumer<AdminUserController>(
                      builder: (context, controller, _) {
                        final userCount = controller.users
                            .where((u) => u.role == role)
                            .length;
                        return Text(
                          '$userCount users',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: Color(0xFF21262d)),
          Text(
            'Permissions',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          ...permissions.map(
            (permission) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: _getRoleColor(role),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      permission,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white,
                      ),
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

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.ADMIN:
        return const Color(0xFFef4444);
      case UserRole.RAN_ENGINEER:
        return const Color(0xFF3b82f6);
      case UserRole.CORE_ENGINEER:
        return const Color(0xFF10b981);
      case UserRole.IP_ENGINEER:
        return const Color(0xFFf59e0b);
      case UserRole.NOC_MANAGER:
        return const Color(0xFF8b5cf6);
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.ADMIN:
        return Icons.admin_panel_settings;
      case UserRole.RAN_ENGINEER:
        return Icons.cell_tower;
      case UserRole.CORE_ENGINEER:
        return Icons.hub;
      case UserRole.IP_ENGINEER:
        return Icons.router;
      case UserRole.NOC_MANAGER:
        return Icons.monitor;
    }
  }
}
