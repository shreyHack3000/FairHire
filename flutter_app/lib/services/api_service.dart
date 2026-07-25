import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/audit_models.dart';

class ApiService {
  static const String baseUrl = 'https://fairhire-backend-f8mp.onrender.com';

  /// Check backend server status
  static Future<bool> checkBackendHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'healthy' || data['status'] == 'online';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Upload CSV bytes to POST /audit endpoint
  static Future<AuditReport> uploadAndAuditCsv(
      Uint8List fileBytes, String filename) async {
    final uri = Uri.parse('$baseUrl/audit');
    final request = http.MultipartRequest('POST', uri);

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: filename,
    );

    request.files.add(multipartFile);

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'error') {
          throw Exception(data['message'] ?? 'Backend returned error status.');
        }
        return AuditReport.fromJson(data);
      } else {
        Map<String, dynamic>? errorJson;
        try {
          errorJson = json.decode(response.body);
        } catch (_) {}
        final msg = errorJson?['error'] ?? errorJson?['message'] ?? 'Server error (${response.statusCode})';
        throw Exception(msg);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network request failed: $e');
    }
  }

  /// Fetch all historical audits from Supabase PostgreSQL via GET /audits
  static Future<List<AuditHistoryItem>> fetchAuditHistory() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/audits'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawAudits = data['audits'] as List? ?? [];
        return rawAudits
            .map((item) => AuditHistoryItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
