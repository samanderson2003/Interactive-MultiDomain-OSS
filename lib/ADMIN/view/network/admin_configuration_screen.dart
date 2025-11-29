import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminConfigurationScreen extends StatelessWidget {
  const AdminConfigurationScreen({super.key});

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
              'Network Configuration',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage network settings and configurations',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0d1117),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF21262d)),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.settings, size: 64, color: Colors.white24),
                    const SizedBox(height: 16),
                    Text(
                      'Configuration Management',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure network parameters and settings',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
