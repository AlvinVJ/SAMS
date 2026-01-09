import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sams_final/state/in_memory_procedures.dart';
import '../styles/app_theme.dart';
import '../widgets/dashboard_layout.dart';
import '../services/procedure_service.dart';
// TODO: Import RequestFormScreen once created
import '../widgets/request_form.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final ProcedureService _procedureService = ProcedureService();
  late Future<List<ProcedureSummary>> _proceduresFuture;

  @override
  void initState() {
    super.initState();
    _proceduresFuture = _procedureService.fetchProcedures();
  }

  /// Handles procedure selection by fetching details from Firebase
  /// and navigating to the Forms page
  Future<void> _handleProcedureSelection(String procedureId) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Fetch procedure details from Firebase Firestore
      final firestore = FirebaseFirestore.instance;
      final docSnapshot = await firestore
          .collection('procedures')
          .doc(procedureId)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('Procedure not found');
      }

      // Get the procedure data
      final procedureData = docSnapshot.data()!;

      // Convert to ProcedureDraft using the factory method
      final procedureDraft = ProcedureDraft.fromJson(procedureData);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to Request Form Screen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RequestFormScreen(
              procedureId: procedureId,
              title: procedureDraft.title,
              description: procedureDraft.description,
              fields: procedureDraft.formSchema,
            ),
          ),
        );
      }
    } catch (error) {
      // Close loading dialog if open
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading procedure: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      activeRoute: '/create-request',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Request',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select the category of request you would like to submit.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.textLight),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Dynamic Grid using FutureBuilder
          FutureBuilder<List<ProcedureSummary>>(
            future: _proceduresFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading procedures: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No procedures found.'));
              }

              final procedures = snapshot.data!;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.2,
                ),
                itemCount: procedures.length,
                itemBuilder: (context, index) {
                  final procedure = procedures[index];
                  return _buildCategoryCard(
                    icon: Icons.description, // Default icon
                    title: procedure.title,
                    description: procedure.description,
                    onTap: () => _handleProcedureSelection(procedure.id),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 32),

          // Help Info Box
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppTheme.primary, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need help choosing?',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'If you are unsure which category your request falls under, please select "General Request" or contact the student support center at support@sams.edu.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 28),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.grey.shade300,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
