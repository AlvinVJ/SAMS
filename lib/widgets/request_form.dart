import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/admin_dashboard_layout.dart';
import '../styles/app_theme.dart';
import '../data/firebase_procedure_repository.dart';
import '../state/in_memory_procedures.dart';

class RequestFormScreen extends StatefulWidget {
  final ProcedureDraft procedure;
  final String procedureId;

  const RequestFormScreen({
    super.key,
    required this.procedureId,
    required this.procedure,
  });

  @override
  State<RequestFormScreen> createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _values = {};

  final ApiProcedureRepository _requestRepo = ApiProcedureRepository(
    "http://localhost:3000",
  );

  @override
  Widget build(BuildContext context) {
    return AdminDashboardLayout(
      disableSidebar: true,
      activeRoute: '/requests/create',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          ),

          const SizedBox(height: 12),

          Text(
            widget.procedure.title,
            style: Theme.of(context).textTheme.headlineLarge,
          ),

          const SizedBox(height: 6),

          Text(
            widget.procedure.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textLight),
          ),

          const SizedBox(height: 24),

          Form(
            key: _formKey,
            child: Column(
              children: [
                ...widget.procedure.formSchema.map(_buildField),

                const SizedBox(height: 32),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Submit Request'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── Field Renderer ─────────────────

  Widget _buildField(FormFieldDraft field) {
    final label = field.required ? '${field.label} *' : field.label;

    switch (field.type) {
      case FormFieldType.text:
        return _wrap(
          TextFormField(
            decoration: InputDecoration(labelText: label),
            validator: field.required
                ? (v) => v == null || v.isEmpty ? 'Required' : null
                : null,
            onChanged: (v) => _values[field.fieldId] = v,
          ),
        );

      case FormFieldType.date:
        return _wrap(
          TextFormField(
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
                setState(() {
                  _values[field.fieldId] = picked;
                });
              }
            },
          ),
        );

      case FormFieldType.singleChoice:
        return _wrap(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              ...field.options!.map(
                (opt) => RadioListTile(
                  value: opt,
                  groupValue: _values[field.fieldId],
                  title: Text(opt),
                  onChanged: (v) {
                    setState(() {
                      _values[field.fieldId] = v;
                    });
                  },
                ),
              ),
              if (field.required && _values[field.fieldId] == null)
                const Text(
                  'Required',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
            ],
          ),
        );

      case FormFieldType.multipleChoice:
        _values[field.fieldId] ??= <String>[];

        return _wrap(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label),
              ...field.options!.map(
                (opt) => CheckboxListTile(
                  value: _values[field.fieldId].contains(opt),
                  title: Text(opt),
                  onChanged: (checked) {
                    setState(() {
                      checked!
                          ? _values[field.fieldId].add(opt)
                          : _values[field.fieldId].remove(opt);
                    });
                  },
                ),
              ),
            ],
          ),
        );

      case FormFieldType.file:
        return _wrap(
          ElevatedButton.icon(
            icon: const Icon(Icons.upload),
            label: Text(label),
            onPressed: () {
              // file picker later
            },
          ),
        );
    }
  }

  Widget _wrap(Widget child) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: child);
  }

  // ───────────────── Submit ─────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await FirebaseAuth.instance.currentUser!.getIdToken();

    await _requestRepo.createRequest(
      procedureId: widget.procedureId,
      values: _values,
      authToken: token,
    );

    Navigator.pop(context);
  }
}
