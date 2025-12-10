// lib/widgets/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final bool parentalLockEnabled;
  final String? selectedProfile;
  final String? pinCode;
  final bool pinSet;
  final Function(bool) onParentalLockChanged;
  final Function(String) onProfileChanged;
  final Function(String) onPinChanged;

  const SettingsScreen({
    super.key,
    required this.parentalLockEnabled,
    required this.selectedProfile,
    required this.pinCode,
    required this.pinSet,
    required this.onParentalLockChanged,
    required this.onProfileChanged,
    required this.onPinChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _parentalLock;
  late String? _selectedProfile;
  late bool _screenTimeAlerts;
  late bool _appInstallBlocking;
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _parentalLock = widget.parentalLockEnabled;
    _selectedProfile = widget.selectedProfile;
    _screenTimeAlerts = true;
    _appInstallBlocking = true;
    _notificationsEnabled = true;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        const SizedBox(height: 8),
        const Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),

        // SECURITY SECTION
        _buildSectionHeader('Security & Control'),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SwitchListTile(
            title: const Text('Enable Parental Lock'),
            subtitle: const Text('Lock device remotely'),
            value: _parentalLock,
            onChanged: (v) {
              setState(() => _parentalLock = v);
              widget.onParentalLockChanged(v);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(v ? 'Parental lock enabled' : 'Parental lock disabled')),
              );
            },
            secondary: const Icon(Icons.lock_outline),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SwitchListTile(
            title: const Text('App Installation Blocking'),
            subtitle: const Text('Prevent new app installations'),
            value: _appInstallBlocking,
            onChanged: (v) => setState(() => _appInstallBlocking = v),
            secondary: const Icon(Icons.block),
          ),
        ),
        const SizedBox(height: 12),

        // PROFILE MANAGEMENT
        _buildSectionHeader('Profiles'),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Manage Profiles'),
            subtitle: Text('Current: ${_selectedProfile ?? 'None'}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showProfileDialog(),
          ),
        ),
        const SizedBox(height: 12),

        // SECURITY & PIN
        _buildSectionHeader('Security & PIN'),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security & PIN'),
            subtitle: Text(widget.pinSet ? 'PIN is set' : 'No PIN set'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPinDialog(),
          ),
        ),
        const SizedBox(height: 12),

        // NOTIFICATIONS
        _buildSectionHeader('Notifications & Alerts'),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SwitchListTile(
            title: const Text('Screen Time Alerts'),
            subtitle: const Text('Alert when limit approaching'),
            value: _screenTimeAlerts,
            onChanged: (v) => setState(() => _screenTimeAlerts = v),
            secondary: const Icon(Icons.notifications),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SwitchListTile(
            title: const Text('General Notifications'),
            subtitle: const Text('Enable push notifications'),
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
            secondary: const Icon(Icons.notifications_active),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black54),
      ),
    );
  }

  void _showProfileDialog() {
    final profiles = ['Child 1', 'Child 2', 'Teenager', 'Admin'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: profiles
              .map((p) => ListTile(
                    title: Text(p),
                    leading: _selectedProfile == p
                        ? const Icon(Icons.check_circle, color: Colors.blue)
                        : const Icon(Icons.circle_outlined),
                    onTap: () {
                      setState(() => _selectedProfile = p);
                      widget.onProfileChanged(p);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Profile changed to $p')));
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showPinDialog() {
    final pinController = TextEditingController(text: widget.pinCode);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set PIN'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Enter 4-digit PIN'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (pinController.text.length == 4) {
                widget.onPinChanged(pinController.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN updated')));
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('PIN must be 4 digits')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
