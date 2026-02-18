import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../styles/app_theme.dart';
import '../widgets/admin_dashboard_layout.dart';
import '../services/admin_service.dart';

class DataImportScreen extends StatefulWidget {
  const DataImportScreen({super.key});

  @override
  State<DataImportScreen> createState() => _DataImportScreenState();
}

class _DataImportScreenState extends State<DataImportScreen> {
  final AdminService _adminService = AdminService();
  bool _isLoading = false;

  Future<void> _importData(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final platformFile = result.files.single;
        final bytes = platformFile.bytes;

        if (bytes == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to read file bytes')),
          );
          return;
        }

        setState(() => _isLoading = true);

        if (type == 'club') {
          // Both users and clubs use the same service method for now
          await _adminService.uploadUsersFile(bytes, platformFile.name);
        } else {
          // type is student or faculty
          await _adminService.uploadUsersFile(bytes, platformFile.name);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${type[0].toUpperCase()}${type.substring(1)} imported successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminDashboardLayout(
      activeRoute: '/admin/data-import',
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                const SizedBox(height: 32),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: MediaQuery.of(context).size.width > 900
                      ? 3
                      : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  children: [
                    _importCard(
                      title: 'Students',
                      description: 'Bulk import student accounts and profiles.',
                      icon: Icons.person,
                      color: Colors.green,
                      onTap: () => _importData('student'),
                    ),
                    _importCard(
                      title: 'Faculty',
                      description: 'Bulk import faculty accounts and profiles.',
                      icon: Icons.supervisor_account,
                      color: Colors.orange,
                      onTap: () => _importData('faculty'),
                    ),
                    _importCard(
                      title: 'Clubs & Roles',
                      description: 'Import club data and role mappings.',
                      icon: Icons.groups,
                      color: Colors.purple,
                      onTap: () => _importData('club'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Data Import',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Centralized tool to initialize and update institution data via CSV.',
                style: TextStyle(color: AppTheme.textLight),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _showFormatInfo,
          icon: const Icon(Icons.info_outline, size: 20),
          label: const Text('CSV Format Guide'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary.withOpacity(0.1),
            foregroundColor: AppTheme.primary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _importCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            const Text(
              'UPLOAD CSV',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFormatInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CSV Format Guide'),
        content: SizedBox(
          width: 800,
          child: DefaultTabController(
            length: 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TabBar(
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.textLight,
                  indicatorColor: AppTheme.primary,
                  tabs: [
                    Tab(text: 'Students'),
                    Tab(text: 'Faculty'),
                    Tab(text: 'Clubs & Roles'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    children: [
                      _formatTable([
                        ['mits_uid', 'Yes', 'Unique Student ID'],
                        ['name', 'Yes', 'Full Name'],
                        ['email', 'Yes', 'Institutional Email'],
                        ['user_type_tag', 'Yes', '"STUDENT"'],
                        ['batch_id', 'Yes', 'Batch ID'],
                        ['class_id', 'Yes', 'Class ID'],
                        ['hosteller', 'Yes', '"true" / "false"'],
                        ['gender', 'Yes', 'Male / Female'],
                        ['phone', 'Yes', 'Mobile Number'],
                        ['role_tag', 'No', 'e.g. CLASS_ADVISOR'],
                      ]),
                      _formatTable([
                        ['mits_uid', 'Yes', 'Employee ID'],
                        ['name', 'Yes', 'Full Name'],
                        ['email', 'Yes', 'Institutional Email'],
                        ['user_type_tag', 'Yes', '"FACULTY"'],
                        ['department_id', 'Yes', 'Department ID'],
                        ['role_tag', 'No', 'e.g. HOD'],
                      ]),
                      _formatTable([
                        ['mits_uid', 'Yes', 'Unique ID'],
                        ['name', 'Yes', 'Full Name'],
                        ['email', 'Yes', 'Institutional Email'],
                        ['user_type_tag', 'Yes', 'STUDENT / FACULTY'],
                        ['role_tag', 'No', 'e.g. HOD, ADMIN'],
                        ['club_role_tag', 'No', 'e.g. COORDINATOR'],
                        ['club_id', 'No', 'ID of the club (if mapping)'],
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _formatTable(List<List<String>> rows) {
    return SingleChildScrollView(
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade200, width: 1),
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(0.8),
          2: FlexColumnWidth(2),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade50),
            children: ['Key', 'Required', 'Description']
                .map(
                  (h) => Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      h,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                .toList(),
          ),
          ...rows.map(
            (row) => TableRow(
              children: row
                  .map(
                    (cell) => Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(cell, style: const TextStyle(fontSize: 13)),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
