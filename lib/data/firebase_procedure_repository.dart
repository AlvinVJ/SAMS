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
          "visibility": procedure.visibility.contains(ProcedureVisibility.all)
              ? ["all"]
              : procedure.visibility.map((v) => v.name).toList(),
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

  Future<List<Map<String, String>>> fetchRoles(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/helper/roles?search=$query'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map<Map<String, String>>((item) {
            return {
              'id': item['id'].toString(),
              'name': item['name'].toString(),
            };
          }).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load roles: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching roles: $e');
      return []; // Return empty list on error to prevent crashing
    }
  }
}
