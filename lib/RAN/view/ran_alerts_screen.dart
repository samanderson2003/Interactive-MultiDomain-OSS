import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../controller/ran_controller.dart';
import '../model/alert_model.dart';

class RANAlertsScreen extends StatefulWidget {
  const RANAlertsScreen({super.key});

  @override
  State<RANAlertsScreen> createState() => _RANAlertsScreenState();
}

class _RANAlertsScreenState extends State<RANAlertsScreen> {
  String _searchQuery = '';
  AlertSeverity? _selectedSeverity;
  String? _selectedLocation;
  String? _selectedBTS;
  String _sortBy = 'time';
  bool _sortAscending = false;
  final Set<int> _selectedAlerts = {};
  bool _selectAll = false;

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AlertModel> _getAllAlerts(RANController controller) {
    final allAlerts = <AlertModel>[];

    for (var bts in controller.btsList) {
      for (var alertMsg in bts.alerts) {
        allAlerts.add(
          AlertModel(
            id: '${bts.id}-${allAlerts.length}',
            btsId: bts.id,
            btsName: bts.name,
            severity: alertMsg.contains('Critical') || alertMsg.contains('High')
                ? AlertSeverity.critical
                : alertMsg.contains('Warning')
                ? AlertSeverity.warning
                : AlertSeverity.info,
            title: _extractTitle(alertMsg),
            description: alertMsg,
            timestamp: DateTime.now().subtract(
              Duration(minutes: allAlerts.length * 15),
            ),
            status: AlertStatus.active,
            location: '${bts.city}, ${bts.location}',
            alertType: _extractAlertType(alertMsg),
          ),
        );
      }
    }

    return allAlerts;
  }

  String _extractTitle(String message) {
    if (message.contains('capacity')) return 'High Capacity Utilization';
    if (message.contains('RSRP')) return 'Signal Strength Issue';
    if (message.contains('RSRQ')) return 'Signal Quality Issue';
    if (message.contains('SINR')) return 'Interference Detected';
    if (message.contains('Users')) return 'User Limit Warning';
    return 'Network Alert';
  }

  String _extractAlertType(String message) {
    if (message.contains('capacity')) return 'CAPACITY';
    if (message.contains('RSRP')) return 'SIGNAL_STRENGTH';
    if (message.contains('RSRQ')) return 'SIGNAL_QUALITY';
    if (message.contains('SINR')) return 'INTERFERENCE';
    if (message.contains('Users')) return 'USER_LIMIT';
    return 'GENERAL';
  }

