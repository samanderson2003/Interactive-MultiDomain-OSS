import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants.dart';
import '../../controller/admin_user_controller.dart';
import '../../model/admin_user_model.dart';

class AdminUsersListScreen extends StatefulWidget {
  const AdminUsersListScreen({super.key});

  @override
  State<AdminUsersListScreen> createState() => _AdminUsersListScreenState();
}

class _AdminUsersListScreenState extends State<AdminUsersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUserController>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Consumer<AdminUserController>(
              builder: (context, controller, _) {
                if (controller.isLoading && controller.users.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFef4444)),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(isMobile ? 12 : 24),
                      child: _buildUsersTable(controller),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Management',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage all system users and their permissions',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Consumer<AdminUserController>(
                        builder: (context, controller, _) {
                          return _buildSearchBar(controller);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFef4444),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Icon(Icons.add, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Consumer<AdminUserController>(
                  builder: (context, controller, _) {
                    return _buildFilterDropdown(controller);
                  },
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Management',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage all system users and their permissions',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Consumer<AdminUserController>(
                builder: (context, controller, _) {
                  return Row(
                    children: [
                      _buildFilterDropdown(controller),
                      const SizedBox(width: 12),
                      _buildSearchBar(controller),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to add user page
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFef4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(
                          'Add User',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => controller.loadUsers(),
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        tooltip: 'Refresh',
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterDropdown(AdminUserController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButton<UserRole?>(
        value: null, // controller's filter role
        hint: Text(
          'Filter by Role',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        icon: const Icon(Icons.filter_list, color: Colors.white, size: 18),
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF0d1117),
        items: [
          DropdownMenuItem(
            value: null,
            child: Text(
              'All Roles',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
            ),
          ),
          ...UserRole.values.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(
                role.displayName,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
              ),
            );
          }),
        ],
        onChanged: (value) {
          controller.setRoleFilter(value);
        },
      ),
    );
  }

  Widget _buildSearchBar(AdminUserController controller) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search users...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.4),
            fontSize: 13,
          ),
          border: InputBorder.none,
          icon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.4),
            size: 20,
          ),
        ),
        onChanged: (value) => controller.setSearchQuery(value),
      ),
    );
  }

  Widget _buildUsersTable(AdminUserController controller) {
    final users = controller.users;

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2.5),
          1: FlexColumnWidth(2.5),
          2: FlexColumnWidth(1.8),
          3: FlexColumnWidth(1.2),
          4: FlexColumnWidth(1.2),
          5: FlexColumnWidth(1.3),
        },
        children: [
          _buildTableHeader(),
          ...users.map((user) => _buildTableRow(user, controller)),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      children: [
        _buildHeaderCell('User'),
        _buildHeaderCell('Email'),
        _buildHeaderCell('Role'),
        _buildHeaderCell('Status'),
        _buildHeaderCell('Last Login'),
        _buildHeaderCell('Actions'),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.7),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  TableRow _buildTableRow(AdminUser user, AdminUserController controller) {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      children: [
        _buildUserCell(user),
        _buildTextCell(user.email),
        _buildRoleCell(user.role),
        _buildStatusCell(user.isActive),
        _buildTextCell(_formatDate(user.lastLogin)),
        _buildActionsCell(user, controller),
      ],
    );
  }

  Widget _buildUserCell(AdminUser user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3b82f6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                user.initials,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.employeeId,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.white.withOpacity(0.8),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildRoleCell(UserRole role) {
    final colors = {
      UserRole.ADMIN: const Color(0xFFef4444),
      UserRole.RAN_ENGINEER: const Color(0xFF3b82f6),
      UserRole.CORE_ENGINEER: const Color(0xFF10b981),
      UserRole.IP_ENGINEER: const Color(0xFFf59e0b),
      UserRole.NOC_MANAGER: const Color(0xFF8b5cf6),
    };

    final color = colors[role] ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 140),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          role.displayName,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildStatusCell(bool isActive) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 100),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF10b981).withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive
                ? const Color(0xFF10b981).withOpacity(0.3)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF10b981) : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isActive ? const Color(0xFF10b981) : Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCell(AdminUser user, AdminUserController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              // Edit user
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: 'Edit',
            color: const Color(0xFF3b82f6),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),
          IconButton(
            onPressed: () {
              controller.toggleUserStatus(user.uid, !user.isActive);
            },
            icon: Icon(
              user.isActive ? Icons.block : Icons.check_circle_outline,
              size: 18,
            ),
            tooltip: user.isActive ? 'Deactivate' : 'Activate',
            color: user.isActive
                ? const Color(0xFFf59e0b)
                : const Color(0xFF10b981),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),
          IconButton(
            onPressed: () {
              _showDeleteDialog(user, controller);
            },
            icon: const Icon(Icons.delete_outline, size: 18),
            tooltip: 'Delete',
            color: const Color(0xFFef4444),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(AdminUser user, AdminUserController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0d1117),
        title: Text(
          'Delete User',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete ${user.name}? This action cannot be undone.',
          style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteUser(user.uid);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFef4444),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
