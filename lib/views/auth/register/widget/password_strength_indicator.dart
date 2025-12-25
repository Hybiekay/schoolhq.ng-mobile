import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final strength = _calculatePasswordStrength(password);
    final strengthText = _getStrengthText(strength);
    final color = _getStrengthColor(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password Strength: $strengthText',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: strength / 100,
          backgroundColor: Colors.grey.shade200,
          color: color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  double _calculatePasswordStrength(String password) {
    double strength = 0;

    // Length check
    if (password.length >= 8) strength += 25;
    if (password.length >= 12) strength += 15;

    // Character variety
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 20;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 20;
    if (RegExp(r'\d').hasMatch(password)) strength += 20;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 20;

    return strength.clamp(0, 100).toDouble();
  }

  String _getStrengthText(double strength) {
    if (strength < 40) return 'Weak';
    if (strength < 70) return 'Fair';
    if (strength < 90) return 'Good';
    return 'Strong';
  }

  Color _getStrengthColor(double strength) {
    if (strength < 40) return Colors.red;
    if (strength < 70) return Colors.orange;
    if (strength < 90) return Colors.blue;
    return Colors.green;
  }
}
