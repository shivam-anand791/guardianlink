// lib/widgets/apps_screen.dart
import 'package:flutter/material.dart';

class AppsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> installedApps;
  final Function(int, bool) onAppStatusChanged;
  final Function(int, int) onTimeLimitChanged;

  const AppsScreen({
    super.key,
    required this.installedApps,
    required this.onAppStatusChanged,
    required this.onTimeLimitChanged,
  });

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  late List<Map<String, dynamic>> _apps;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _apps = List.from(widget.installedApps);
  }

  @override
  Widget build(BuildContext context) {
    final filteredApps = _filterApps();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        const SizedBox(height: 8),
        const Text('App Control', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),

        // STATS CARDS
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Total Apps',
                value: _apps.length.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'Blocked',
                value: _apps.where((a) => a['blocked']).length.toString(),
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'Allowed',
                value: _apps.where((a) => !a['blocked']).length.toString(),
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // FILTER TABS
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['All', 'Allowed', 'Blocked'].map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedFilter = filter);
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // APPS LIST
        ...filteredApps.asMap().entries.map((entry) {
          final idx = entry.key;
          final app = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildAppCard(app, idx),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatCard({required String label, required String value, required Color color}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppCard(Map<String, dynamic> app, int index) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: app['blocked'] ? Colors.red.shade100 : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.app_shortcut,
                    color: app['blocked'] ? Colors.red : Colors.blue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app['name'],
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      Text(
                        app['category'],
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _apps[index]['blocked'] = !_apps[index]['blocked'];
                    });
                    widget.onAppStatusChanged(index, _apps[index]['blocked']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _apps[index]['blocked'] ? '${app['name']} blocked' : '${app['name']} unblocked',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: app['blocked'] ? Colors.red.shade100 : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      app['blocked'] ? 'BLOCKED' : 'ALLOWED',
                      style: TextStyle(
                        color: app['blocked'] ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.black54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Daily limit: ${app['timeLimit']} min',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
                TextButton(
                  onPressed: () => _showTimeLimitDialog(app, index),
                  child: const Text('Edit', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filterApps() {
    switch (_selectedFilter) {
      case 'Allowed':
        return _apps.where((a) => !a['blocked']).toList();
      case 'Blocked':
        return _apps.where((a) => a['blocked']).toList();
      default:
        return _apps;
    }
  }

  void _showTimeLimitDialog(Map<String, dynamic> app, int index) {
    final controller = TextEditingController(text: app['timeLimit'].toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set Time Limit for ${app['name']}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter time limit in minutes',
            suffix: Text('min'),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final newLimit = int.tryParse(controller.text) ?? app['timeLimit'];
                setState(() {
                  _apps[index]['timeLimit'] = newLimit;
                });
                widget.onTimeLimitChanged(index, newLimit);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Time limit set to $newLimit minutes')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
