import 'dart:async';

import 'package:flutter/material.dart';

import '../models/sensor_data.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SensorData? sensor;
  String? error;
  bool loading = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    loadData();

    timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => loadData(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final data = await ApiService.getLatestSensor();

      if (!mounted) return;

      setState(() {
        sensor = data;
        error = null;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Widget metricCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 34),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sensor == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error ?? 'No data',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Home status: ONLINE',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          metricCard(
            'Temperature',
            '${sensor!.temperature.toStringAsFixed(1)} °C',
            Icons.thermostat,
          ),
          metricCard(
            'Humidity',
            '${sensor!.humidity.toStringAsFixed(1)} %',
            Icons.water_drop,
          ),
          metricCard(
            'Motion',
            sensor!.motion ? 'DETECTED' : 'No motion',
            Icons.directions_run,
          ),
          metricCard(
            'Gas sensor',
            '${sensor!.gas}',
            Icons.warning_amber,
          ),
          metricCard(
            'Light sensor',
            '${sensor!.light}',
            Icons.light_mode,
          ),
        ],
      ),
    );
  }
}
