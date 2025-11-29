import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminAuditComplianceScreen extends StatelessWidget {
  const AdminAuditComplianceScreen({super.key});

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
              'Audit & Compliance',
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
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.security, size: 64, color: Colors.white24),
                    const SizedBox(height: 16),
                    Text(
                      'Audit logs and compliance reports',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
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
