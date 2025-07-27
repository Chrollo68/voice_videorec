import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'screens/homescreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio & Video Recorder',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const PermissionCheckScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PermissionCheckScreen extends StatefulWidget {
  const PermissionCheckScreen({super.key});

  @override
  State<PermissionCheckScreen> createState() => _PermissionCheckScreenState();
}

class _PermissionCheckScreenState extends State<PermissionCheckScreen> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.microphone,
      Permission.camera,
      Permission.audio,
      Permission.videos,
    ];
    final statuses = await permissions.request();

    final denied = statuses.entries.where((entry) => entry.value.isDenied);

    if (denied.isNotEmpty) {
      _showPermissionDialog();
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Permissions Required"),
        content:
            const Text("This app needs microphone and camera access to work."),
        actions: [
          TextButton(
            onPressed: () => openAppSettings(),
            child: const Text("Open Settings"),
          ),
          TextButton(
            onPressed: () => _requestPermissions(),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
