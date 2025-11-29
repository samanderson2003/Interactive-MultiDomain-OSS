import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controller/ip_controller.dart';
import '../model/network_link_model.dart';
import '../model/link_status_model.dart';

class IPLinksScreen extends StatefulWidget {
  const IPLinksScreen({super.key});

  @override
  State<IPLinksScreen> createState() => _IPLinksScreenState();
}

class _IPLinksScreenState extends State<IPLinksScreen> {
  String _filterStatus = 'All';
  String _sortBy = 'Utilization';
  bool _sortAscending = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131823),
        title: Text(
          'Network Links',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<IPController>().refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<IPController>(
        builder: (context, controller, _) {
          final filteredLinks = _getFilteredAndSortedLinks(controller.links);

          return Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child: filteredLinks.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredLinks.length,
                        itemBuilder: (context, index) {
                          return _buildLinkCard(filteredLinks[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF131823),
        border: Border(bottom: BorderSide(color: Color(0xFF1f2937))),
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search links...',
              hintStyle: GoogleFonts.poppins(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF0a0e1a),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Status filter
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0a0e1a),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: _filterStatus,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF131823),
                    underline: const SizedBox(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    items: ['All', 'Operational', 'Degraded', 'Failed']
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _filterStatus = value!),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Sort by
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0a0e1a),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF131823),
                    underline: const SizedBox(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    items: ['Utilization', 'Capacity', 'Latency', 'Packet Loss']
                        .map(
                          (sort) =>
                              DropdownMenuItem(value: sort, child: Text(sort)),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _sortBy = value!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: const Color(0xFFf59e0b),
                ),
                onPressed: () =>
                    setState(() => _sortAscending = !_sortAscending),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(NetworkLinkModel link) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: link.utilizationColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${link.fromNodeName} → ${link.toNodeName}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      link.id,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(link.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  link.status.toString().split('.').last.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(link.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Capacity',
                  '${link.capacityGbps} Gbps',
                  Icons.speed,
                  const Color(0xFF0ea5e9),
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Utilization',
                  '${link.utilizationPercent.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  link.utilizationColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Latency',
                  '${link.latencyMs.toStringAsFixed(1)} ms',
                  Icons.access_time,
                  link.latencyMs > 50 ? Colors.orange : Colors.green,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Packet Loss',
                  '${link.packetLossPercent.toStringAsFixed(2)}%',
                  Icons.error_outline,
                  link.packetLossPercent > 1 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          if (link.hasAlert)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Alert: High utilization threshold exceeded',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.link_off, size: 64, color: Colors.white38),
          const SizedBox(height: 16),
          Text(
            'No links found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(LinkStatus status) {
    switch (status) {
      case LinkStatus.operational:
        return Colors.green;
      case LinkStatus.degraded:
        return Colors.orange;
      case LinkStatus.failed:
        return Colors.red;
    }
  }

  List<NetworkLinkModel> _getFilteredAndSortedLinks(
    List<NetworkLinkModel> links,
  ) {
    var filtered = links.where((link) {
      // Filter by status
      if (_filterStatus != 'All') {
        final statusMatch =
            link.status.toString().split('.').last.toLowerCase() ==
            _filterStatus.toLowerCase();
        if (!statusMatch) return false;
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return link.id.toLowerCase().contains(query) ||
            link.fromNodeName.toLowerCase().contains(query) ||
            link.toNodeName.toLowerCase().contains(query);
      }

      return true;
    }).toList();

    // Sort
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'Utilization':
          comparison = a.utilizationPercent.compareTo(b.utilizationPercent);
          break;
        case 'Capacity':
          comparison = a.capacityGbps.compareTo(b.capacityGbps);
          break;
        case 'Latency':
          comparison = a.latencyMs.compareTo(b.latencyMs);
          break;
        case 'Packet Loss':
          comparison = a.packetLossPercent.compareTo(b.packetLossPercent);
          break;
        default:
          comparison = 0;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }
}
