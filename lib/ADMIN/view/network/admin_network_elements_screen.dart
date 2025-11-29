import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/admin_network_controller.dart';

class AdminNetworkElementsScreen extends StatefulWidget {
  const AdminNetworkElementsScreen({super.key});

  @override
  State<AdminNetworkElementsScreen> createState() => _AdminNetworkElementsScreenState();
}

class _AdminNetworkElementsScreenState extends State<AdminNetworkElementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminNetworkController>().loadNetworkElements();
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
            _buildHeader(),
            const SizedBox(height: 24),
            _buildFilters(),
            const SizedBox(height: 24),
            _buildElementsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AdminNetworkController>(
      builder: (context, controller, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Network Elements',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.networkElements.length} elements',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => controller.loadNetworkElements(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3b82f6),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1117),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF21262d)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                context.read<AdminNetworkController>().setSearchQuery(value);
              },
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search elements...',
                hintStyle: GoogleFonts.poppins(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                filled: true,
                fillColor: const Color(0xFF161b22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementsTable() {
    return Consumer<AdminNetworkController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (controller.networkElements.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.router, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    'No network elements found',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white60),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0d1117),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF21262d)),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1.5),
              5: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF21262d))),
                ),
                children: [
                  _buildHeaderCell('Name'),
                  _buildHeaderCell('IP Address'),
                  _buildHeaderCell('Domain'),
                  _buildHeaderCell('Type'),
                  _buildHeaderCell('Location'),
                  _buildHeaderCell('Status'),
                ],
              ),
              ...controller.networkElements.map((element) {
                return TableRow(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF21262d))),
                  ),
                  children: [
                    _buildCell(Text(element.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white))),
                    _buildCell(Text(element.ipAddress, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white))),
                    _buildCell(Text(element.domain, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white))),
                    _buildCell(Text(element.type, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70))),
                    _buildCell(Text(element.location, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70))),
                    _buildCell(_buildStatusBadge(element.status)),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildCell(Widget child) {
    return Padding(padding: const EdgeInsets.all(16), child: child);
  }

  Widget _buildStatusBadge(String status) {
    final color = status == 'Active' ? const Color(0xFF10b981) : const Color(0xFFef4444);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
