import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppsScriptService {
  final Dio _dio = Dio();
  static const String _prefKey = 'apps_script_url';
  // Load from environment variable
  static String get _defaultUrl => dotenv.env['APPS_SCRIPT_URL'] ?? '';

  // Singleton
  static final AppsScriptService _instance = AppsScriptService._internal();
  factory AppsScriptService() => _instance;
  AppsScriptService._internal();

  Future<String?> getScriptUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey) ?? _defaultUrl;
  }

  Future<void> saveScriptUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, url);
  }

  Future<List<int>> convertOfficeToPdf(String filePath) async {
    final url = await getScriptUrl();
    if (url == null || url.isEmpty) {
      throw Exception('Script URL not configured. Please go to Settings.');
    }

    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final base64File = base64Encode(bytes);
    final fileName = file.path.split(Platform.pathSeparator).last;

    try {
      final response = await _dio.post(
        url,
        data: {'action': 'convert', 'file': base64File, 'filename': fileName},
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.data is Map && response.data['status'] == 'success') {
        final pdfBase64 = response.data['data']['file'];
        return base64Decode(pdfBase64);
      } else {
        throw Exception(response.data['message'] ?? 'Unknown script error');
      }
    } catch (e) {
      throw Exception('Conversion failed: $e');
    }
  }
}
