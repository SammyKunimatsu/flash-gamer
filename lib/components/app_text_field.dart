import 'package:flutter/material.dart';
class AppTextField extends StatelessWidget {
  final String? label;
  final String hint;
  final IconData? icon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final double borderRadius;
  final bool isDarkTheme;
  const AppTextField({
    super.key,
    this.label,
    required this.hint,
    this.icon,
    this.suffixIcon,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.borderRadius = 14,
    this.isDarkTheme = true,
  });
  @override
  Widget build(BuildContext context) {
    final textColor = isDarkTheme ? Colors.white : Colors.black87;
    final hintColor = isDarkTheme ? Colors.white.withAlpha(70) : Colors.grey.shade400;
    final iconColor = isDarkTheme ? Colors.white.withAlpha(120) : Colors.grey.shade500;
    final fillColor = isDarkTheme ? Colors.white.withAlpha(13) : Colors.grey.shade100;
    final borderColor = isDarkTheme ? Colors.white.withAlpha(25) : Colors.grey.shade300;
    final labelColor = isDarkTheme ? Colors.white.withAlpha(180) : Colors.grey.shade700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: labelColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(color: textColor, fontSize: 15),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: hintColor, fontSize: 14),
            prefixIcon: icon != null
                ? Icon(icon, color: iconColor, size: 20)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: fillColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide:
                  const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide:
                  BorderSide(color: Colors.red.shade300, width: 1.5),
            ),
            errorStyle: TextStyle(color: Colors.red.shade300, fontSize: 12),
          ),
        ),
      ],
    );
  }
}