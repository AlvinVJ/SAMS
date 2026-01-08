import 'dart:convert';
import 'package:http/http.dart' as http;

class ProcedureSummary {
  final String id;
  final String title;
  final String description;

  ProcedureSummary({
    required this.id,
    required this.title,
    required this.description,
  });

  // Helper to parse the array format [id, title, desc]
  factory ProcedureSummary.fromArray(List<dynamic> array) {
    return ProcedureSummary(
      id: array[0].toString(),
      title: array[1].toString(),
      description: array[2].toString(),
    );
  }
}

class ProcedureService {
  // TODO: Replace with your actual backend URL or env variable
  final String baseUrl = 'http://localhost:3000';

  Future<List<ProcedureSummary>> fetchProcedures() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/common/fetch_procedures'),
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Navigate to the procedures array: response.data.procedures
        final List<dynamic> proceduresData = jsonResponse['data']['procedures'];

        return proceduresData.map((item) {
          return ProcedureSummary.fromArray(item as List<dynamic>);
        }).toList();
      } else {
        throw Exception('Failed to load procedures: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching procedures: $e');
    }
  }
}
