import 'package:flutter/material.dart';

import '../services/api_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool security = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadState();
  }

  Future<void> loadState() async {
    try {
      final states = await ApiService.getDeviceStates();

      if (!mounted) return;

      setState(() {
        security = states['security'] ?? false;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> change(bool value) async {
    setState(() => security = value);

    try {
      await ApiService.sendCommand('security', value);
    } catch (e) {
      if (!mounted) return;

      setState(() => security = !value);

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
            title: const Text('Security Mode'),
            subtitle: Text(
              security
                  ? 'PIR motion will create an alert'
                  : 'Security monitoring is disabled',
            ),
            value: security,
            onChanged: change,
            secondary: const Icon(Icons.security),
          ),
        ),
      ],
    );
  }
}
