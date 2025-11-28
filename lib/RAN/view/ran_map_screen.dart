import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controller/ran_controller.dart';
import '../model/bts_model.dart';

class RANMapScreen extends StatefulWidget {
  const RANMapScreen({super.key});

  @override
  State<RANMapScreen> createState() => _RANMapScreenState();
}

class _RANMapScreenState extends State<RANMapScreen>
    with TickerProviderStateMixin {
  String? _selectedCity;
  String? _selectedRegion;
  BTSStatus? _selectedStatus;
  BTSModel? _hoveredBTS;
  BTSModel? _selectedBTS;

  late AnimationController _pulseController;
  late AnimationController _rippleController;

  final List<String> _cities = [
    'All Cities',
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
  ];

  final List<String> _regions = [
    'All Regions',
    'North',
    'South',
    'East',
    'West',
    'Central',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  List<BTSModel> _getFilteredBTS(RANController controller) {
    var filtered = controller.btsList;

    if (_selectedCity != null && _selectedCity != 'All Cities') {
      filtered = filtered.where((bts) => bts.city == _selectedCity).toList();
    }

    if (_selectedRegion != null && _selectedRegion != 'All Regions') {
      filtered = filtered
          .where((bts) => bts.region == _selectedRegion)
          .toList();
    }

    if (_selectedStatus != null) {
      filtered = filtered
          .where((bts) => bts.status == _selectedStatus)
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: Consumer<RANController>(
        builder: (context, ranController, child) {
          final filteredBTS = _getFilteredBTS(ranController);

          return Column(
            children: [
              _buildAppBar(context, ranController),
              _buildFilterBar(ranController),
              Expanded(
                child: Row(
                  children: [
                    Expanded(flex: 7, child: _buildMapView(filteredBTS)),
                    Container(
                      width: 380,
                      decoration: const BoxDecoration(
                        color: Color(0xFF131823),
                        border: Border(
                          left: BorderSide(color: Color(0xFF1e293b)),
                        ),
                      ),
                      child: _selectedBTS != null
                          ? _buildBTSDetails(_selectedBTS!)
                          : _buildBTSList(filteredBTS),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, RANController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF131823),
        border: Border(bottom: BorderSide(color: Color(0xFF1e293b))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0ea5e9).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.map_outlined,
              color: Color(0xFF0ea5e9),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Interactive BTS Map',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          _buildStatChip(
            'Total',
            controller.totalBTS.toString(),
            const Color(0xFF0ea5e9),
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            'Active',
            controller.activeBTS.toString(),
            const Color(0xFF10b981),
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            'Inactive',
            controller.inactiveBTS.toString(),
            const Color(0xFFef4444),
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            'Degraded',
            controller.degradedBTS.toString(),
            const Color(0xFFf59e0b),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(RANController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF131823),
        border: Border(bottom: BorderSide(color: Color(0xFF1e293b))),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Text(
            'Filters:',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 16),
          _buildDropdownFilter(
            'City',
            _selectedCity,
            _cities,
            (value) => setState(() => _selectedCity = value),
          ),
          const SizedBox(width: 12),
          _buildDropdownFilter(
            'Region',
            _selectedRegion,
            _regions,
            (value) => setState(() => _selectedRegion = value),
          ),
          const SizedBox(width: 12),
          _buildStatusFilter(),
          const Spacer(),
          if (_selectedCity != null ||
              _selectedRegion != null ||
              _selectedStatus != null)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedCity = null;
                  _selectedRegion = null;
                  _selectedStatus = null;
                });
              },
              icon: const Icon(Icons.clear, size: 16),
              label: Text(
                'Clear Filters',
                style: GoogleFonts.inter(fontSize: 13),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0ea5e9),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1e293b)),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white60),
        ),
        dropdownColor: const Color(0xFF0F172A),
        underline: const SizedBox(),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.white60,
          size: 20,
        ),
        style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
        items: items.map((String item) {
          return DropdownMenuItem<String>(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Row(
      children: [
        _buildStatusChip(BTSStatus.active),
        const SizedBox(width: 8),
        _buildStatusChip(BTSStatus.degraded),
        const SizedBox(width: 8),
        _buildStatusChip(BTSStatus.inactive),
      ],
    );
  }

  Widget _buildStatusChip(BTSStatus status) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = isSelected ? null : status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? status.color.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? status.color : const Color(0xFF1e293b),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: status.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              status.displayName,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? status.color : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView(List<BTSModel> btsList) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(20.5937, 78.9629), // Center of India
            initialZoom: 5.0,
            minZoom: 4.0,
            maxZoom: 18.0,
            backgroundColor: const Color(0xFF0a0e1a),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.interactive.app',
              tileBuilder: (context, tileWidget, tile) {
                return ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.7),
                    BlendMode.darken,
                  ),
                  child: tileWidget,
                );
              },
            ),
            MarkerLayer(
              markers: btsList.map((bts) {
                final isHovered = _hoveredBTS?.id == bts.id;
                final isSelected = _selectedBTS?.id == bts.id;

                return Marker(
                  point: LatLng(bts.latitude, bts.longitude),
                  width: isHovered || isSelected ? 80 : 60,
                  height: isHovered || isSelected ? 80 : 60,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedBTS = bts),
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hoveredBTS = bts),
                      onExit: (_) => setState(() => _hoveredBTS = null),
                      child: AnimatedBuilder(
                        animation: bts.status == BTSStatus.inactive
                            ? _rippleController
                            : _pulseController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Ripple effect for inactive BTS
                              if (bts.status == BTSStatus.inactive)
                                Container(
                                  width: 40 + _rippleController.value * 30,
                                  height: 40 + _rippleController.value * 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: bts.status.color.withOpacity(
                                        0.5 - _rippleController.value * 0.5,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              // Pulse glow for active BTS
                              if (bts.status == BTSStatus.active)
                                Container(
                                  width: 24 + _pulseController.value * 8,
                                  height: 24 + _pulseController.value * 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: bts.status.color.withOpacity(
                                          0.4,
                                        ),
                                        blurRadius:
                                            8 + _pulseController.value * 8,
                                        spreadRadius:
                                            _pulseController.value * 4,
                                      ),
                                    ],
                                  ),
                                ),
                              // Main marker
                              Container(
                                width: isHovered || isSelected ? 28 : 20,
                                height: isHovered || isSelected ? 28 : 20,
                                decoration: BoxDecoration(
                                  color: bts.status.color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: isSelected ? 3 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: bts.status.color.withOpacity(0.6),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: isHovered || isSelected
                                    ? const Icon(
                                        Icons.cell_tower,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              // Hover tooltip
                              if (isHovered && !isSelected)
                                Positioned(
                                  bottom: 35,
                                  child: FadeIn(
                                    duration: const Duration(milliseconds: 200),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF131823),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: bts.status.color,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            bts.name,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            bts.location,
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: bts.status.color
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              bts.status.displayName,
                                              style: GoogleFonts.inter(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                color: bts.status.color,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        // Legend
        Positioned(bottom: 24, left: 24, child: _buildLegend()),
      ],
    );
  }

  Widget _buildLegend() {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131823).withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1e293b)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BTS Status',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildLegendItem('Active', BTSStatus.active.color),
            const SizedBox(height: 8),
            _buildLegendItem('Degraded', BTSStatus.degraded.color),
            const SizedBox(height: 8),
            _buildLegendItem('Inactive', BTSStatus.inactive.color),
            const SizedBox(height: 8),
            _buildLegendItem('Maintenance', BTSStatus.maintenance.color),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildBTSList(List<BTSModel> btsList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'BTS Towers',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0ea5e9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${btsList.length}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0ea5e9),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFF1e293b), height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: btsList.length,
            itemBuilder: (context, index) {
              final bts = btsList[index];
              return _buildBTSListItem(bts);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBTSListItem(BTSModel bts) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1e293b))),
      ),
      child: ListTile(
        onTap: () => setState(() => _selectedBTS = bts),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bts.status.color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: bts.status.color, width: 2),
          ),
          child: Icon(Icons.cell_tower, color: bts.status.color, size: 20),
        ),
        title: Text(
          bts.name,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              bts.location,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: bts.status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    bts.status.displayName,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: bts.status.color,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  bts.technology,
                  style: GoogleFonts.inter(fontSize: 9, color: Colors.white38),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white38,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildBTSDetails(BTSModel bts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () => setState(() => _selectedBTS = null),
              ),
              const SizedBox(width: 8),
              Text(
                'Tower Details',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFF1e293b), height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        bts.status.color.withOpacity(0.2),
                        bts.status.color.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: bts.status.color.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.cell_tower, size: 48, color: bts.status.color),
                      const SizedBox(height: 12),
                      Text(
                        bts.name,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bts.id,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: bts.status.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: bts.status.color),
                        ),
                        child: Text(
                          bts.status.displayName,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: bts.status.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailSection('Location', [
                  _buildDetailRow(Icons.location_on, 'Address', bts.location),
                  _buildDetailRow(Icons.location_city, 'City', bts.city),
                  _buildDetailRow(Icons.map, 'Region', bts.region),
                  _buildDetailRow(
                    Icons.public,
                    'Coordinates',
                    '${bts.latitude.toStringAsFixed(4)}, ${bts.longitude.toStringAsFixed(4)}',
                  ),
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('Technical Specs', [
                  _buildDetailRow(
                    Icons.network_cell,
                    'Technology',
                    bts.technology,
                  ),
                  _buildDetailRow(
                    Icons.speed,
                    'Frequency',
                    '${bts.frequency} MHz',
                  ),
                  _buildDetailRow(
                    Icons.settings_input_antenna,
                    'Bandwidth',
                    '${bts.bandwidth} MHz',
                  ),
                  _buildDetailRow(
                    Icons.power,
                    'TX Power',
                    '${bts.txPower.toStringAsFixed(1)} dBm',
                  ),
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('Signal Quality', [
                  _buildSignalRow('RSRP', bts.rsrp, 'dBm', bts.rsrpQuality),
                  _buildSignalRow('RSRQ', bts.rsrq, 'dB', bts.rsrqQuality),
                  _buildSignalRow('SINR', bts.sinr, 'dB', bts.sinrQuality),
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('Capacity', [
                  _buildCapacityBar(bts),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.people,
                    'Active Users',
                    '${bts.activeUsers}',
                  ),
                  _buildDetailRow(
                    Icons.groups,
                    'Max Capacity',
                    '${bts.maxCapacity}',
                  ),
                ]),
                const SizedBox(height: 16),
                if (bts.alerts.isNotEmpty)
                  _buildDetailSection('Active Alerts', [
                    ...bts.alerts.map(
                      (alert) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFef4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFef4444).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFef4444),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  alert,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF1e293b)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white38),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalRow(
    String label,
    double value,
    String unit,
    String quality,
  ) {
    Color qualityColor;
    if (quality == 'Excellent') {
      qualityColor = const Color(0xFF10b981);
    } else if (quality == 'Good') {
      qualityColor = const Color(0xFF3b82f6);
    } else if (quality == 'Fair') {
      qualityColor = const Color(0xFFf59e0b);
    } else {
      qualityColor = const Color(0xFFef4444);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
              ),
              Row(
                children: [
                  Text(
                    '${value.toStringAsFixed(1)} $unit',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: qualityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      quality,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: qualityColor,
                      ),
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

  Widget _buildCapacityBar(BTSModel bts) {
    final percentage = bts.capacityUtilization;
    Color barColor;
    if (percentage > 85) {
      barColor = const Color(0xFFef4444);
    } else if (percentage > 70) {
      barColor = const Color(0xFFf59e0b);
    } else {
      barColor = const Color(0xFF10b981);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Utilization',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: const Color(0xFF1e293b),
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
      ],
    );
  }
}
