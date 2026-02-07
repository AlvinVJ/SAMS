import 'package:flutter/material.dart';
import 'package:sams_final/admin_screens/admin_workflow_canvas_screen.dart';
import '../styles/app_theme.dart';
import '../widgets/admin_dashboard_layout.dart';
import '../services/admin_procedure_service.dart';
import 'admin_edit_procedure_screen.dart';

class AdminProceduresScreen extends StatefulWidget {
  const AdminProceduresScreen({super.key});

  @override
  State<AdminProceduresScreen> createState() => _AdminProceduresScreenState();
}

class _AdminProceduresScreenState extends State<AdminProceduresScreen> {
  final AdminProcedureService _service = AdminProcedureService();
  List<ProcedureSummary> _procedures = [];
  List<ProcedureSummary> _filteredProcedures = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProcedures();
  }

  Future<void> _fetchProcedures() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final procedures = await _service.fetchProcedures();
      setState(() {
        _procedures = procedures;
        _filteredProcedures = procedures;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterProcedures(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredProcedures = _procedures;
      } else {
        _filteredProcedures = _procedures
            .where(
              (p) =>
                  p.title.toLowerCase().contains(query.toLowerCase()) ||
                  p.description.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  Future<void> _deleteProcedure(String procedureId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Procedure'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteProcedure(procedureId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Procedure deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchProcedures(); // Refresh list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✗ Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminDashboardLayout(
      activeRoute: '/admin/procedures',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ───────────────── Header ─────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Procedures',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage approval procedures and workflows',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppTheme.textLight),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminCreateProcedureScreen(),
                    ),
                  );
                  // Refresh list if procedure was created
                  if (result == true) {
                    _fetchProcedures();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Procedure'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ───────────────── Search Bar ─────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardBox(),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: _filterProcedures,
                    decoration: _inputDecoration(
                      'Search procedures...',
                      Icons.search,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchProcedures,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ───────────────── Content ─────────────────
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading procedures',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppTheme.textLight),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _fetchProcedures,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_filteredProcedures.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.inbox,
                      size: 48,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No procedures yet'
                          : 'No procedures found',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isEmpty
                          ? 'Create your first procedure to get started'
                          : 'Try a different search term',
                      style: const TextStyle(color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredProcedures.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.25,
              ),
              itemBuilder: (context, index) {
                return _ProcedureCard(
                  procedure: _filteredProcedures[index],
                  onDelete: () => _deleteProcedure(
                    _filteredProcedures[index].procId,
                    _filteredProcedures[index].title,
                  ),
                  onRefresh: _fetchProcedures,
                );
              },
            ),
        ],
      ),
    );
  }
}

/// ───────────────── Card Widget ─────────────────
class _ProcedureCard extends StatelessWidget {
  final ProcedureSummary procedure;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  const _ProcedureCard({
    required this.procedure,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardBox(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.description, color: Colors.blue, size: 28),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: AppTheme.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            procedure.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          Text(
            procedure.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
          ),

          const Spacer(),

          Divider(color: Colors.grey.shade200),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _meta('Levels', '${procedure.approvalLevelsCount}'),
              _meta('Status', 'Active'),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminEditProcedureScreen(
                          procedureId: procedure.procId,
                        ),
                      ),
                    );

                    // Refresh if updated
                    if (result == true) {
                      onRefresh();
                    }
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Icon(Icons.delete, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _meta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// ───────────────── Styling Helpers ─────────────────
BoxDecoration _cardBox() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: Colors.grey.shade200),
);

InputDecoration _inputDecoration(String hint, IconData icon) => InputDecoration(
  hintText: hint,
  prefixIcon: Icon(icon, color: AppTheme.textLight),
  filled: true,
  fillColor: AppTheme.backgroundLight,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide.none,
  ),
);
