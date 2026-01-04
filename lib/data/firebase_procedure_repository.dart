// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../state/in_memory_procedures.dart';

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

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../state/in_memory_procedures.dart';

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
      Uri.parse('$baseUrl/api/admin/procedures'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(procedure.toJson(adminUid: adminUid)),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to save procedure');
    }
  }
}
