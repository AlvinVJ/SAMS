import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';
import '../../widgets/admin_dashboard_layout.dart';
import '../../services/admin_service.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  final AdminService _adminService = AdminService();
  List<dynamic> _allRequests = [];
  List<dynamic> _filteredRequests = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Filter state
  String _searchQuery = '';
  String _statusFilter = 'All Statuses';
  String _procedureFilter = 'All Procedures';

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      setState(() => _isLoading = true);
      final data = await _adminService.getGlobalRequests();
      setState(() {
        _allRequests = data;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredRequests = _allRequests.where((req) {
        // Search filter
        final idMatch = req['req_id'].toString().toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        final nameMatch = (req['studentName'] ?? '')
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final procedureMatch = (req['procedure_title'] ?? '')
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final searchMatch = idMatch || nameMatch || procedureMatch;

        // Status filter
        bool statusMatch = true;
        if (_statusFilter != 'All Statuses') {
          statusMatch = req['status_text'].toString() == _statusFilter;
        }

        // Procedure filter
        bool procMatch = true;
        if (_procedureFilter != 'All Procedures') {
          procMatch = req['procedure_title'].toString() == _procedureFilter;
        }

        return searchMatch && statusMatch && procMatch;
      }).toList();
    });
  }

  List<String> _getUniqueProcedures() {
    final procedures = _allRequests
        .map((e) => e['procedure_title'].toString())
        .toSet()
        .toList();
    procedures.sort();
    return ['All Procedures', ...procedures];
  }

  @override
  Widget build(BuildContext context) {
    return AdminDashboardLayout(
      activeRoute: '/admin/requests',
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // PAGE HEADER
            // =========================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requests',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage and track all approval requests across the organization.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _fetchRequests,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'Refresh',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =========================
            // FILTER BAR
            // =========================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      onChanged: (val) {
                        _searchQuery = val;
                        _applyFilters();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search requests, students...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: AppTheme.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _statusFilter,
                      items:
                          const [
                                'All Statuses',
                                'Pending',
                                'Approved',
                                'Rejected',
                              ]
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _statusFilter = val;
                          _applyFilters();
                        }
                      },
                      decoration: _dropdownDecoration(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _procedureFilter,
                      items: _getUniqueProcedures()
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _procedureFilter = val;
                          _applyFilters();
                        }
                      },
                      decoration: _dropdownDecoration(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // TABLE
            // =========================
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Center(
                child: Text(
                  'Error: $_errorMessage',
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: DataTable(
                              horizontalMargin: 16,
                              columnSpacing: 24,
                              headingRowHeight: 56,
                              dataRowMaxHeight: 64,
                              headingRowColor: WidgetStateProperty.all(
                                AppTheme.backgroundLight,
                              ),
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    'S.No',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Procedure Name',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Submitted By',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Current Level',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Submission Date',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              rows: _filteredRequests
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => _buildRow(
                                      context,
                                      entry.value,
                                      entry.key,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        );
                      },
                    ),

                    // =========================
                    // FOOTER
                    // =========================
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${_filteredRequests.length} of ${_allRequests.length} requests',
                            style: const TextStyle(color: AppTheme.textLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =========================
  // HELPERS
  // =========================

  static InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppTheme.backgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  static DataRow _buildRow(BuildContext context, dynamic r, int index) {
    // Parse color
    Color statusColor = AppTheme.warning;
    final colorStr = r['color']?.toString().toLowerCase();
    if (colorStr == 'success') statusColor = AppTheme.success;
    if (colorStr == 'error') statusColor = AppTheme.error;

    final dateStr = r['created_at']?.toString().split('T')[0] ?? '';

    return DataRow(
      cells: [
        DataCell(
          Text(
            '${index + 1}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(Text(r['procedure_title'] ?? '')),
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                child: Text(
                  (r['studentName'] ?? '?').toString().toUpperCase().substring(
                    0,
                    1,
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r['studentName'] ?? 'Unknown'),
                  Text(
                    r['department'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(Text('Level ${r['current_level']} / ${r['total_levels']}')),
        DataCell(_statusBadge(r['status_text'] ?? 'Pending', statusColor)),
        DataCell(Text(dateStr)),
      ],
    );
  }

  static Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
