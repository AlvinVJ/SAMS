
import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/faculty_dashboard_layout.dart';

class FacultyDashboardScreen extends StatelessWidget {
  FacultyDashboardScreen({super.key});

  // ===== Dummy Data (API placeholder) =====
  final String facultyName = "Dr. Sarah Johnson";

  final int pending = 3;
  final int approved = 12;
  final int rejected = 1;
  final int total = 16;

  final List<Map<String, String>> latestUpdates = [
    {"msg": "Your request #REQ-2023-081 was approved by the Dean.", "time": "2 hours ago", "color": "green"},
    {"msg": "Request #REQ-2023-078 was returned for correction.", "time": "Yesterday", "color": "red"},
    {"msg": "System maintenance scheduled for Oct 28, 10 PM - 2 AM.", "time": "Oct 21", "color": "blue"},
  ];

  final List<Map<String, String>> pendingApprovals = [
    {"id": "#REQ-2023-089", "subject": "Lab Equipment Purchase", "date": "Oct 23, 2023", "status": "Pending Dean"},
    {"id": "#REQ-2023-092", "subject": "Conference Leave Application", "date": "Oct 22, 2023", "status": "Under Review"},
    {"id": "#REQ-2023-085", "subject": "Research Grant Allocation", "date": "Oct 20, 2023", "status": "Pending Finance"},
  ];

  @override
  Widget build(BuildContext context) {
    return FacultyDashboardLayout(
      activeRoute: "/faculty/dashboard",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome
          Text("Welcome back, $facultyName!",
              style: Theme.of(context).textTheme.headlineLarge),
          const Text(
            "Here's an overview of your faculty requests and approvals for today.",
            style: TextStyle(color: AppTheme.textLight),
          ),

          const SizedBox(height: 28),

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

          const SizedBox(height: 28),

          // ===== QUICK ACTIONS + LATEST UPDATES =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _quickActions(context)),
              const SizedBox(width: 28),
              Expanded(flex: 1, child: _latestUpdatesBox()),
            ],
          ),

          // const SizedBox(height: 4),

          // ===== PENDING APPROVALS TABLE =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recent Pending Approvals",
                  style: Theme.of(context).textTheme.titleLarge),
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
          Text("$count",
              style: const TextStyle(
                  fontSize: 30, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );

  Widget _quickActions(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: _cardBox,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Quick Actions",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(
          children: [
            _action("Create Request", Icons.add, context, "/faculty/create-request", primary: true),
            const SizedBox(width: 16),
            _action("Review Approvals", Icons.fact_check, context, "/faculty/requests"),
            const SizedBox(width: 16),
            _action("View History", Icons.history, context, "/faculty/history"),
          ],
        ),
      ],
    ),
  );

  Widget _action(String label, IconData icon, BuildContext ctx, String route, {bool primary = false}) =>
      Expanded(
        child: InkWell(
          onTap: () => Navigator.pushNamed(ctx, route),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: primary ? AppTheme.primary : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(icon, color: primary ? Colors.white : AppTheme.primary),
                const SizedBox(height: 10),
                Text(label,
                    style: TextStyle(
                        color: primary ? Colors.white : AppTheme.textDark,
                        fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ),
      );

  Widget _latestUpdatesBox() => Container(
    padding: const EdgeInsets.all(24),
    decoration: _cardBox,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Latest Updates",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      Text(u["msg"]!,
                          style: const TextStyle(color: AppTheme.textDark)),
                      Text(u["time"]!,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textLight)),
                    ],
                  ),
                )
              ],
            ),
          ),
      ],
    ),
  );

  Widget _pendingTable() => Container(
    padding: const EdgeInsets.all(24),
    decoration: _cardBox,
    child: DataTable(
      columns: const [
        DataColumn(label: Text("Request ID")),
        DataColumn(label: Text("Subject")),
        DataColumn(label: Text("Date")),
        DataColumn(label: Text("Status")),
      ],
      rows: pendingApprovals.map((p) {
        return DataRow(cells: [
          DataCell(Text(p["id"]!)),
          DataCell(Text(p["subject"]!)),
          DataCell(Text(p["date"]!)),
          DataCell(Text(p["status"]!,
              style: const TextStyle(color: Colors.orange))),
        ]);
      }).toList(),
    ),
  );

  // ---------- Reusables ----------
  final _cardBox = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.grey.shade200),
  );

  Widget _dot(String c) {
    Color color =
        c == "green" ? Colors.green : c == "red" ? Colors.red : AppTheme.primary;
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
