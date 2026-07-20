import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'result.dart';

class DiaTrackScreen extends StatefulWidget {
  const DiaTrackScreen({super.key});

  @override
  State<DiaTrackScreen> createState() => _DiaTrackScreenState();
}

class _DiaTrackScreenState extends State<DiaTrackScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _pulseRateController = TextEditingController();
  final TextEditingController _systolicBPController = TextEditingController();
  final TextEditingController _diastolicBPController = TextEditingController();
  final TextEditingController _glucoseLevelController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String? _gender = 'Male';
  bool _hasFamilyDiabetes = false;
  bool _hasHypertension = false;
  bool _hasFamilyHypertensive = false;
  bool _hasStroke = false;
  bool _hasCardiovascularDisease = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _ageController.dispose();
    _pulseRateController.dispose();
    _systolicBPController.dispose();
    _diastolicBPController.dispose();
    _glucoseLevelController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        double heightCm = double.parse(_heightController.text);
        double heightM = heightCm / 100.0;
        double weightKg = double.parse(_weightController.text);
        double bmi = weightKg / (heightM * heightM);

        Map<String, dynamic> data = {
          'age': double.parse(_ageController.text),
          'gender': _gender == 'Male' ? 1 : (_gender == 'Female' ? 0 : 2),
          'pulse_rate': double.parse(_pulseRateController.text),
          'systolic_bp': double.parse(_systolicBPController.text),
          'diastolic_bp': double.parse(_diastolicBPController.text),
          'glucose': double.parse(_glucoseLevelController.text),
          'height': heightCm,
          'weight': weightKg,
          'bmi': bmi,
          'family_diabetes': _hasFamilyDiabetes ? 1 : 0,
          'hypertensive': _hasHypertension ? 1 : 0,
          'family_hypertension': _hasFamilyHypertensive ? 1 : 0,
          'cardiovascular_disease': _hasCardiovascularDisease ? 1 : 0,
          'stroke': _hasStroke ? 1 : 0,
        };

        double risk = await ApiService().predictDiabetes(data);

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(riskLevel: risk),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'DiaTrack',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF1565C0), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Fill in your health data below to get an AI-powered diabetes risk assessment.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Section: Personal Info ---
            _buildSectionHeader(Icons.person_outline, 'Personal Information'),
            const SizedBox(height: 12),
            _buildCard([
              _buildFormField(_ageController, 'Age', 'Enter your age', 'Please enter your age'),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: _inputDecoration('Gender'),
                items: ['Male', 'Female', 'Other'].map((gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
            ]),
            const SizedBox(height: 20),

            // --- Section: Vitals ---
            _buildSectionHeader(Icons.favorite_outline, 'Vital Signs'),
            const SizedBox(height: 12),
            _buildCard([
              _buildFormField(_pulseRateController, 'Pulse Rate (bpm)', 'e.g. 72', 'Please enter pulse rate'),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(_systolicBPController, 'Systolic BP', 'e.g. 120', 'Required'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFormField(_diastolicBPController, 'Diastolic BP', 'e.g. 80', 'Required'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildFormField(_glucoseLevelController, 'Glucose Level (mg/dL)', 'e.g. 100', 'Please enter glucose level'),
            ]),
            const SizedBox(height: 20),

            // --- Section: Body Measurements ---
            _buildSectionHeader(Icons.straighten_outlined, 'Body Measurements'),
            const SizedBox(height: 12),
            _buildCard([
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(_heightController, 'Height (cm)', 'e.g. 170', 'Required'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFormField(_weightController, 'Weight (kg)', 'e.g. 70', 'Required'),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 20),

            // --- Section: Medical History ---
            _buildSectionHeader(Icons.medical_information_outlined, 'Medical History'),
            const SizedBox(height: 12),
            _buildCard([
              _buildSwitchTile('Family has Diabetes', _hasFamilyDiabetes, (v) => setState(() => _hasFamilyDiabetes = v)),
              _buildSwitchTile('Hypertensive', _hasHypertension, (v) => setState(() => _hasHypertension = v)),
              _buildSwitchTile('Family has Hypertension', _hasFamilyHypertensive, (v) => setState(() => _hasFamilyHypertensive = v)),
              _buildSwitchTile('Cardiovascular Disease', _hasCardiovascularDisease, (v) => setState(() => _hasCardiovascularDisease = v)),
              _buildSwitchTile('History of Stroke', _hasStroke, (v) => setState(() => _hasStroke = v)),
            ]),
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.analytics_outlined),
                          SizedBox(width: 8),
                          Text(
                            'Predict Risk',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1565C0)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _buildFormField(
    TextEditingController controller,
    String label,
    String hint,
    String errorMsg,
  ) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label).copyWith(hintText: hint, hintStyle: TextStyle(color: Colors.grey[400])),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorMsg;
        }
        return null;
      },
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontSize: 14)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1565C0),
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }
}
