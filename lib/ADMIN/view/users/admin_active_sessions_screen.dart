import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/admin_user_controller.dart';

class AdminActiveSessionsScreen extends StatefulWidget {
  const AdminActiveSessionsScreen({super.key});

  @override
  State<AdminActiveSessionsScreen> createState() =>
      _AdminActiveSessionsScreenState();
}

class _AdminActiveSessionsScreenState extends State<AdminActiveSessionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUserController>().loadActiveSessions();
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
            _buildSessionsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AdminUserController>(
      builder: (context, controller, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Sessions',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.activeSessions.length} active sessions',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => controller.loadActiveSessions(),
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
        );
      },
    );
  }

  Widget _buildSessionsTable() {
    return Consumer<AdminUserController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (controller.activeSessions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    'No active sessions',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white60,
                    ),
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
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
              4: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF21262d))),
                ),
                children: [
                  _buildHeaderCell('User'),
                  _buildHeaderCell('Device'),
                  _buildHeaderCell('IP Address'),
                  _buildHeaderCell('Login Time'),
                  _buildHeaderCell('Actions'),
                ],
              ),
              ...controller.activeSessions.map((session) {
                return TableRow(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF21262d)),
                    ),
                  ),
                  children: [
                    _buildCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.userName,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            session.email,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildCell(
                      Text(
                        session.deviceInfo,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildCell(
                      Text(
                        session.ipAddress,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildCell(
                      Text(
                        _formatDateTime(session.loginTime),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildCell(
                      IconButton(
                        onPressed: () =>
                            _terminateSession(controller, session.sessionId),
                        icon: const Icon(Icons.close),
                        color: const Color(0xFFef4444),
                        tooltip: 'Terminate Session',
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
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

  Future<void> _terminateSession(
    AdminUserController controller,
    String sessionId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0d1117),
        title: Text(
          'Terminate Session',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to terminate this session? The user will be logged out immediately.',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFef4444),
            ),
            child: const Text('Terminate'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await controller.terminateSession(sessionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Session terminated successfully',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFF10b981),
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
