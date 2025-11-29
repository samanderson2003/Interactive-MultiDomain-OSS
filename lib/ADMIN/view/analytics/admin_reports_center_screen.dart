import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/admin_analytics_controller.dart';

class AdminReportsCenterScreen extends StatefulWidget {
  const AdminReportsCenterScreen({super.key});

  @override
  State<AdminReportsCenterScreen> createState() =>
      _AdminReportsCenterScreenState();
}

class _AdminReportsCenterScreenState extends State<AdminReportsCenterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<AdminAnalyticsController>();
      controller.loadReportTemplates();
      controller.loadGeneratedReports();
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
            Text(
              'Reports Center',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildTemplates(),
            const SizedBox(height: 24),
            _buildGeneratedReports(),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplates() {
    return Consumer<AdminAnalyticsController>(
      builder: (context, controller, _) {
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
                'Report Templates',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Divider(height: 32, color: Color(0xFF21262d)),
              ...controller.reportTemplates.map((template) {
                return ListTile(
                  leading: const Icon(
                    Icons.description,
                    color: Color(0xFF3b82f6),
                  ),
                  title: Text(
                    template.name,
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  subtitle: Text(
                    template.description,
                    style: GoogleFonts.poppins(color: Colors.white60),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () =>
                        controller.generateReport(template.id, 'Admin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3b82f6),
                    ),
                    child: const Text('Generate'),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGeneratedReports() {
    return Consumer<AdminAnalyticsController>(
      builder: (context, controller, _) {
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
                'Generated Reports',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Divider(height: 32, color: Color(0xFF21262d)),
              ...controller.generatedReports.map((report) {
                return ListTile(
                  leading: const Icon(
                    Icons.file_present,
                    color: Color(0xFF10b981),
                  ),
                  title: Text(
                    'Report ${report.id}',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Generated: ${report.generatedAt.day}/${report.generatedAt.month}/${report.generatedAt.year}',
                    style: GoogleFonts.poppins(color: Colors.white60),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    color: const Color(0xFF3b82f6),
                    onPressed: () {},
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
