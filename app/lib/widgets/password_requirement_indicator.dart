import 'package:flutter/material.dart';
import '../theme/agrovia_theme.dart';

class PasswordRequirementIndicator extends StatelessWidget {
  final String password;

  const PasswordRequirementIndicator({
    super.key,
    required this.password,
  });

  bool get hasMinLength => password.length >= 8;
  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasSpecialChar => password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]'));

  bool get isValid => hasMinLength && hasUppercase && hasNumber && hasSpecialChar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequirementRow('At least 8 characters', hasMinLength),
        const SizedBox(height: 4),
        _buildRequirementRow('At least 1 uppercase letter (A-Z)', hasUppercase),
        const SizedBox(height: 4),
        _buildRequirementRow('At least 1 number (0-9)', hasNumber),
        const SizedBox(height: 4),
        _buildRequirementRow('At least 1 special character (!@#\$%...)', hasSpecialChar),
      ],
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    final color = isMet ? AgroviaColors.accentGreen : AgroviaColors.accentDanger;
    final icon = isMet ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
