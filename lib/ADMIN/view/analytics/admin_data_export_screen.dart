import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/admin_analytics_controller.dart';

class AdminDataExportScreen extends StatefulWidget {
  const AdminDataExportScreen({super.key});

  @override
  State<AdminDataExportScreen> createState() => _AdminDataExportScreenState();
}

class _AdminDataExportScreenState extends State<AdminDataExportScreen> {
  String _selectedFormat = 'CSV';
  final List<String> _selectedDataTypes = [];

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
              'Data Export',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Container(
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
                    'Export Format',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    children: ['CSV', 'JSON', 'Excel'].map((format) {
                      return ChoiceChip(
                        label: Text(format),
                        selected: _selectedFormat == format,
                        onSelected: (selected) {
                          if (selected)
                            setState(() => _selectedFormat = format);
                        },
                      );
                    }).toList(),
                  ),
                  const Divider(height: 32, color: Color(0xFF21262d)),
                  Text(
                    'Data Types',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...[
                    'performance',
                    'userActivity',
                    'networkPerformance',
                    'systemResources',
                  ].map((type) {
                    return CheckboxListTile(
                      title: Text(
                        type.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim(),
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      value: _selectedDataTypes.contains(type),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedDataTypes.add(type);
                          } else {
                            _selectedDataTypes.remove(type);
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _selectedDataTypes.isEmpty
                        ? null
                        : () => _exportData(),
                    icon: const Icon(Icons.download),
                    label: const Text('Export Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3b82f6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    final controller = context.read<AdminAnalyticsController>();
    final result = await controller.exportData(
      _selectedFormat,
      _selectedDataTypes,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success']
                ? 'Data exported successfully'
                : 'Export failed: ${result['error']}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: result['success']
              ? const Color(0xFF10b981)
              : const Color(0xFFef4444),
        ),
      );
    }
  }
}
