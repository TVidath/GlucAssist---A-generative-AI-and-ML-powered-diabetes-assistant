import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final double riskLevel;

  const ResultPage({super.key, required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    final riskPercent = (riskLevel * 100).clamp(0, 100).toInt();
    final riskColor = _getRiskColor();
    final riskStage = _getRiskStage();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Your Result',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Risk Score Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'images/blood.png',
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Diabetes Risk Assessment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Big percentage display
                    Text(
                      '$riskPercent%',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        riskStage,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: riskColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Risk Meter Bar
                    _buildRiskMeter(),
                    const SizedBox(height: 20),
                    // Risk Description
                    Text(
                      _getRiskText(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Next Steps Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Color(0xFF1565C0)),
                        SizedBox(width: 8),
                        Text(
                          'Recommended Next Steps',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStepItem(
                      Icons.local_hospital_outlined,
                      'Discuss your risk level with a medical professional.',
                    ),
                    _buildStepItem(
                      Icons.people_outline,
                      'Your doctor can provide personalized resources.',
                    ),
                    _buildStepItem(
                      Icons.info_outline,
                      'This result is not a medical diagnosis.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Go Home Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  },
                  icon: const Icon(Icons.home_outlined),
                  label: const Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskMeter() {
    return Column(
      children: [
        // Meter bar with indicator
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Background bar
            Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4CAF50), // Green
                    Color(0xFFFFC107), // Yellow
                    Color(0xFFFF9800), // Orange
                    Color(0xFFF44336), // Red
                  ],
                ),
              ),
            ),
            // Indicator arrow
            Positioned(
              left: (riskLevel.clamp(0.0, 1.0)) * (1.0 - 0.05) * 300, // approximate positioning
              top: -6,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: _getRiskColor(), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Low', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            Text('Moderate', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            Text('High', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }

  Color _getRiskColor() {
    if (riskLevel < 0.33) {
      return const Color(0xFF4CAF50); // Green
    } else if (riskLevel < 0.66) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFFF44336); // Red
    }
  }

  String _getRiskStage() {
    if (riskLevel < 0.33) {
      return 'Low Risk';
    } else if (riskLevel < 0.66) {
      return 'Moderate Risk';
    } else {
      return 'High Risk';
    }
  }

  String _getRiskText() {
    if (riskLevel < 0.33) {
      return 'Your health data indicates a low risk of diabetes. Continue maintaining a healthy lifestyle with regular exercise and a balanced diet.';
    } else if (riskLevel < 0.66) {
      return 'Your health data suggests a moderate risk of diabetes. Consider consulting a healthcare professional for a thorough evaluation.';
    } else {
      return 'Your health data indicates a high risk of diabetes. We strongly recommend consulting a medical professional as soon as possible for a proper diagnosis.';
    }
  }
}
