class SensorData {
  final String deviceId;
  final double temperature;
  final double humidity;
  final bool motion;
  final int gas;
  final int light;
  final DateTime? timestamp;

  SensorData({
    required this.deviceId,
    required this.temperature,
    required this.humidity,
    required this.motion,
    required this.gas,
    required this.light,
    this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      deviceId: json['device_id']?.toString() ?? 'unknown',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0,
      motion: json['motion'] == true,
      gas: (json['gas'] as num?)?.toInt() ?? 0,
      light: (json['light'] as num?)?.toInt() ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
    );
  }
}
