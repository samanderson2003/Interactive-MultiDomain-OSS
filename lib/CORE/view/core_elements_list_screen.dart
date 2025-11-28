import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controller/core_controller.dart';
import '../model/core_element_model.dart';

class CoreElementsListScreen extends StatefulWidget {
  const CoreElementsListScreen({super.key});

  @override
  State<CoreElementsListScreen> createState() => _CoreElementsListScreenState();
}

class _CoreElementsListScreenState extends State<CoreElementsListScreen> {
  String _searchQuery = '';
  CoreElementType? _filterType;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<CoreController>();
      if (controller.coreElements.isEmpty) {
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
          'CORE Elements',
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
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildElementsList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF131823),
      child: Column(
        children: [
          TextField(
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search elements...',
              hintStyle: GoogleFonts.poppins(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF0ea5e9)),
              filled: true,
              fillColor: const Color(0xFF0a0e1a),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown<CoreElementType?>(
                  value: _filterType,
                  hint: 'All Types',
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...CoreElementType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.toString().split('.').last.toUpperCase(),
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterType = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown<String?>(
                  value: _filterStatus,
                  hint: 'All Status',
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Status')),
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(value: 'Standby', child: Text('Standby')),
                    DropdownMenuItem(
                      value: 'Maintenance',
                      child: Text('Maintenance'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0a0e1a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF131823),
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0ea5e9)),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildElementsList() {
    return Consumer<CoreController>(
      builder: (context, controller, _) {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0ea5e9)),
          );
        }

        var elements = controller.coreElements;

        // Apply filters
        if (_searchQuery.isNotEmpty) {
          elements = elements.where((e) {
            return e.name.toLowerCase().contains(_searchQuery) ||
                e.location.toLowerCase().contains(_searchQuery) ||
                e.ipAddress.contains(_searchQuery);
          }).toList();
        }

        if (_filterType != null) {
          elements = elements.where((e) => e.type == _filterType).toList();
        }

        if (_filterStatus != null) {
          elements = elements.where((e) => e.status == _filterStatus).toList();
        }

        if (elements.isEmpty) {
          return Center(
            child: Text(
              'No elements found',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: elements.length,
          itemBuilder: (context, index) {
            return _buildElementCard(elements[index]);
          },
        );
      },
    );
  }

  Widget _buildElementCard(CoreElementModel element) {
    final statusColor = element.status == 'Active'
        ? Colors.green
        : element.status == 'Standby'
        ? Colors.orange
        : Colors.grey;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/core-element-detail',
          arguments: element,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131823),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF0ea5e9).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0ea5e9).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForType(element.type),
                    color: const Color(0xFF0ea5e9),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        element.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${element.typeString} • ${element.location}',
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
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    element.status,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    'CPU',
                    '${element.cpu.toStringAsFixed(1)}%',
                    element.cpu < 80,
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    'Memory',
                    '${element.memory.toStringAsFixed(1)}%',
                    element.memory < 85,
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    'Capacity',
                    '${element.capacityUsage.toStringAsFixed(1)}%',
                    element.capacityUsage < 90,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, bool isHealthy) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isHealthy ? Colors.green : Colors.red,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  IconData _getIconForType(CoreElementType type) {
    switch (type) {
      case CoreElementType.hlr:
        return Icons.storage;
      case CoreElementType.epc:
        return Icons.hub;
      case CoreElementType.mme:
        return Icons.router;
      case CoreElementType.sgw:
        return Icons.network_cell;
      case CoreElementType.pgw:
        return Icons.cloud;
      case CoreElementType.hss:
        return Icons.dns;
    }
  }
}
