import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../widgets/dashboard_layout.dart';
import '../styles/app_theme.dart';
import '../data/firebase_procedure_repository.dart';
import '../state/in_memory_procedures.dart';
import '../config/environment.dart';

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
    Environment.apiUrl,
  );

  bool _isUploading = false;

  String _getMimeType(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'svg':
        return 'image/svg+xml';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'csv':
        return 'text/csv';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _pickGenericFile(FormFieldDraft field) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'jpeg',
          'png',
          'svg',
          'doc',
          'docx',
          'csv',
          'xls',
          'xlsx'
        ],
        withData: true,
      );

      if (result != null) {
        setState(() => _isUploading = true);
        final file = result.files.first;

        final mimeType = _getMimeType(file.extension);

        setState(() {
          _values[field.fieldId] = {
            'name': file.name,
            'type': mimeType,
            'bytes': file.bytes, // Store bytes for Flutter Web compatibility
          };
          _controllers[field.fieldId] ??= TextEditingController();
          _controllers[field.fieldId]!.text = file.name;
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickAndParseCSV(FormFieldDraft field) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null) {
        setState(() => _isUploading = true);
        final file = result.files.first;
        final content = utf8.decode(file.bytes!);
        final lines = content.split('\n');

        // Simple CSV parsing: assume first column is mits_uid
        // Skip header if it exists
        List<Map<String, String>> students = [];
        bool hasHeader = lines.first.toLowerCase().contains('mits_uid');
        int startIndex = hasHeader ? 1 : 0;

        for (int i = startIndex; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;
          final parts = line.split(',');
          if (parts.isNotEmpty) {
            students.add({'mits_uid': parts[0].trim()});
          }
        }

        setState(() {
          _values[field.fieldId] = students;
          _controllers[field.fieldId] ??= TextEditingController();
          _controllers[field.fieldId]!.text =
              "${file.name} (${students.length} students)";
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to parse CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
                crossAxisAlignment: CrossAxisAlignment.stretch,
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

        FormFieldType.file => _buildGenericFileField(field, label),
        FormFieldType.csv => _buildCSVFileField(field, label),
      },
    );
  }

  Widget _buildGenericFileField(FormFieldDraft field, String label) {
    _controllers[field.fieldId] ??= TextEditingController();
    final buttonLabel = _values[field.fieldId] == null
        ? "Upload File"
        : "Change File";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        ElevatedButton.icon(
          icon: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file),
          label: Text(buttonLabel),
          onPressed: _isUploading ? null : () => _pickGenericFile(field),
        ),
        if (_values[field.fieldId] != null) ...[
          const SizedBox(height: 8),
          _fileSelectedText(field.fieldId),
        ],
        if (field.required && _values[field.fieldId] == null)
          _errorText("Required *"),
      ],
    );
  }

  Widget _buildCSVFileField(FormFieldDraft field, String label) {
    final buttonLabel = _values[field.fieldId] == null
        ? "Upload Student List (CSV)"
        : "Change CSV";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        ElevatedButton.icon(
          icon: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.table_chart_outlined),
          label: Text(buttonLabel),
          onPressed: _isUploading ? null : () => _pickAndParseCSV(field),
        ),
        if (_values[field.fieldId] != null) _fileSelectedText(field.fieldId),
        if (field.required && _values[field.fieldId] == null)
          _errorText("Required *"),
      ],
    );
  }

  Widget _fileSelectedText(String fieldId) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        _controllers[fieldId]?.text ?? "File selected",
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
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
      child: Text(
        text,
        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
      ),
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

    // 1. Validate TextFields
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Validate Required File/CSV fields (since they aren't TextFormFields)
    for (var field in widget.fields) {
      if (field.required &&
          (field.type == FormFieldType.file || field.type == FormFieldType.csv)) {
        if (_values[field.fieldId] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please upload the required file: ${field.label}'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

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
      // Find a file to upload if it exists
      List<int>? fileBytes;
      String? fileName;
      for (var entry in _values.entries) {
        if (entry.value is Map && entry.value.containsKey('bytes')) {
          fileBytes = entry.value['bytes'];
          fileName = entry.value['name'];
          break;
        }
      }

      // Create a copy of values for JSON submission, excluding raw bytes
      final Map<String, dynamic> submissionValues = Map.from(_values);
      submissionValues.forEach((key, value) {
        if (value is Map && value.containsKey('bytes')) {
          submissionValues[key] = {
            'name': value['name'],
            'type': value['type'],
            // 'bytes' removed here!
          };
        }
      });

      // Submit to backend using ProcedureService
      await _requestRepo.createRequest(
        procedureId: widget.procedureId,
        values: submissionValues,
        authToken: await FirebaseAuth.instance.currentUser!.getIdToken(),
        fileName: fileName,
        fileBytes: fileBytes,
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
