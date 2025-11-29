import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminNotificationsScreen extends StatelessWidget {
  const AdminNotificationsScreen({super.key});

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
              'Notification Settings',
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
                children: [
                  SwitchListTile(
                    title: Text(
                      'Email Notifications',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    value: true,
                    onChanged: (v) {},
                  ),
                  SwitchListTile(
                    title: Text(
                      'Alarm Notifications',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    value: true,
                    onChanged: (v) {},
                  ),
                  SwitchListTile(
                    title: Text(
                      'System Alerts',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    value: false,
                    onChanged: (v) {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
