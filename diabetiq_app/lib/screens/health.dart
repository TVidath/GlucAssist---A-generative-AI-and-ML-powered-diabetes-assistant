import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  List<dynamic> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final records = await api.getHealthRecords();
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading health records: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteRecord(int id) async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      await api.deleteHealthRecord(id);
      _fetchRecords();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Record deleted')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Health History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _records.isEmpty 
          ? const Center(child: Text('No health records found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final date = DateTime.parse(record['created_at']).toLocal().toString().split('.')[0];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Record: $date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteRecord(record['id']),
                            ),
                          ],
                        ),
                        const Divider(),
                        _buildStatRow('BMI', '${record['bmi']}', Icons.calculate, Colors.blue),
                        _buildStatRow('Glucose', '${record['glucose']}', Icons.water_drop, Colors.pink),
                        _buildStatRow('Blood Pressure', '${record['systolic_bp']}/${record['diastolic_bp']}', Icons.bloodtype, Colors.red),
                        _buildStatRow('Risk Level', '${(record['risk_level'] * 100).toStringAsFixed(1)}%', Icons.warning_amber, Colors.orange),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatRow(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
