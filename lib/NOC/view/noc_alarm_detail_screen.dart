import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NOCAlarmDetailScreen extends StatelessWidget {
  const NOCAlarmDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      appBar: AppBar(
        title: Text(
          'Alarm Details',
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
          'Alarm Detail Screen - Coming Soon',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }
}
