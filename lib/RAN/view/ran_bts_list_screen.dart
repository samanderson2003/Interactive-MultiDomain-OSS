import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../controller/ran_controller.dart';
import '../model/bts_model.dart';
import 'dart:typed_data';
import 'package:excel/excel.dart' hide Border;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;

class RANBTSListScreen extends StatefulWidget {
  const RANBTSListScreen({super.key});

  @override
  State<RANBTSListScreen> createState() => _RANBTSListScreenState();
}

class _RANBTSListScreenState extends State<RANBTSListScreen> {
  String _searchQuery = '';
  String? _selectedCity;
  String? _selectedRegion;
  BTSStatus? _selectedStatus;
  String? _selectedTechnology;
  String _sortBy = 'name';
  bool _sortAscending = true;
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _exportToExcel(List<BTSModel> btsList) async {
    final excel = Excel.createExcel();
    final sheet = excel['BTS List'];

    // Add headers
    sheet.appendRow([
      TextCellValue('BTS Name'),
      TextCellValue('BTS ID'),
      TextCellValue('City'),
      TextCellValue('Region'),
      TextCellValue('Status'),
      TextCellValue('Technology'),
      TextCellValue('RSRP (dBm)'),
      TextCellValue('RSRQ (dB)'),
      TextCellValue('SINR (dB)'),
      TextCellValue('Capacity (%)'),
      TextCellValue('Active Users'),
      TextCellValue('Max Capacity'),
      TextCellValue('Latitude'),
      TextCellValue('Longitude'),
    ]);

    // Add data rows
    for (var bts in btsList) {
      sheet.appendRow([
        TextCellValue(bts.name),
        TextCellValue(bts.id),
        TextCellValue(bts.city),
        TextCellValue(bts.region),
        TextCellValue(bts.status.displayName),
        TextCellValue(bts.technology),
        DoubleCellValue(bts.rsrp),
        DoubleCellValue(bts.rsrq),
        DoubleCellValue(bts.sinr),
        DoubleCellValue(bts.capacityUtilization),
        IntCellValue(bts.activeUsers),
        IntCellValue(bts.maxCapacity),
        DoubleCellValue(bts.latitude),
        DoubleCellValue(bts.longitude),
      ]);
    }

    // Generate file
    final bytes = excel.encode();
    if (bytes != null) {
      final blob = html.Blob([Uint8List.fromList(bytes)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'BTS_List_Export.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Excel file downloaded successfully',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10b981),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _exportToPDF(List<BTSModel> btsList) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'BTS Tower List Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Total: ${btsList.length}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: [
                'BTS Name',
                'City',
                'Status',
                'Tech',
                'RSRP',
                'RSRQ',
                'SINR',
                'Capacity',
                'Users',
              ],
              data: btsList.map((bts) {
                return [
                  bts.name,
                  bts.city,
                  bts.status.displayName,
                  bts.technology,
                  '${bts.rsrp.toStringAsFixed(1)} dBm',
                  '${bts.rsrq.toStringAsFixed(1)} dB',
                  '${bts.sinr.toStringAsFixed(1)} dB',
                  '${bts.capacityUtilization.toStringAsFixed(0)}%',
                  '${bts.activeUsers}/${bts.maxCapacity}',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.centerRight,
                6: pw.Alignment.centerRight,
                7: pw.Alignment.centerRight,
                8: pw.Alignment.center,
              },
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'BTS_List_Report.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'PDF file downloaded successfully',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10b981),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showExportDialog(List<BTSModel> btsList) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF131823),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0ea5e9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.download,
                      color: Color(0xFF0ea5e9),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Export BTS List',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Choose export format for ${btsList.length} BTS records:',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              _buildExportOption(
                icon: Icons.table_chart,
                title: 'Excel (XLSX)',
                description: 'Export as spreadsheet with all data fields',
                color: const Color(0xFF10b981),
                onTap: () {
                  Navigator.pop(context);
                  _exportToExcel(btsList);
                },
              ),
              const SizedBox(height: 12),
              _buildExportOption(
                icon: Icons.picture_as_pdf,
                title: 'PDF Document',
                description: 'Export as formatted PDF report',
                color: const Color(0xFFef4444),
                onTap: () {
                  Navigator.pop(context);
                  _exportToPDF(btsList);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white60,
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

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1e293b)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  List<BTSModel> _getFilteredAndSortedBTS(RANController controller) {
    var filtered = controller.btsList;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((bts) {
        return bts.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            bts.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            bts.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            bts.city.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply city filter
    if (_selectedCity != null) {
      filtered = filtered.where((bts) => bts.city == _selectedCity).toList();
    }

    // Apply region filter
    if (_selectedRegion != null) {
      filtered = filtered
          .where((bts) => bts.region == _selectedRegion)
          .toList();
    }

    // Apply status filter
    if (_selectedStatus != null) {
      filtered = filtered
          .where((bts) => bts.status == _selectedStatus)
          .toList();
    }

    // Apply technology filter
    if (_selectedTechnology != null) {
      filtered = filtered
          .where((bts) => bts.technology == _selectedTechnology)
          .toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'city':
          comparison = a.city.compareTo(b.city);
          break;
        case 'status':
          comparison = a.status.displayName.compareTo(b.status.displayName);
          break;
        case 'rsrp':
          comparison = a.rsrp.compareTo(b.rsrp);
          break;
        case 'capacity':
          comparison = a.capacityUtilization.compareTo(b.capacityUtilization);
          break;
        case 'users':
          comparison = a.activeUsers.compareTo(b.activeUsers);
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
          final filteredBTS = _getFilteredAndSortedBTS(ranController);
          final totalPages = (filteredBTS.length / _itemsPerPage).ceil();
          final paginatedBTS = filteredBTS
              .skip(_currentPage * _itemsPerPage)
              .take(_itemsPerPage)
              .toList();

          return Column(
            children: [
              _buildAppBar(context, ranController),
              _buildSearchAndFilters(ranController),
              _buildToolbar(filteredBTS.length),
              Expanded(
                child: filteredBTS.isEmpty
                    ? _buildEmptyState()
                    : _buildDataTable(paginatedBTS, ranController),
              ),
              if (filteredBTS.isNotEmpty)
                _buildPagination(filteredBTS.length, totalPages),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, RANController controller) {
    final filteredBTS = _getFilteredAndSortedBTS(controller);

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
              Icons.list_alt,
              color: Color(0xFF0ea5e9),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'BTS Tower List',
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
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white70),
            onPressed: () {
              _showExportDialog(filteredBTS);
            },
            tooltip: 'Export Data',
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

  Widget _buildSearchAndFilters(RANController controller) {
    final cities = [
      'All Cities',
      ...controller.btsList.map((b) => b.city).toSet(),
    ];
    final regions = [
      'All Regions',
      ...controller.btsList.map((b) => b.region).toSet(),
    ];
    final technologies = [
      'All Tech',
      ...controller.btsList.map((b) => b.technology).toSet(),
    ];

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
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by name, ID, location, or city...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white38,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white38,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              color: Colors.white38,
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
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
                      setState(() {
                        _searchQuery = value;
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildDropdownFilter(
                'City',
                _selectedCity ?? 'All Cities',
                cities,
                (value) {
                  setState(() {
                    _selectedCity = value == 'All Cities' ? null : value;
                    _currentPage = 0;
                  });
                },
              ),
              const SizedBox(width: 12),
              _buildDropdownFilter(
                'Region',
                _selectedRegion ?? 'All Regions',
                regions,
                (value) {
                  setState(() {
                    _selectedRegion = value == 'All Regions' ? null : value;
                    _currentPage = 0;
                  });
                },
              ),
              const SizedBox(width: 12),
              _buildDropdownFilter(
                'Technology',
                _selectedTechnology ?? 'All Tech',
                technologies,
                (value) {
                  setState(() {
                    _selectedTechnology = value == 'All Tech' ? null : value;
                    _currentPage = 0;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                'Status:',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(width: 12),
              _buildStatusFilter(BTSStatus.active),
              const SizedBox(width: 8),
              _buildStatusFilter(BTSStatus.degraded),
              const SizedBox(width: 8),
              _buildStatusFilter(BTSStatus.inactive),
              const SizedBox(width: 8),
              _buildStatusFilter(BTSStatus.maintenance),
              const Spacer(),
              if (_searchQuery.isNotEmpty ||
                  _selectedCity != null ||
                  _selectedRegion != null ||
                  _selectedStatus != null ||
                  _selectedTechnology != null)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _selectedCity = null;
                      _selectedRegion = null;
                      _selectedStatus = null;
                      _selectedTechnology = null;
                      _currentPage = 0;
                    });
                  },
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: Text(
                    'Clear All Filters',
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

  Widget _buildStatusFilter(BTSStatus status) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = isSelected ? null : status;
          _currentPage = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? status.color.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
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

  Widget _buildToolbar(int totalResults) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF131823),
        border: Border(bottom: BorderSide(color: Color(0xFF1e293b))),
      ),
      child: Row(
        children: [
          Text(
            '$totalResults Results',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 24),
          Text(
            'Sort by:',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(width: 12),
          _buildSortButton('Name', 'name'),
          const SizedBox(width: 8),
          _buildSortButton('City', 'city'),
          const SizedBox(width: 8),
          _buildSortButton('Status', 'status'),
          const SizedBox(width: 8),
          _buildSortButton('RSRP', 'rsrp'),
          const SizedBox(width: 8),
          _buildSortButton('Capacity', 'capacity'),
          const SizedBox(width: 8),
          _buildSortButton('Users', 'users'),
        ],
      ),
    );
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
            _sortAscending = true;
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
            Icons.search_off,
            size: 64,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No BTS towers found',
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

  Widget _buildDataTable(List<BTSModel> btsList, RANController controller) {
    return SingleChildScrollView(
      child: FadeIn(
        duration: const Duration(milliseconds: 400),
        child: Container(
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF131823),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1e293b)),
          ),
          child: Column(
            children: [
              _buildTableHeader(),
              ...btsList.asMap().entries.map((entry) {
                return _buildTableRow(entry.value, entry.key);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell('BTS Info', flex: 3),
          _buildHeaderCell('Location', flex: 2),
          _buildHeaderCell('Status', flex: 1),
          _buildHeaderCell('Technology', flex: 1),
          _buildHeaderCell('Signal Quality', flex: 2),
          _buildHeaderCell('Capacity', flex: 1),
          _buildHeaderCell('Users', flex: 1),
          _buildHeaderCell('Actions', flex: 1),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white70,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTableRow(BTSModel bts, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFF1e293b).withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          // BTS Info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: bts.status.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: bts.status.color),
                      ),
                      child: Icon(
                        Icons.cell_tower,
                        size: 16,
                        color: bts.status.color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bts.name,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            bts.id,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Location
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Color(0xFF0ea5e9),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        bts.city,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  bts.region,
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
          // Status
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bts.status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: bts.status.color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: bts.status.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      bts.status.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: bts.status.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Technology
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3b82f6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                bts.technology,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3b82f6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Signal Quality
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSignalMetric('RSRP', bts.rsrp, bts.rsrpQuality),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: _buildMiniMetric('RSRQ', bts.rsrq)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildMiniMetric('SINR', bts.sinr)),
                  ],
                ),
              ],
            ),
          ),
          // Capacity
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text(
                  '${bts.capacityUtilization.toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: bts.capacityUtilization > 85
                        ? const Color(0xFFef4444)
                        : bts.capacityUtilization > 70
                        ? const Color(0xFFf59e0b)
                        : const Color(0xFF10b981),
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: bts.capacityUtilization / 100,
                    minHeight: 4,
                    backgroundColor: const Color(0xFF1e293b),
                    valueColor: AlwaysStoppedAnimation(
                      bts.capacityUtilization > 85
                          ? const Color(0xFFef4444)
                          : bts.capacityUtilization > 70
                          ? const Color(0xFFf59e0b)
                          : const Color(0xFF10b981),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Users
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text(
                  bts.activeUsers.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '/${bts.maxCapacity}',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
                ),
              ],
            ),
          ),
          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, size: 18),
                  color: const Color(0xFF0ea5e9),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/ran-bts-detail',
                      arguments: bts,
                    );
                  },
                  tooltip: 'View Details',
                ),
                IconButton(
                  icon: const Icon(Icons.location_on, size: 18),
                  color: const Color(0xFF10b981),
                  onPressed: () {
                    Navigator.pushNamed(context, '/ran-map', arguments: bts);
                  },
                  tooltip: 'View on Map',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalMetric(String label, double value, String quality) {
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

    return Row(
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
        ),
        Text(
          value.toStringAsFixed(1),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: qualityColor,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniMetric(String label, double value) {
    return Text(
      '$label: ${value.toStringAsFixed(1)}',
      style: GoogleFonts.inter(fontSize: 10, color: Colors.white38),
    );
  }

  Widget _buildPagination(int totalResults, int totalPages) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF131823),
        border: Border(top: BorderSide(color: Color(0xFF1e293b))),
      ),
      child: Row(
        children: [
          Text(
            'Showing ${_currentPage * _itemsPerPage + 1}-${((_currentPage + 1) * _itemsPerPage).clamp(0, totalResults)} of $totalResults',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            color: _currentPage > 0 ? Colors.white : Colors.white38,
            onPressed: _currentPage > 0
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
          ),
          ...List.generate(totalPages, (index) {
            if (totalPages <= 7 ||
                index == 0 ||
                index == totalPages - 1 ||
                (index >= _currentPage - 1 && index <= _currentPage + 1)) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentPage = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFF0ea5e9)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _currentPage == index
                          ? const Color(0xFF0ea5e9)
                          : const Color(0xFF1e293b),
                    ),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: _currentPage == index
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white70,
                    ),
                  ),
                ),
              );
            } else if (index == _currentPage - 2 || index == _currentPage + 2) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '...',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            color: _currentPage < totalPages - 1
                ? Colors.white
                : Colors.white38,
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
    );
  }
}
