import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/admin_system_controller.dart';

class AdminSystemLogsScreen extends StatefulWidget {
  const AdminSystemLogsScreen({super.key});

  @override
  State<AdminSystemLogsScreen> createState() => _AdminSystemLogsScreenState();
}

class _AdminSystemLogsScreenState extends State<AdminSystemLogsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminSystemController>().loadSystemLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: Consumer<AdminSystemController>(
        builder: (context, controller, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Logs',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0d1117),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF21262d)),
                  ),
                  child: Column(
                    children: controller.systemLogs
                        .map(
                          (log) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getLogColor(log.level),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '[${log.level}]',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: _getLogColor(log.level),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    log.message,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getLogColor(String level) {
    switch (level.toUpperCase()) {
      case 'ERROR':
        return const Color(0xFFef4444);
      case 'WARNING':
        return const Color(0xFFf59e0b);
      case 'INFO':
        return const Color(0xFF3b82f6);
      default:
        return Colors.white60;
    }
  }
}
