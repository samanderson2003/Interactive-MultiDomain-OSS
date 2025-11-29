import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controller/admin_network_controller.dart';

class AdminDomainOverviewScreen extends StatefulWidget {
  const AdminDomainOverviewScreen({super.key});

  @override
  State<AdminDomainOverviewScreen> createState() =>
      _AdminDomainOverviewScreenState();
}

class _AdminDomainOverviewScreenState extends State<AdminDomainOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<AdminNetworkController>();
      controller.loadNetworkElements();
      controller.loadAlarms();
      controller.loadDomainSummary();
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
            _buildDomainCards(),
            const SizedBox(height: 24),
            _buildSummaryStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Domain Overview',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Network domains summary and statistics',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _buildDomainCards() {
    return Consumer<AdminNetworkController>(
      builder: (context, controller, _) {
        if (controller.isLoading || controller.domainSummary == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary = controller.domainSummary!;

        return Row(
          children: [
            Expanded(
              child: _buildDomainCard(
                'RAN Domain',
                Icons.cell_tower,
                const Color(0xFF3b82f6),
                summary.ranElements,
                summary.criticalAlarms,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDomainCard(
                'CORE Domain',
                Icons.hub,
                const Color(0xFF10b981),
                summary.coreElements,
                summary.majorAlarms,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDomainCard(
                'IP Transport',
                Icons.router,
                const Color(0xFFf59e0b),
                summary.ipElements,
                summary.minorAlarms,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDomainCard(
    String title,
    IconData icon,
    Color color,
    int elements,
    int alarms,
  ) {
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Icon(Icons.more_vert, color: Colors.white60),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$elements',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Elements',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$alarms',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFef4444),
                    ),
                  ),
                  Text(
                    'Alarms',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    return Consumer<AdminNetworkController>(
      builder: (context, controller, _) {
        if (controller.domainSummary == null) {
          return const SizedBox();
        }

        final summary = controller.domainSummary!;

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
                'Overall Statistics',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Divider(height: 32, color: Color(0xFF21262d)),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Total Elements',
                      '${summary.totalElements}',
                      Icons.devices,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Active',
                      '${summary.activeElements}',
                      Icons.check_circle,
                      const Color(0xFF10b981),
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Inactive',
                      '${summary.inactiveElements}',
                      Icons.cancel,
                      const Color(0xFFef4444),
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Total Alarms',
                      '${summary.totalAlarms}',
                      Icons.warning,
                      const Color(0xFFf59e0b),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, [
    Color? color,
  ]) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.white60, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white60),
            ),
          ],
        ),
      ],
    );
  }
}
