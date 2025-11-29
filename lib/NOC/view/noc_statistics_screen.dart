import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NOCStatisticsScreen extends StatelessWidget {
  const NOCStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      appBar: AppBar(
        title: Text(
          'Alarm Statistics',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF131823),
      ),
      body: Center(
        child: Text(
          'Statistics Screen - Coming Soon',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }
}
