// lib/widgets/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class HomeScreen extends StatefulWidget {
  final FlutterReactiveBle? flutterReactiveBle;
  final Uuid serviceUuid;
  final Uuid charUuid;
  final String deviceName;
  final bool isScanning;
  final Function() onConnectPressed;
  final bool isConnected;

  const HomeScreen({
    super.key,
    required this.flutterReactiveBle,
    required this.serviceUuid,
    required this.charUuid,
    required this.deviceName,
    required this.isScanning,
    required this.onConnectPressed,
    required this.isConnected,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _todayScreenTime = 287; // minutes
  final int _screenTimeLimit = 480; // 8 hours
  final List<String> _recentApps = ['YouTube', 'TikTok', 'Instagram'];

  @override
  Widget build(BuildContext context) {
    final screenTimePercent = (_todayScreenTime / _screenTimeLimit).clamp(0.0, 1.0);
    final isExceeded = _todayScreenTime > _screenTimeLimit;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        const SizedBox(height: 8),
        
        // HEADER WITH DEVICE STATUS
        _buildStatusHeader(),
        const SizedBox(height: 20),

        // SCREEN TIME SUMMARY
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: isExceeded ? Colors.red.shade50 : Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today's Screen Time",
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isExceeded ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isExceeded ? 'Exceeded' : 'On Track',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_todayScreenTime min',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        color: isExceeded ? Colors.red : Colors.blue,
                      ),
                    ),
                    Text(
                      'Limit: $_screenTimeLimit min',
                      style: const TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: screenTimePercent,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isExceeded ? Colors.red : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // QUICK ACTIONS
        const Text(
          'Quick Actions',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickActionButton(
              icon: Icons.lock,
              label: 'Lock Device',
              color: Colors.red,
              onTap: () => ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Device locked'))),
            ),
            _buildQuickActionButton(
              icon: Icons.block,
              label: 'Block All Apps',
              color: Colors.orange,
              onTap: () => ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('All apps blocked'))),
            ),
            _buildQuickActionButton(
              icon: Icons.bedtime,
              label: 'Downtime',
              color: Colors.purple,
              onTap: () => ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Downtime enabled'))),
            ),
            _buildQuickActionButton(
              icon: Icons.history,
              label: 'Activity',
              color: Colors.teal,
              onTap: () => ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Opening activity log'))),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // RECENT APPS
        const Text(
          'Recent Apps Used',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ..._recentApps.map((app) => Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.app_shortcut, color: Colors.blue),
            ),
            title: Text(app, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('45 min today'),
            trailing: const Icon(Icons.chevron_right),
          ),
        )),
        const SizedBox(height: 24),

        // CONNECT BUTTON
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isConnected ? Colors.green : Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: widget.isScanning ? null : widget.onConnectPressed,
            icon: const Icon(Icons.bluetooth),
            label: Text(
              widget.isScanning
                  ? 'Scanning...'
                  : widget.isConnected
                      ? 'Device Connected'
                      : 'Connect Device',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatusHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Connected Device', style: TextStyle(fontSize: 12, color: Colors.black54)),
            Text(
              widget.deviceName,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isConnected ? Colors.green.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.isConnected ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.isConnected ? 'Online' : 'Offline',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: widget.isConnected ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
