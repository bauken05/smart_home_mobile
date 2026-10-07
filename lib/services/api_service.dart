import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sensor_data.dart';

class ApiService {
  // Android emulator + backend same PC: http://10.0.2.2:8000
  // Physical phone: http://YOUR_LAPTOP_IP:8000
  // Cloud: https://your-api-domain.com
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<SensorData> getLatestSensor() async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/sensors/latest'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Sensor data unavailable: ${response.statusCode}');
    }

    return SensorData.fromJson(jsonDecode(response.body));
  }

  static Future<List<SensorData>> getHistory({int limit = 30}) async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/sensors/history?limit=$limit'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('History error: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((item) => SensorData.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<Map<String, bool>> getDeviceStates() async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/devices/state?edge_id=edge_01'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Device state error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return {
      'light': data['light'] == true,
      'fan': data['fan'] == true,
      'security': data['security'] == true,
    };
  }

  static Future<void> sendCommand(String device, bool state) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/devices/$device/command'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'state': state,
            'edge_id': 'edge_01',
          }),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Command error: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> getAlerts() async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/alerts?limit=30'))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception('Alerts error: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
