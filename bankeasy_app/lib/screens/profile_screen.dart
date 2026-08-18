import 'package:flutter/material.dart';
import '../data/profile_store.dart';
import '../models/profile.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Profile _profile = Profile();
  bool _loaded = false;

  final _fields = const [
    ('fullName', 'Full name'),
    ('cnic', 'CNIC'),
    ('phone', 'Phone number'),
    ('designation', 'Designation'),
    ('grade', 'Grade / scale'),
    ('homeBranch', 'Home branch'),
    ('preferredBank', 'Preferred bank'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ProfileStore.load();
    setState(() {
      _profile = p;
      _loaded = true;
    });
  }

  String? _getValue(String key) {
    switch (key) {
      case 'fullName': return _profile.fullName;
      case 'cnic': return _profile.cnic;
      case 'phone': return _profile.phone;
      case 'designation': return _profile.designation;
      case 'grade': return _profile.grade;
      case 'homeBranch': return _profile.homeBranch;
      case 'preferredBank': return _profile.preferredBank;
    }
    return null;
  }

  void _setValue(String key, String value) {
    switch (key) {
      case 'fullName': _profile.fullName = value; break;
      case 'cnic': _profile.cnic = value; break;
      case 'phone': _profile.phone = value; break;
      case 'designation': _profile.designation = value; break;
      case 'grade': _profile.grade = value; break;
      case 'homeBranch': _profile.homeBranch = value; break;
      case 'preferredBank': _profile.preferredBank = value; break;
    }
  }

  Future<void> _editField(String key, String label) async {
    final controller = TextEditingController(text: _getValue(key) ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Save')),
        ],
      ),
    );
    if (result != null) {
      setState(() => _setValue(key, result));
      await ProfileStore.save(_profile);
    }
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear profile data?'),
        content: const Text(
          'This permanently removes everything saved on this device. '
          'There is no backup to restore from unless you\'ve exported it yourself.',
          style: TextStyle(fontSize: 12.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear permanently'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ProfileStore.clear();
      setState(() => _profile = Profile());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Your profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Profile completeness',
                        style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
                    Text('${_profile.filledFieldCount} / ${_profile.totalFieldCount} fields',
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.navy, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: _profile.totalFieldCount == 0
                        ? 0
                        : _profile.filledFieldCount / _profile.totalFieldCount,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE4E0D2),
                    valueColor: const AlwaysStoppedAnimation(AppColors.navy),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Personal & employment details',
              style: TextStyle(fontSize: 11.5, color: AppColors.muted, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _fields.length; i++)
                  Column(
                    children: [
                      ListTile(
                        dense: true,
                        title: Text(_fields[i].$2, style: const TextStyle(fontSize: 12.5)),
                        trailing: Text(
                          _getValue(_fields[i].$1)?.isNotEmpty == true
                              ? _getValue(_fields[i].$1)!
                              : 'Not set',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: _getValue(_fields[i].$1)?.isNotEmpty == true
                                ? AppColors.navy
                                : const Color(0xFFC99A2E),
                          ),
                        ),
                        onTap: () => _editField(_fields[i].$1, _fields[i].$2),
                      ),
                      if (i != _fields.length - 1)
                        const Divider(height: 1, color: Color(0xFFEDEAE0)),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Data and privacy',
              style: TextStyle(fontSize: 11.5, color: AppColors.muted, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  dense: true,
                  activeTrackColor: AppColors.navy,
                  title: const Text('Auto-fill forms from profile',
                      style: TextStyle(fontSize: 12.5)),
                  subtitle: const Text('Turn off to fill every form manually',
                      style: TextStyle(fontSize: 10)),
                  value: _profile.autofillEnabled,
                  onChanged: (v) async {
                    setState(() => _profile.autofillEnabled = v);
                    await ProfileStore.save(_profile);
                  },
                ),
                const Divider(height: 1, color: Color(0xFFEDEAE0)),
                ListTile(
                  dense: true,
                  title: const Text('Clear profile data',
                      style: TextStyle(fontSize: 12.5, color: AppColors.danger)),
                  trailing: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                  onTap: _confirmClear,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.goldTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, size: 14, color: AppColors.goldTintText),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Nothing here is uploaded. Clearing it removes it from this '
                    'device for good — there\'s no backup unless you export it yourself.',
                    style: TextStyle(fontSize: 10, color: AppColors.goldTintText, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
