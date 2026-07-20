import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  Map<String, dynamic>? profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final data = await apiService.getProfile();
      setState(() {
        profileData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  void _showEditDialog() {
    final nameCtrl = TextEditingController(text: profileData?['name'] ?? '');
    final dobCtrl = TextEditingController(text: profileData?['dob'] ?? '');
    final phoneCtrl = TextEditingController(text: profileData?['phone'] ?? '');
    final addrCtrl = TextEditingController(text: profileData?['address'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Profile'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                    TextField(controller: dobCtrl, decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)')),
                    TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
                    TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Address')),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    setDialogState(() => isSaving = true);
                    try {
                      final api = Provider.of<ApiService>(context, listen: false);
                      await api.updateProfile({
                        'name': nameCtrl.text,
                        'dob': dobCtrl.text,
                        'phone': phoneCtrl.text,
                        'address': addrCtrl.text,
                      });
                      if (context.mounted) Navigator.pop(context);
                      _fetchProfile(); // Refresh
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    } finally {
                      if (context.mounted) setDialogState(() => isSaving = false);
                    }
                  },
                  child: isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final name = profileData?['name'] ?? 'Unknown User';
    final email = profileData?['email'] ?? 'Unknown Email';
    final dob = profileData?['dob'] ?? 'Not set';
    final phone = profileData?['phone'] ?? 'Not set';
    final address = profileData?['address'] ?? 'Not set';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              color: Colors.white,
              child: Column(
                children: [
                  const CircleAvatar(radius: 50, backgroundImage: AssetImage('images/profile.png')),
                  const SizedBox(height: 14),
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(email, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personal Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Card(
                    child: Column(
                      children: [
                        ListTile(leading: const Icon(Icons.cake_outlined, color: Color(0xFF1565C0)), title: const Text('Date of Birth'), subtitle: Text(dob)),
                        const Divider(height: 1),
                        ListTile(leading: const Icon(Icons.phone_outlined, color: Color(0xFF1565C0)), title: const Text('Phone Number'), subtitle: Text(phone)),
                        const Divider(height: 1),
                        ListTile(leading: const Icon(Icons.location_on_outlined, color: Color(0xFF1565C0)), title: const Text('Address'), subtitle: Text(address)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _showEditDialog,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final apiService = Provider.of<ApiService>(context, listen: false);
                        await apiService.logout();
                        if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
                      },
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Log Out'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red[600]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
