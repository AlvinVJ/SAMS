import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/dashboard_layout.dart';
import '../styles/app_theme.dart';
import '../data/firebase_procedure_repository.dart';
import '../state/in_memory_procedures.dart';

class RequestFormScreen extends StatefulWidget {
  final String title;
  final String description;
  final List<FormFieldDraft> fields;
  final String procedureId;
  final String? activeRoute;

  const RequestFormScreen({
    super.key,
    required this.procedureId,
    required this.title,
    required this.description,
    required this.fields,
    required this.activeRoute,
  });

  @override
  State<RequestFormScreen> createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _values = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _multiChoiceErrors = {};

  final ApiProcedureRepository _requestRepo = ApiProcedureRepository(
    "http://localhost:3000",
  );

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      disableSidebar: true,
      activeRoute: widget.activeRoute,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          ),

          const SizedBox(height: 12),

          Text(widget.title, style: Theme.of(context).textTheme.headlineLarge),

          const SizedBox(height: 6),

          Text(
            widget.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textLight),
          ),

          const SizedBox(height: 24),

          // ───────────── Form Container ─────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ...widget.fields.map(_buildField),

                  const SizedBox(height: 32),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Submit Request'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── Field Renderer ─────────────────

  Widget _buildField(FormFieldDraft field) {
    final label = field.required ? '${field.label} *' : field.label;

    return _fieldCard(
      child: switch (field.type) {
        FormFieldType.text => TextFormField(
          decoration: InputDecoration(labelText: label),
          validator: field.required
              ? (v) => v == null || v.isEmpty ? 'Required' : null
              : null,
          onChanged: (v) => _values[field.fieldId] = v,
        ),

        FormFieldType.date => _buildDateField(field, label),

        FormFieldType.singleChoice => _buildSingleChoice(field, label),

        FormFieldType.multipleChoice => _buildMultiChoice(field, label),

        FormFieldType.file => ElevatedButton.icon(
          icon: const Icon(Icons.upload),
          label: Text(label),
          onPressed: () {},
        ),
      },
    );
  }

  Widget _buildDateField(FormFieldDraft field, String label) {
    _controllers[field.fieldId] ??= TextEditingController();

    return TextFormField(
      controller: _controllers[field.fieldId],
      readOnly: true,
      decoration: InputDecoration(labelText: label),
      validator: field.required
          ? (_) => _values[field.fieldId] == null ? 'Required' : null
          : null,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          initialDate: DateTime.now(),
        );

        if (picked != null) {
          final dateString = picked.toIso8601String().split('T').first;
          setState(() {
            // Store as ISO string, not DateTime object
            _values[field.fieldId] = dateString;
            _controllers[field.fieldId]!.text = dateString;
          });
        }
      },
    );
  }

  Widget _buildSingleChoice(FormFieldDraft field, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        ...field.options!.map(
          (opt) => RadioListTile<String>(
            value: opt,
            groupValue: _values[field.fieldId] as String?,
            title: Text(opt),
            onChanged: (v) {
              setState(() {
                _values[field.fieldId] = v;
              });
            },
          ),
        ),
        if (field.required && _values[field.fieldId] == null)
          _errorText('Required'),
      ],
    );
  }

  Widget _buildMultiChoice(FormFieldDraft field, String label) {
    _values[field.fieldId] ??= <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        ...field.options!.map(
          (opt) => CheckboxListTile(
            value: _values[field.fieldId].contains(opt),
            title: Text(opt),
            onChanged: (checked) {
              setState(() {
                checked!
                    ? _values[field.fieldId].add(opt)
                    : _values[field.fieldId].remove(opt);
                _multiChoiceErrors[field.fieldId] = null;
              });
            },
          ),
        ),
        if (_multiChoiceErrors[field.fieldId] != null)
          _errorText(_multiChoiceErrors[field.fieldId]!),
      ],
    );
  }

  // ───────────────── Styling Helpers ─────────────────

  Widget _fieldCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _errorText(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Text(
        text,
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }

  // ───────────────── Submit ─────────────────

  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_isSubmitting) return;

    _multiChoiceErrors.clear();

    for (final field in widget.fields) {
      if (field.type == FormFieldType.multipleChoice &&
          field.required &&
          (_values[field.fieldId] == null || _values[field.fieldId].isEmpty)) {
        _multiChoiceErrors[field.fieldId] = 'Select at least one option';
      }
    }

    if (_multiChoiceErrors.isNotEmpty) {
      setState(() {});
      return;
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Submit to backend using ProcedureService
      await _requestRepo.createRequest(
        procedureId: widget.procedureId,
        values: _values,
        authToken: await FirebaseAuth.instance.currentUser!.getIdToken(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Request submitted successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back to requests screen
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✗ Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
