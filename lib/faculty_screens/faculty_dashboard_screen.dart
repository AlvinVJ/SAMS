import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/faculty_dashboard_layout.dart';
import '../services/auth_service.dart';
import '../services/faculty_service.dart';

class FacultyDashboardScreen extends StatefulWidget {
  const FacultyDashboardScreen({super.key});

  @override
  State<FacultyDashboardScreen> createState() => _FacultyDashboardScreenState();
}

class _FacultyDashboardScreenState extends State<FacultyDashboardScreen> {
  String _facultyName = "Faculty";
  bool _isLoading = true;
  String? _errorMessage;

  // Real Data
  int pending = 0;
  int approved = 0;
  int rejected = 0;
  int total = 0;
  List<dynamic> breakdown = [];
  List<dynamic> latestUpdates = [];
  List<dynamic> pendingApprovals = [];

  String _selectedRole = "";
  List<String> _roles = [];
  final FacultyService _facultyService = FacultyService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadDashboardData();
  }

  void _loadProfile() {
    final profile = AuthService().userProfile;
    if (profile != null) {
      setState(() {
        if (profile.displayName != null) _facultyName = profile.displayName!;
        _roles = profile.roleTags ?? [];

        // Default to Class Advisor if available, otherwise first role
        if (_roles.contains("class_advisor")) {
          _selectedRole = "class_advisor";
        } else if (_roles.isNotEmpty) {
          _selectedRole = _roles.first;
        }
      });
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _facultyService.fetchDashboardData(
        role: _selectedRole,
      );
      setState(() {
        pending = data['stats']['pending'] ?? 0;
        approved = data['stats']['approved'] ?? 0;
        rejected = data['stats']['rejected'] ?? 0;
        total = data['stats']['total'] ?? 0;
        breakdown = data['breakdown'] ?? [];
        pendingApprovals = data['recentPending'] ?? [];
        latestUpdates = data['updates'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const FacultyDashboardLayout(
        activeRoute: "/faculty/dashboard",
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return FacultyDashboardLayout(
        activeRoute: "/faculty/dashboard",
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text("Failed to load dashboard data"),
              Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDashboardData,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    return FacultyDashboardLayout(
      activeRoute: "/faculty/dashboard",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome + Role Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back, $_facultyName!",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Here's an overview of your faculty requests and approvals for today.",
                      style: TextStyle(color: AppTheme.textLight),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    icon: const Icon(Icons.filter_list, size: 20),
                    items: _roles
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(
                              r == "all"
                                  ? "All Roles"
                                  : r.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedRole = val);
                        _loadDashboardData();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ===== STATS CARDS =====
          Row(
            children: [
              _stats("Pending Approvals", pending, Colors.orange),
              const SizedBox(width: 16),
              _stats("Approved Requests", approved, Colors.green),
              const SizedBox(width: 16),
              _stats("Rejected Requests", rejected, Colors.red),
              const SizedBox(width: 16),
              _stats("Total Requests", total, AppTheme.primary),
            ],
          ),

          const SizedBox(height: 20),

          // ===== ANALYTICS + LATEST UPDATES =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _requestBreakdown()),
              const SizedBox(width: 28),
              Expanded(flex: 1, child: _latestUpdatesBox()),
            ],
          ),

          // ===== PENDING APPROVALS TABLE =====
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Pending Approvals",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(onPressed: () {}, child: const Text("View All")),
            ],
          ),

          const SizedBox(height: 16),
          _pendingTable(),
        ],
      ),
    );
  }

  // ---------- UI PARTS ----------
  Widget _stats(String title, int count, Color color) => Expanded(
    child: Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: _cardBox,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, color: color, size: 14),
          const Spacer(),
          Text(title, style: const TextStyle(color: AppTheme.textLight)),
          Text(
            "$count",
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );

  Widget _requestBreakdown() {
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.teal,
      Colors.orange,
      Colors.pink,
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardBox,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Request Breakdown",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Overview of request types you've been involved in.",
            style: TextStyle(color: AppTheme.textLight, fontSize: 13),
          ),
          const SizedBox(height: 24),
          if (breakdown.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "No request data yet",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: breakdown.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return SizedBox(
                  width: 180, // Fixed width for wrap items
                  child: _breakdownItem(
                    item['label'] ?? 'Unknown',
                    item['count'] ?? 0,
                    colors[index % colors.length],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _breakdownItem(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Icon(Icons.bar_chart, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _latestUpdatesBox() => Container(
    padding: const EdgeInsets.all(24),
    decoration: _cardBox,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Latest Updates",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        for (var u in latestUpdates)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                _dot(u["color"]!),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u["msg"]!,
                        style: const TextStyle(color: AppTheme.textDark),
                      ),
                      Text(
                        u["time"]!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  Widget _pendingTable() => Container(
    padding: const EdgeInsets.all(24),
    decoration: _cardBox,
    child: SizedBox(
      width: double.infinity,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("S.No")),
          DataColumn(label: Text("Subject")),
          DataColumn(label: Text("Date")),
          DataColumn(label: Text("Status")),
        ],
        rows: pendingApprovals.asMap().entries.map((entry) {
          final index = entry.key;
          final p = entry.value;
          return DataRow(
            cells: [
              DataCell(Text('${index + 1}')),
              DataCell(Text(p["subject"]!)),
              DataCell(Text(p["date"]!)),
              DataCell(
                Text(
                  p["status"]!,
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    ),
  );

  // ---------- Reusables ----------
  final _cardBox = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.grey.shade200),
  );

  Widget _dot(String c) {
    Color color = c == "green"
        ? Colors.green
        : c == "red"
        ? Colors.red
        : AppTheme.primary;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
