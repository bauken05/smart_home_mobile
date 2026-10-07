import 'package:flutter/material.dart';

import '../services/api_service.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  bool light = false;
  bool fan = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStates();
  }

  Future<void> loadStates() async {
    try {
      final states = await ApiService.getDeviceStates();

      if (!mounted) return;

      setState(() {
        light = states['light'] ?? false;
        fan = states['fan'] ?? false;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> changeState(String device, bool value) async {
    try {
      await ApiService.sendCommand(device, value);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$device command sent: ${value ? "ON" : "OFF"}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: SwitchListTile(
            title: const Text('Living Room Light'),
            subtitle: const Text('ESP32 output GPIO 26'),
            value: light,
            onChanged: (value) {
              setState(() => light = value);
              changeState('light', value);
            },
            secondary: const Icon(Icons.lightbulb),
          ),
        ),
        Card(
          child: SwitchListTile(
            title: const Text('Fan'),
            subtitle: const Text('ESP32 output GPIO 25'),
            value: fan,
            onChanged: (value) {
              setState(() => fan = value);
              changeState('fan', value);
            },
            secondary: const Icon(Icons.air),
          ),
        ),
      ],
    );
  }
}
