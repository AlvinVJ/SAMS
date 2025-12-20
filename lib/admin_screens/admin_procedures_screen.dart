import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import '../widgets/admin_dashboard_layout.dart';

class AdminProceduresScreen extends StatelessWidget {
  const AdminProceduresScreen({super.key});

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
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppTheme.textLight),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Create Procedure'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ───────────────── Filters ─────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardBox(),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: _inputDecoration(
                      'Search procedures...',
                      Icons.search,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    initialValue: 'all',
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Formats')),
                      DropdownMenuItem(value: 'form', child: Text('Form')),
                      DropdownMenuItem(value: 'letter', child: Text('Letter')),
                      DropdownMenuItem(value: 'sheet', child: Text('Sheet')),
                    ],
                    onChanged: (_) {},
                    decoration: _dropdownDecoration(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ───────────────── Grid ─────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _procedures.length, // 🔑 dummy data
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              return _ProcedureCard(_procedures[index]);
            },
          ),
        ],
      ),
    );
  }
}

/// ───────────────── Card Widget ─────────────────
class _ProcedureCard extends StatelessWidget {
  final _Procedure data;

  const _ProcedureCard(this.data);

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
              Icon(data.icon, color: data.color, size: 28),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            data.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(
            data.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style:
                const TextStyle(color: AppTheme.textLight, fontSize: 13),
          ),

          const Spacer(),

          Divider(color: Colors.grey.shade200),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _meta('Format', data.format),
              _meta('Levels', '${data.levels}'),
              _meta('Requests', '${data.requests}'),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('View'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Edit'),
                ),
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
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// ───────────────── Dummy Data (Replace with API) ─────────────────
final List<_Procedure> _procedures = [
  _Procedure(
    'Leave Application',
    'Standard procedure for requesting leave.',
    'Form',
    3,
    342,
    Icons.description,
    Colors.blue,
  ),
  _Procedure(
    'Purchase Request',
    'Office procurement approvals.',
    'Form',
    4,
    128,
    Icons.shopping_cart,
    Colors.purple,
  ),
  _Procedure(
    'Travel Authorization',
    'Official travel approval workflow.',
    'Letter',
    3,
    89,
    Icons.flight,
    Colors.orange,
  ),
  _Procedure(
    'Equipment Request',
    'Hardware and equipment provisioning.',
    'Form',
    2,
    56,
    Icons.devices,
    Colors.teal,
  ),
];

class _Procedure {
  final String title;
  final String description;
  final String format;
  final int levels;
  final int requests;
  final IconData icon;
  final Color color;

  _Procedure(
    this.title,
    this.description,
    this.format,
    this.levels,
    this.requests,
    this.icon,
    this.color,
  );
}

/// ───────────────── Styling Helpers ─────────────────
BoxDecoration _cardBox() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    );

InputDecoration _inputDecoration(String hint, IconData icon) =>
    InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.textLight),
      filled: true,
      fillColor: AppTheme.backgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );

InputDecoration _dropdownDecoration() => InputDecoration(
      filled: true,
      fillColor: AppTheme.backgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
