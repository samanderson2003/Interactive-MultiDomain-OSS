import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSupportTicketsScreen extends StatelessWidget {
  const AdminSupportTicketsScreen({super.key});

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
              'Support Tickets',
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
                    const Icon(
                      Icons.support_agent,
                      size: 64,
                      color: Colors.white24,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Manage support tickets and requests',
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
