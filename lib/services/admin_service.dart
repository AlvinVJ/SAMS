import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final String _baseUrl = "http://localhost:3000";

  Future<String?> _getToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return await user?.getIdToken();
  }

  Map<String, String> _headers(String token) => {
    "Authorization": "Bearer $token",
    "Content-Type": "application/json",
  };

  // ================= DEPARTMENTS =================

  Future<List<dynamic>> getDepartments() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/api/admin/departments"),
      headers: _headers(token!),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception("Failed to fetch departments");
  }

  Future<void> createDepartment(int id, String name) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse("$_baseUrl/api/admin/department"),
      headers: _headers(token!),
      body: json.encode({"dept_id": id, "dept_name": name}),
    );
    if (response.statusCode != 201)
      throw Exception("Failed to create department");
  }

  // ================= BATCHES =================

  Future<List<dynamic>> getBatches() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/api/admin/batches"),
      headers: _headers(token!),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception("Failed to fetch batches");
  }

  Future<void> createBatch(int id, String name) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse("$_baseUrl/api/admin/batch"),
      headers: _headers(token!),
      body: json.encode({"batch_id": id, "batch": name}),
    );
    if (response.statusCode != 201) throw Exception("Failed to create batch");
  }

  // ================= CLASSES =================

  Future<List<dynamic>> getClasses() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/api/admin/classes"),
      headers: _headers(token!),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception("Failed to fetch classes");
  }

  Future<void> createClass(int id, String name, int batchId, int deptId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse("$_baseUrl/api/admin/class"),
      headers: _headers(token!),
      body: json.encode({
        "class_id": id,
        "class": name,
        "batch_id": batchId,
        "dept_id": deptId,
      }),
    );
    if (response.statusCode != 201) throw Exception("Failed to create class");
  }

  // ================= USERS =================

  Future<List<dynamic>> getUsers({String? query}) async {
    final token = await _getToken();
    String url = "$_baseUrl/api/admin/users";
    if (query != null && query.isNotEmpty) {
      url += "?q=${Uri.encodeComponent(query)}";
    }
    final response = await http.get(Uri.parse(url), headers: _headers(token!));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception("Failed to fetch users");
  }

  Future<void> updateUser(String mitsUid, Map<String, dynamic> data) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse("$_baseUrl/api/admin/user/$mitsUid"),
      headers: _headers(token!),
      body: json.encode(data),
    );
    if (response.statusCode != 200) throw Exception("Failed to update user");
  }

  Future<List<dynamic>> getRoles() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/api/admin/roles"),
      headers: _headers(token!),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    // Note: I might need to implement this endpoint on backend if not existing
    return [];
  }

  // ================= REQUESTS =================

  Future<List<dynamic>> getGlobalRequests() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/api/admin/global-requests"),
      headers: _headers(token!),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception("Failed to fetch global requests");
  }

  Future<Map<String, dynamic>> getAdminDashboardStats() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/api/admin/dashboard-stats"),
      headers: _headers(token!),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception("Failed to fetch dashboard stats");
  }

  Future<void> uploadUsersFile(List<int> bytes, String fileName) async {
    final token = await _getToken();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$_baseUrl/api/admin/bulk-import-users"),
    );
    request.headers.addAll(_headers(token!));
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? "Failed to import users data");
    }
  }
}
