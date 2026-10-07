import 'package:flutter/material.dart';

import '../models/sensor_data.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<SensorData> items = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final data = await ApiService.getHistory(limit: 50);

      if (!mounted) return;

      setState(() {
        items = data;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    return RefreshIndicator(
      onRefresh: load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.timeline),
              title: Text(
                '${item.temperature.toStringAsFixed(1)} °C | '
                '${item.humidity.toStringAsFixed(1)} %',
              ),
              subtitle: Text(
                'Gas: ${item.gas} | Light: ${item.light} | '
                'Motion: ${item.motion ? "Yes" : "No"}\n'
                '${item.timestamp?.toLocal().toString() ?? ""}',
              ),
            ),
          );
        },
      ),
    );
  }
}