  List<AlertModel> _getFilteredAndSortedAlerts(List<AlertModel> alerts) {
    var filtered = alerts;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((alert) {
        return alert.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            alert.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            alert.btsName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            alert.btsId.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply severity filter
    if (_selectedSeverity != null) {
      filtered = filtered
          .where((alert) => alert.severity == _selectedSeverity)
          .toList();
    }

    // Apply location filter
    if (_selectedLocation != null) {
      filtered = filtered
          .where((alert) => alert.location.contains(_selectedLocation!))
          .toList();
    }

    // Apply BTS filter
    if (_selectedBTS != null) {
      filtered = filtered
          .where((alert) => alert.btsId == _selectedBTS)
          .toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'time':
          comparison = a.timestamp.compareTo(b.timestamp);
          break;
        case 'severity':
          comparison = a.severity.index.compareTo(b.severity.index);
          break;
        case 'bts':
          comparison = a.btsName.compareTo(b.btsName);
          break;
        case 'location':
          comparison = a.location.compareTo(b.location);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      body: Consumer<RANController>(
        builder: (context, ranController, child) {
          final allAlerts = _getAllAlerts(ranController);
          final filteredAlerts = _getFilteredAndSortedAlerts(allAlerts);

          return Column(
            children: [
              _buildAppBar(context, allAlerts),
              _buildSearchAndFilters(ranController, allAlerts),
              _buildToolbar(filteredAlerts.length, allAlerts),
              Expanded(
                child: filteredAlerts.isEmpty
                    ? _buildEmptyState()
                    : _buildAlertsList(filteredAlerts),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, List<AlertModel> alerts) {
    final critical = alerts
        .where((a) => a.severity == AlertSeverity.critical)
        .length;
    final warning = alerts
        .where((a) => a.severity == AlertSeverity.warning)
        .length;
    final info = alerts.where((a) => a.severity == AlertSeverity.info).length;

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
              color: const Color(0xFFef4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.notifications_active,
              color: Color(0xFFef4444),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'RAN Alerts',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          if (critical > 0)
            _buildStatChip(
              'Critical',
              critical.toString(),
              const Color(0xFFef4444),
            ),
          if (critical > 0) const SizedBox(width: 12),
          if (warning > 0)
            _buildStatChip(
              'Warning',
              warning.toString(),
              const Color(0xFFf59e0b),
            ),
          if (warning > 0) const SizedBox(width: 12),
          if (info > 0)
            _buildStatChip('Info', info.toString(), const Color(0xFF3b82f6)),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () {
              setState(() {
                _selectedAlerts.clear();
                _selectAll = false;
              });
            },
            tooltip: 'Refresh',
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

  Widget _buildSearchAndFilters(
    RANController controller,
    List<AlertModel> alerts,
  ) {
    final locations = [
      'All Locations',
      ...alerts.map((a) => a.location).toSet(),
    ];
    final btsList = ['All BTS', ...alerts.map((a) => a.btsName).toSet()];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF131823),
        border: Border(bottom: BorderSide(color: Color(0xFF1e293b))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1e293b)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search alerts...',
                      hintStyle: GoogleFonts.inter(color: Colors.white38),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white38,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white38,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildDropdownFilter(
                'Location',
                _selectedLocation ?? 'All Locations',
                locations,
                (value) {
                  setState(() {
                    _selectedLocation = value == 'All Locations' ? null : value;
                  });
                },
              ),
              const SizedBox(width: 12),
              _buildDropdownFilter('BTS', _selectedBTS ?? 'All BTS', btsList, (
                value,
              ) {
                setState(() {
                  _selectedBTS = value == 'All BTS' ? null : value;
                });
              }),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                'Severity:',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(width: 12),
              _buildSeverityFilter(AlertSeverity.critical),
              const SizedBox(width: 8),
              _buildSeverityFilter(AlertSeverity.warning),
              const SizedBox(width: 8),
              _buildSeverityFilter(AlertSeverity.info),
              const Spacer(),
              if (_searchQuery.isNotEmpty ||
                  _selectedSeverity != null ||
                  _selectedLocation != null ||
                  _selectedBTS != null)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _selectedSeverity = null;
                      _selectedLocation = null;
                      _selectedBTS = null;
                    });
                  },
                  icon: const Icon(Icons.clear_all, size: 16),
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
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label,
    String value,
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

  Widget _buildSeverityFilter(AlertSeverity severity) {
    final isSelected = _selectedSeverity == severity;
    final severityData = _getSeverityData(severity);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSeverity = isSelected ? null : severity;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? severityData['color'].withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? severityData['color'] : const Color(0xFF1e293b),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(severityData['icon'], color: severityData['color'], size: 14),
            const SizedBox(width: 6),
            Text(
              severityData['label'],
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? severityData['color'] : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getSeverityData(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return {
          'label': 'Critical',
          'color': const Color(0xFFef4444),
          'icon': Icons.error,
        };
      case AlertSeverity.major:
        return {
          'label': 'Major',
          'color': const Color(0xFFf97316),
          'icon': Icons.warning_amber,
        };
      case AlertSeverity.minor:
        return {
          'label': 'Minor',
          'color': const Color(0xFFfbbf24),
          'icon': Icons.info_outline,
        };
      case AlertSeverity.warning:
        return {
          'label': 'Warning',
          'color': const Color(0xFFf59e0b),
          'icon': Icons.warning_amber_rounded,
        };
      case AlertSeverity.info:
        return {
          'label': 'Info',
          'color': const Color(0xFF3b82f6),
          'icon': Icons.info,
        };
    }
  }

  Widget _buildToolbar(int filteredCount, List<AlertModel> allAlerts) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF131823),
        border: Border(bottom: BorderSide(color: Color(0xFF1e293b))),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _selectAll,
            onChanged: (value) {
              setState(() {
                _selectAll = value ?? false;
                if (_selectAll) {
                  _selectedAlerts.addAll(
                    List.generate(filteredCount, (i) => i),
                  );
                } else {
                  _selectedAlerts.clear();
                }
              });
            },
            activeColor: const Color(0xFF0ea5e9),
          ),
          const SizedBox(width: 8),
          Text(
            _selectedAlerts.isEmpty
                ? '$filteredCount Alerts'
                : '${_selectedAlerts.length} Selected',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (_selectedAlerts.isNotEmpty) ...[
            const SizedBox(width: 24),
            _buildBulkActionButton(
              Icons.check,
              'Acknowledge',
              const Color(0xFF10b981),
            ),
            const SizedBox(width: 12),
            _buildBulkActionButton(
              Icons.build,
              'Resolve',
              const Color(0xFF0ea5e9),
            ),
            const SizedBox(width: 12),
            _buildBulkActionButton(
              Icons.delete_outline,
              'Delete',
              const Color(0xFFef4444),
            ),
          ],
          const Spacer(),
          Text(
            'Sort by:',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(width: 12),
          _buildSortButton('Time', 'time'),
          const SizedBox(width: 8),
          _buildSortButton('Severity', 'severity'),
          const SizedBox(width: 8),
          _buildSortButton('BTS', 'bts'),
          const SizedBox(width: 8),
          _buildSortButton('Location', 'location'),
        ],
      ),
    );
  }

  Widget _buildBulkActionButton(IconData icon, String label, Color color) {
    return ElevatedButton.icon(
      onPressed: () {
        _handleBulkAction(label);
      },
      icon: Icon(icon, size: 16),
      label: Text(label, style: GoogleFonts.inter(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: color),
      ),
    );
  }

  void _handleBulkAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              '$action applied to ${_selectedAlerts.length} alert(s)',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10b981),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {
      _selectedAlerts.clear();
      _selectAll = false;
    });
  }

  Widget _buildSortButton(String label, String sortKey) {
    final isActive = _sortBy == sortKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_sortBy == sortKey) {
            _sortAscending = !_sortAscending;
          } else {
            _sortBy = sortKey;
            _sortAscending = false;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF0ea5e9).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? const Color(0xFF0ea5e9) : const Color(0xFF1e293b),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? const Color(0xFF0ea5e9) : Colors.white70,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: const Color(0xFF0ea5e9),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No alerts found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList(List<AlertModel> alerts) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        return FadeInUp(
          duration: Duration(milliseconds: 300 + (index * 50)),
          child: _buildAlertCard(alerts[index], index),
        );
      },
    );
  }

  Widget _buildAlertCard(AlertModel alert, int index) {
    final severityData = _getSeverityData(alert.severity);
    final isSelected = _selectedAlerts.contains(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF131823),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF0ea5e9)
              : severityData['color'].withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedAlerts.remove(index);
              } else {
                _selectedAlerts.add(index);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value ?? false) {
                            _selectedAlerts.add(index);
                          } else {
                            _selectedAlerts.remove(index);
                          }
                        });
                      },
                      activeColor: const Color(0xFF0ea5e9),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: severityData['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        severityData['icon'],
                        color: severityData['color'],
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: severityData['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  severityData['label'],
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: severityData['color'],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  alert.alertType,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.white60,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatTimestamp(alert.timestamp),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            alert.title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alert.description,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cell_tower, color: Colors.white60, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        alert.btsName,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.location_on, color: Colors.white60, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        alert.location,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      const Spacer(),
                      Consumer<RANController>(
                        builder: (context, ranController, child) {
                          final bts = ranController.btsList.firstWhere(
                            (b) => b.id == alert.btsId,
                            orElse: () => ranController.btsList.first,
                          );
                          return _buildActionButton(
                            Icons.visibility,
                            'View BTS',
                            const Color(0xFF0ea5e9),
                            () {
                              Navigator.pushNamed(
                                context,
                                '/ran-bts-detail',
                                arguments: bts,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _acknowledgeAlert(alert);
                        },
                        icon: const Icon(Icons.check, size: 16),
                        label: Text(
                          'Acknowledge',
                          style: GoogleFonts.inter(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF10b981),
                          side: const BorderSide(color: Color(0xFF10b981)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _resolveAlert(alert);
                        },
                        icon: const Icon(Icons.build, size: 16),
                        label: Text(
                          'Resolve',
                          style: GoogleFonts.inter(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0ea5e9),
                          side: const BorderSide(color: Color(0xFF0ea5e9)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {
                        _showAlertDetails(alert);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Color(0xFF1e293b)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      child: const Icon(Icons.more_horiz, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: GoogleFonts.inter(fontSize: 12)),
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _acknowledgeAlert(AlertModel alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Alert acknowledged',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10b981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resolveAlert(AlertModel alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Alert resolved',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0ea5e9),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAlertDetails(AlertModel alert) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF131823),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getSeverityData(
                        alert.severity,
                      )['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getSeverityData(alert.severity)['icon'],
                      color: _getSeverityData(alert.severity)['color'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Alert Details',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Alert ID', alert.id),
              const SizedBox(height: 12),
              _buildDetailRow('Title', alert.title),
              const SizedBox(height: 12),
              _buildDetailRow('Description', alert.description),
              const SizedBox(height: 12),
              _buildDetailRow('BTS Name', alert.btsName),
              const SizedBox(height: 12),
              _buildDetailRow('Location', alert.location),
              const SizedBox(height: 12),
              _buildDetailRow('Type', alert.alertType),
              const SizedBox(height: 12),
              _buildDetailRow('Timestamp', alert.timestamp.toString()),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0ea5e9),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
