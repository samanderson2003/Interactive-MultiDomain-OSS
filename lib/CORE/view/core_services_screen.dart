import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controller/core_controller.dart';
import '../model/service_health_model.dart';

class CoreServicesScreen extends StatefulWidget {
  const CoreServicesScreen({super.key});

  @override
  State<CoreServicesScreen> createState() => _CoreServicesScreenState();
}

class _CoreServicesScreenState extends State<CoreServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<CoreController>();
      if (controller.serviceHealthList.isEmpty) {
        controller.loadDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131823),
        title: Text(
          'Service Health',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<CoreController>().refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<CoreController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0ea5e9)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverallHealth(controller),
                const SizedBox(height: 24),
                _buildServicesList(controller),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallHealth(CoreController controller) {
    final operational = controller.serviceHealthList
        .where((s) => s.status == 'Operational')
        .length;
    final total = controller.serviceHealthList.length;
    final healthPercentage = (operational / total * 100);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0ea5e9).withOpacity(0.2),
            const Color(0xFF131823),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0ea5e9).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Overall System Health',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: healthPercentage / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.white24,
                      color: healthPercentage > 80
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '${healthPercentage.toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$operational of $total services operational',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(CoreController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Status',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...controller.serviceHealthList.map((service) {
          return _buildServiceCard(service);
        }).toList(),
      ],
    );
  }

  Widget _buildServiceCard(ServiceHealthModel service) {
    final isHealthy = service.status == 'Operational';
    final color = isHealthy
        ? Colors.green
        : (service.status == 'Degraded' ? Colors.orange : Colors.red);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  service.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color),
                ),
                child: Text(
                  service.status,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildServiceMetric(
                  'Uptime',
                  '${service.uptime.toStringAsFixed(2)}%',
                ),
              ),
              Expanded(
                child: _buildServiceMetric(
                  'Last Incident',
                  _formatTimeAgo(service.lastIncident),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: service.uptime / 100,
            backgroundColor: Colors.white24,
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
