// lib/widgets/tools_screen.dart
import 'package:flutter/material.dart';

class ToolsScreen extends StatefulWidget {
  final Map<String, dynamic> systemInfo;

  const ToolsScreen({super.key, required this.systemInfo});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  late List<Map<String, dynamic>> _websites;
  late List<Map<String, dynamic>> _downtime;

  @override
  void initState() {
    super.initState();
    _websites = [
      {'domain': 'tiktok.com', 'category': 'Social', 'allowed': false},
      {'domain': 'instagram.com', 'category': 'Social', 'allowed': true},
      {'domain': 'youtube.com', 'category': 'Streaming', 'allowed': true},
      {'domain': 'roblox.com', 'category': 'Gaming', 'allowed': false},
    ];
    _downtime = [
      {'name': 'School Hours', 'start': '09:00', 'end': '15:00', 'days': 'Mon-Fri', 'enabled': true},
      {'name': 'Bedtime', 'start': '22:00', 'end': '08:00', 'days': 'Daily', 'enabled': true},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Tools & Controls',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.language), text: 'Websites'),
              Tab(icon: Icon(Icons.schedule), text: 'Downtime'),
              Tab(icon: Icon(Icons.computer), text: 'System'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildWebsitesTab(),
            _buildDowntimeTab(),
            _buildSystemTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildWebsitesTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        const SizedBox(height: 8),
        Card(
          color: Colors.blue.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Block or allow websites by domain',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._websites.map((site) {
          final idx = _websites.indexOf(site);
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: site['allowed'] ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.language,
                  color: site['allowed'] ? Colors.green : Colors.red,
                ),
              ),
              title: Text(site['domain'], style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(site['category']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: site['allowed'],
                    onChanged: (v) {
                      setState(() => _websites[idx]['allowed'] = v);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            v ? '${site['domain']} allowed' : '${site['domain']} blocked',
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete website',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Website'),
                          content: Text('Delete ${site['domain']} from the list?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (!mounted) return;
                      if (confirmed == true) {
                        setState(() => _websites.removeAt(idx));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${site['domain']} removed')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => _showAddWebsiteDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Add Website'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDowntimeTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        const SizedBox(height: 8),
        Card(
          color: Colors.purple.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.bedtime, color: Colors.purple.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Set scheduled downtime when device locks automatically',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._downtime.map((schedule) {
          final idx = _downtime.indexOf(schedule);
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule['name'],
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${schedule['start']} - ${schedule['end']} (${schedule['days']})',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                      Switch(
                        value: schedule['enabled'],
                        onChanged: (v) {
                          setState(() => _downtime[idx]['enabled'] = v);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Edit schedule'))),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _downtime.removeAt(idx));
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text('Schedule deleted')));
                        },
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Add new downtime schedule'))),
          icon: const Icon(Icons.add),
          label: const Text('Add Schedule'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSystemTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        const SizedBox(height: 12),
        _buildSystemInfoCard(
          icon: Icons.phone_android,
          title: 'Device Information',
          children: [
            _buildSystemInfoRow('Device', widget.systemInfo['deviceName']),
            _buildSystemInfoRow('OS', widget.systemInfo['osVersion']),
          ],
        ),
        const SizedBox(height: 12),
        _buildSystemInfoCard(
          icon: Icons.battery_full,
          title: 'Battery & Storage',
          children: [
            _buildSystemInfoRow('Battery', '${widget.systemInfo['batteryLevel']}%'),
            _buildSystemInfoRow('Storage', widget.systemInfo['storageUsed']),
          ],
        ),
        const SizedBox(height: 12),
        _buildSystemInfoCard(
          icon: Icons.wifi,
          title: 'Network',
          children: [
            _buildSystemInfoRow('WiFi Status', widget.systemInfo['wifiStatus']),
            _buildSystemInfoRow('Network', widget.systemInfo['wifiName']),
          ],
        ),
        const SizedBox(height: 12),
        _buildSystemInfoCard(
          icon: Icons.location_on,
          title: 'Location',
          children: [
            _buildSystemInfoRow('Latitude', widget.systemInfo['latitude']),
            _buildSystemInfoRow('Longitude', widget.systemInfo['longitude']),
            _buildSystemInfoRow('Accuracy', widget.systemInfo['accuracy']),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSystemInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSystemInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Text(value ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  void _showAddWebsiteDialog() {
    final domainController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        String selectedCategory = 'Social';
        return StatefulBuilder(builder: (ctx2, setStateDialog) {
          return AlertDialog(
            title: const Text('Add Website'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: domainController,
                  decoration: const InputDecoration(hintText: 'Enter domain (e.g., example.com)'),
                ),
                const SizedBox(height: 12),
                DropdownButton<String>(
                  value: selectedCategory,
                  items: ['Social', 'Gaming', 'Streaming', 'Education', 'Other']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setStateDialog(() => selectedCategory = v);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(ctx);
                domainController.dispose();
              }, child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  final domain = domainController.text.trim();
                  if (domain.isEmpty) return;
                  // prevent duplicates
                  final already = _websites.any((w) => (w['domain'] as String).toLowerCase() == domain.toLowerCase());
                  if (already) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$domain is already in the list')),
                    );
                    return;
                  }
                  setState(() {
                    _websites.add({
                      'domain': domain,
                      'category': selectedCategory,
                      'allowed': true,
                    });
                  });
                  Navigator.pop(ctx);
                  domainController.dispose();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$domain added')),
                  );
                },
                child: const Text('Add'),
              ),
            ],
          );
        });
      },
    );
  }
}
