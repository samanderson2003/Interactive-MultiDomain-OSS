import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../controller/noc_controller.dart';
import '../model/alarm_severity.dart';
import '../model/alarm_status.dart';
import '../model/alarm_domain.dart';
import '../model/noc_alarm_model.dart';
import '../../utils/constants.dart';

class NOCAlarmTableScreen extends StatefulWidget {
  const NOCAlarmTableScreen({super.key});

  @override
  State<NOCAlarmTableScreen> createState() => _NOCAlarmTableScreenState();
}

class _NOCAlarmTableScreenState extends State<NOCAlarmTableScreen> {
  final TextEditingController _searchController = TextEditingController();
  AlarmSeverity? _selectedSeverity;
  AlarmStatus? _selectedStatus;
  AlarmDomain? _selectedDomain;
  String _sortColumn = 'timestamp';
  bool _sortAscending = false;
  int _currentPage = 0;
  final int _itemsPerPage = 20;
  final Set<String> _selectedAlarms = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0e1a),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterBar(),
          _buildBulkActionsBar(),
          Expanded(child: _buildAlarmTable()),
          _buildPaginationBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF131823),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'All Alarms',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        Consumer<NOCController>(
          builder: (context, controller, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: DarkThemeColors.chartPink.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_getFilteredAlarms(controller).length} Alarms',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DarkThemeColors.chartPink,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131823),
          border: Border(
            bottom: BorderSide(
              color: DarkThemeColors.chartPink.withOpacity(0.2),
            ),
          ),
        ),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search alarms by element or description...',
                hintStyle: GoogleFonts.poppins(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white38),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1a2030),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            // Filter dropdowns
            Row(
              children: [
                Expanded(child: _buildDomainFilter()),
                const SizedBox(width: 8),
                Expanded(child: _buildSeverityFilter()),
                const SizedBox(width: 8),
                Expanded(child: _buildStatusFilter()),
                const SizedBox(width: 8),
                _buildClearFiltersButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a2030),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AlarmDomain?>(
          value: _selectedDomain,
          isExpanded: true,
          dropdownColor: const Color(0xFF1a2030),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white38),
          hint: Text(
            'Domain',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white38),
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(
                'All Domains',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
              ),
            ),
            ...AlarmDomain.values.map((domain) {
              return DropdownMenuItem(
                value: domain,
                child: Text(
                  domain.displayName,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                ),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              _selectedDomain = value;
              _currentPage = 0;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSeverityFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a2030),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AlarmSeverity?>(
          value: _selectedSeverity,
          isExpanded: true,
          dropdownColor: const Color(0xFF1a2030),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white38),
          hint: Text(
            'Severity',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white38),
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(
                'All Severities',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
              ),
            ),
            ...AlarmSeverity.values.map((severity) {
              return DropdownMenuItem(
                value: severity,
                child: Text(
                  severity.displayName,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                ),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              _selectedSeverity = value;
              _currentPage = 0;
            });
          },
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a2030),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AlarmStatus?>(
          value: _selectedStatus,
          isExpanded: true,
          dropdownColor: const Color(0xFF1a2030),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white38),
          hint: Text(
            'Status',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white38),
          ),
          items: [
            DropdownMenuItem(
              value: null,
              child: Text(
                'All Statuses',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
              ),
            ),
            ...AlarmStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(
                  status.displayName,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                ),
              );
            }).toList(),
          ],
          onChanged: (value) {
            setState(() {
              _selectedStatus = value;
              _currentPage = 0;
            });
          },
        ),
      ),
    );
  }

  Widget _buildClearFiltersButton() {
    return IconButton(
      icon: const Icon(Icons.filter_alt_off, color: DarkThemeColors.chartPink),
      onPressed: () {
        setState(() {
          _selectedDomain = null;
          _selectedSeverity = null;
          _selectedStatus = null;
          _searchController.clear();
          _currentPage = 0;
        });
      },
      tooltip: 'Clear Filters',
    );
  }

  Widget _buildBulkActionsBar() {
    if (_selectedAlarms.isEmpty) return const SizedBox.shrink();

    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: DarkThemeColors.chartPink.withOpacity(0.1),
          border: Border(
            bottom: BorderSide(
              color: DarkThemeColors.chartPink.withOpacity(0.3),
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              '${_selectedAlarms.length} selected',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _bulkAcknowledge(),
              icon: const Icon(Icons.check_circle, size: 16),
              label: Text(
                'Acknowledge',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DarkThemeColors.chartPink,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showBulkAssignDialog(),
              icon: const Icon(Icons.person_add, size: 16),
              label: Text('Assign', style: GoogleFonts.poppins(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3b82f6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white70),
              onPressed: () {
                setState(() {
                  _selectedAlarms.clear();
                });
              },
              tooltip: 'Clear Selection',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmTable() {
    return Consumer<NOCController>(
      builder: (context, controller, _) {
        final filteredAlarms = _getFilteredAlarms(controller);
        final sortedAlarms = _getSortedAlarms(filteredAlarms);
        final paginatedAlarms = _getPaginatedAlarms(sortedAlarms);

        if (paginatedAlarms.isEmpty) {
          return _buildEmptyState();
        }

        return FadeInUp(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFF131823),
                ),
                dataRowColor: WidgetStateProperty.resolveWith(
                  (states) => const Color(0xFF1a2030),
                ),
                dividerThickness: 1,
                columnSpacing: 24,
                columns: [
                  DataColumn(
                    label: Checkbox(
                      value:
                          _selectedAlarms.length == paginatedAlarms.length &&
                          paginatedAlarms.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedAlarms.addAll(
                              paginatedAlarms.map((a) => a.id),
                            );
                          } else {
                            _selectedAlarms.clear();
                          }
                        });
                      },
                      activeColor: DarkThemeColors.chartPink,
                    ),
                  ),
                  _buildSortableColumn('Timestamp', 'timestamp'),
                  _buildSortableColumn('Domain', 'domain'),
                  _buildSortableColumn('Severity', 'severity'),
                  _buildSortableColumn('Element', 'element'),
                  DataColumn(
                    label: Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _buildSortableColumn('Status', 'status'),
                  DataColumn(
                    label: Text(
                      'Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                rows: paginatedAlarms.map((alarm) {
                  return DataRow(
                    selected: _selectedAlarms.contains(alarm.id),
                    onSelectChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedAlarms.add(alarm.id);
                        } else {
                          _selectedAlarms.remove(alarm.id);
                        }
                      });
                    },
                    cells: [
                      DataCell(
                        Checkbox(
                          value: _selectedAlarms.contains(alarm.id),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedAlarms.add(alarm.id);
                              } else {
                                _selectedAlarms.remove(alarm.id);
                              }
                            });
                          },
                          activeColor: DarkThemeColors.chartPink,
                        ),
                      ),
                      DataCell(
                        Text(
                          _formatTimestamp(alarm.timestamp),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getDomainColor(
                              alarm.domain.displayName,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            alarm.domain.shortName,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getDomainColor(alarm.domain.displayName),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getSeverityColor(
                              alarm.severity,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            alarm.severity.displayName,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getSeverityColor(alarm.severity),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 150,
                          child: Text(
                            alarm.element,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Text(
                            alarm.description,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              alarm.status,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            alarm.status.displayName,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: _getStatusColor(alarm.status),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (alarm.status == AlarmStatus.active)
                              IconButton(
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                  color: DarkThemeColors.chartPink,
                                ),
                                onPressed: () => controller.acknowledgeAlarm(
                                  alarm.id,
                                  'NOC Manager',
                                ),
                                tooltip: 'Acknowledge',
                              ),
                            if (alarm.status == AlarmStatus.acknowledged ||
                                alarm.status == AlarmStatus.inProgress)
                              IconButton(
                                icon: const Icon(
                                  Icons.person_add,
                                  size: 18,
                                  color: Color(0xFF3b82f6),
                                ),
                                onPressed: () => _showAssignDialog(
                                  context,
                                  alarm,
                                  controller,
                                ),
                                tooltip: 'Assign',
                              ),
                            IconButton(
                              icon: const Icon(
                                Icons.visibility,
                                size: 18,
                                color: DarkThemeColors.chartPink,
                              ),
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/noc-alarm-detail',
                                arguments: alarm.id,
                              ),
                              tooltip: 'View Details',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.comment,
                                size: 18,
                                color: Color(0xFFfbbf24),
                              ),
                              onPressed: () => _showCommentDialog(
                                context,
                                alarm,
                                controller,
                              ),
                              tooltip: 'Add Comment',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  DataColumn _buildSortableColumn(String label, String columnId) {
    return DataColumn(
      label: InkWell(
        onTap: () {
          setState(() {
            if (_sortColumn == columnId) {
              _sortAscending = !_sortAscending;
            } else {
              _sortColumn = columnId;
              _sortAscending = true;
            }
          });
        },
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              _sortColumn == columnId
                  ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                  : Icons.unfold_more,
              size: 14,
              color: _sortColumn == columnId
                  ? DarkThemeColors.chartPink
                  : Colors.white38,
            ),
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
            Icons.search_off,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No alarms found',
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationBar() {
    return Consumer<NOCController>(
      builder: (context, controller, _) {
        final filteredAlarms = _getFilteredAlarms(controller);
        final sortedAlarms = _getSortedAlarms(filteredAlarms);
        final totalPages = (sortedAlarms.length / _itemsPerPage).ceil();

        if (totalPages <= 1) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF131823),
            border: Border(
              top: BorderSide(
                color: DarkThemeColors.chartPink.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page ${_currentPage + 1} of $totalPages',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: _currentPage > 0
                        ? () {
                            setState(() {
                              _currentPage--;
                            });
                          }
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: _currentPage < totalPages - 1
                        ? () {
                            setState(() {
                              _currentPage++;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<NOCAlarm> _getFilteredAlarms(NOCController controller) {
    var alarms = controller.alarms;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      alarms = alarms.where((alarm) {
        return alarm.element.toLowerCase().contains(query) ||
            alarm.description.toLowerCase().contains(query);
      }).toList();
    }

    // Apply domain filter
    if (_selectedDomain != null) {
      alarms = alarms.where((a) => a.domain == _selectedDomain).toList();
    }

    // Apply severity filter
    if (_selectedSeverity != null) {
      alarms = alarms.where((a) => a.severity == _selectedSeverity).toList();
    }

    // Apply status filter
    if (_selectedStatus != null) {
      alarms = alarms.where((a) => a.status == _selectedStatus).toList();
    }

    return alarms;
  }

  List<NOCAlarm> _getSortedAlarms(List<NOCAlarm> alarms) {
    final sorted = List<NOCAlarm>.from(alarms);

    sorted.sort((a, b) {
      int comparison = 0;
      switch (_sortColumn) {
        case 'timestamp':
          comparison = a.timestamp.compareTo(b.timestamp);
          break;
        case 'domain':
          comparison = a.domain.displayName.compareTo(b.domain.displayName);
          break;
        case 'severity':
          comparison = a.severity.index.compareTo(b.severity.index);
          break;
        case 'element':
          comparison = a.element.compareTo(b.element);
          break;
        case 'status':
          comparison = a.status.index.compareTo(b.status.index);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return sorted;
  }

  List<NOCAlarm> _getPaginatedAlarms(List<NOCAlarm> alarms) {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, alarms.length);

    if (startIndex >= alarms.length) return [];

    return alarms.sublist(startIndex, endIndex);
  }

  void _bulkAcknowledge() {
    final controller = context.read<NOCController>();
    controller.bulkAcknowledge(_selectedAlarms.toList(), 'NOC Manager');
    setState(() {
      _selectedAlarms.clear();
    });
  }

  void _showBulkAssignDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131823),
        title: Text(
          'Bulk Assign',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Assign ${_selectedAlarms.length} alarms to:',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                'RAN Engineer',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward, color: Colors.white70),
              onTap: () {
                context.read<NOCController>().bulkAssign(
                  _selectedAlarms.toList(),
                  'RAN Engineer',
                );
                Navigator.pop(context);
                setState(() {
                  _selectedAlarms.clear();
                });
              },
            ),
            ListTile(
              title: Text(
                'CORE Engineer',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward, color: Colors.white70),
              onTap: () {
                context.read<NOCController>().bulkAssign(
                  _selectedAlarms.toList(),
                  'CORE Engineer',
                );
                Navigator.pop(context);
                setState(() {
                  _selectedAlarms.clear();
                });
              },
            ),
            ListTile(
              title: Text(
                'IP Engineer',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward, color: Colors.white70),
              onTap: () {
                context.read<NOCController>().bulkAssign(
                  _selectedAlarms.toList(),
                  'IP Engineer',
                );
                Navigator.pop(context);
                setState(() {
                  _selectedAlarms.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(
    BuildContext context,
    NOCAlarm alarm,
    NOCController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131823),
        title: Text(
          'Assign Alarm',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Assign ${alarm.element} to:',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                'RAN Engineer',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward, color: Colors.white70),
              onTap: () {
                controller.assignAlarm(alarm.id, 'RAN Engineer');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'CORE Engineer',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward, color: Colors.white70),
              onTap: () {
                controller.assignAlarm(alarm.id, 'CORE Engineer');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'IP Engineer',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward, color: Colors.white70),
              onTap: () {
                controller.assignAlarm(alarm.id, 'IP Engineer');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentDialog(
    BuildContext context,
    NOCAlarm alarm,
    NOCController controller,
  ) {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131823),
        title: Text(
          'Add Comment',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: TextField(
          controller: commentController,
          maxLines: 3,
          style: GoogleFonts.poppins(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your comment...',
            hintStyle: GoogleFonts.poppins(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1a2030),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (commentController.text.isNotEmpty) {
                controller.addComment(
                  alarm.id,
                  commentController.text,
                  'NOC Manager',
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DarkThemeColors.chartPink,
            ),
            child: Text('Add', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  Color _getSeverityColor(AlarmSeverity severity) {
    switch (severity) {
      case AlarmSeverity.critical:
        return const Color(0xFFef4444);
      case AlarmSeverity.major:
        return const Color(0xFFf97316);
      case AlarmSeverity.minor:
        return const Color(0xFFfbbf24);
      case AlarmSeverity.warning:
        return const Color(0xFF3b82f6);
      case AlarmSeverity.info:
        return const Color(0xFF6366f1);
    }
  }

  Color _getStatusColor(AlarmStatus status) {
    switch (status) {
      case AlarmStatus.active:
        return const Color(0xFFef4444);
      case AlarmStatus.acknowledged:
        return const Color(0xFFfbbf24);
      case AlarmStatus.inProgress:
        return const Color(0xFF3b82f6);
      case AlarmStatus.resolved:
        return const Color(0xFF10b981);
      case AlarmStatus.closed:
        return const Color(0xFF6b7280);
    }
  }

  Color _getDomainColor(String domain) {
    switch (domain) {
      case 'RAN':
        return const Color(0xFF10b981);
      case 'CORE':
        return const Color(0xFF0ea5e9);
      case 'IP':
        return const Color(0xFFf59e0b);
      default:
        return Colors.grey;
    }
  }
}
