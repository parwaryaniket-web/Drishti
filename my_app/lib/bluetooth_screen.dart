import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<ScanResult> scanResults = [];
  bool isScanning = false;

  void startScan() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();

    setState(() {
      scanResults.clear();
      isScanning = true;
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    });

    await Future.delayed(const Duration(seconds: 4));
    setState(() {
      isScanning = false;
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${device.platformName} se connect ho gaya!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connect nahi ho paya: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Glasses Connect Karo')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isScanning ? null : startScan,
            child: Text(isScanning ? 'Scanning...' : 'Devices Dhundo'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                final result = scanResults[index];
                final deviceName = result.device.platformName.isNotEmpty
                    ? result.device.platformName
                    : 'Unknown Device';
                return ListTile(
                  title: Text(deviceName),
                  subtitle: Text(result.device.remoteId.toString()),
                  trailing: ElevatedButton(
                    onPressed: () => connectToDevice(result.device),
                    child: const Text('Connect'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}