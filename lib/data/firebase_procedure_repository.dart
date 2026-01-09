//import 'package:cloud_firestore/cloud_firestore.dart';
import '../state/in_memory_procedures.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// class FirebaseProcedureRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> saveProcedure({
//     required ProcedureDraft procedure,
//     required String adminUid,
//   }) async {
//     await _firestore.collection('procedures').add(
//           procedure.toJson(adminUid: adminUid),
//         );
//   }
// }

class ApiProcedureRepository {
  final String baseUrl;

  ApiProcedureRepository(this.baseUrl);

  Future<void> saveProcedure({
    required ProcedureDraft procedure,
    required String adminUid,
    required String? authToken,
  }) async {
    if (authToken == null) {
      throw Exception('Auth token is missing');
    }
    final response = await http.post(
      Uri.parse('$baseUrl/api/admin/saveProcedure'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      // body: jsonEncode(procedure.toJson(adminUid: adminUid)),
      body: jsonEncode({
        "adminUid": adminUid,

        "procedure": {
          "title": procedure.title,
          "desc": procedure.description,
          "visibility": procedure.visibility,
          "priority": "NORMAL",
          "isActive": true,

          "formBuilder": procedure.formSchema.map((f) => f.toJson()).toList(),

          "approvalLevels": procedure.approvalLevels
              .asMap()
              .entries
              .map((e) => e.value.toJson(e.key + 1))
              .toList(),
        },
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save procedure');
    }
  }

  Future<void> createRequest({
    required String procedureId,
    required Map<String, dynamic> values,
    required String? authToken,
  }) async {
    if (authToken == null) {
      throw Exception('Auth token is missing');
    }
    final response = await http.post(
      Uri.parse('$baseUrl/api/requests/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({"procedureId": procedureId, "formData": values}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create request');
    }
  }
}
