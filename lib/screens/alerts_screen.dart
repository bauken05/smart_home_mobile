import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<Map<String, dynamic>> alerts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final result = await ApiService.getAlerts();

      if (!mounted) return;

      setState(() {
        alerts = result;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.notification_important),
              title: Text(
                '${alert['level'] ?? ''}: ${alert['type'] ?? ''}',
              ),
              subtitle: Text(
                '${alert['message'] ?? ''}\n'
                '${alert['timestamp'] ?? ''}',
              ),
            ),
          );
        },
      ),
    );
  }
}