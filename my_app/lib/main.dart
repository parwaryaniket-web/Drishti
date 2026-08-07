import 'package:flutter/material.dart';
import 'bluetooth_screen.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vision Assist',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool isListening = false;
  List<String> wifiNetworks = [];
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void toggleListening() {
    setState(() {
      isListening = !isListening;
    });
  }

  void scanWifi() async {
    await Permission.location.request();

    final can = await WiFiScan.instance.canStartScan();
    if (can != CanStartScan.yes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WiFi scan possible nahi hai is phone pe')),
      );
      return;
    }

    await WiFiScan.instance.startScan();

    final results = await WiFiScan.instance.getScannedResults();
    setState(() {
      wifiNetworks = results.map((ap) => ap.ssid).where((name) => name.isNotEmpty).toList();
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Nearby WiFi Networks', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: wifiNetworks.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(wifiNetworks[index], style: const TextStyle(color: Colors.white)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Band Karo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0C29),
              Color(0xFF302B63),
              Color(0xFF24243E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'VISION ASSIST',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Aapki Aankhen, Hamari Zimmedari',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.6),
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  isListening ? 'Sun Raha Hu...' : 'Bolne Ke Liye Tap Karo',
                  key: ValueKey<bool>(isListening),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 60),
              GestureDetector(
                onTap: toggleListening,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isListening
                              ? [Colors.redAccent, Colors.deepOrange]
                              : [Colors.blueAccent, Colors.purpleAccent],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isListening ? Colors.red : Colors.blue)
                                .withOpacity(0.6),
                            blurRadius: isListening
                                ? 40 * _pulseAnimation.value
                                : 25 * _pulseAnimation.value,
                            spreadRadius: isListening
                                ? 10 * _pulseAnimation.value
                                : 5 * _pulseAnimation.value,
                          ),
                        ],
                      ),
                      child: Icon(
                        isListening ? Icons.mic : Icons.mic_none_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIconButton(Icons.bluetooth, 'Bluetooth', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BluetoothScreen()),
                      );
                    }),
                    const SizedBox(width: 40),
                    _buildIconButton(Icons.wifi, 'WiFi', () {
                      scanWifi();
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }
}