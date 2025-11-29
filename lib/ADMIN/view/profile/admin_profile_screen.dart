import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../../utils/constants.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: Consumer<AuthController>(
        builder: (context, authController, _) {
          final user = authController.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
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
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFef4444),
                        child: Text(
                          user?.name.substring(0, 1).toUpperCase() ?? 'A',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        user?.name ?? 'Admin User',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Colors.white60,
                        ),
                        title: Text(
                          'Full Name',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        subtitle: Text(
                          user?.name ?? 'N/A',
                          style: GoogleFonts.poppins(color: Colors.white70),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.email, color: Colors.white60),
                        title: Text(
                          'Email',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        subtitle: Text(
                          user?.email ?? 'N/A',
                          style: GoogleFonts.poppins(color: Colors.white70),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.badge, color: Colors.white60),
                        title: Text(
                          'Role',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                        subtitle: Text(
                          UserRole.ADMIN.displayName,
                          style: GoogleFonts.poppins(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
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
          );
        },
      ),
    );
  }
}
