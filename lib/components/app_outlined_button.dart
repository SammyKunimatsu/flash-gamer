import 'package:flutter/material.dart';
class AppOutlinedButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;
  final Color borderColor;
  final Color textColor;
  final double borderWidth;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  const AppOutlinedButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.height = 52,
    this.borderRadius = 14,
    this.borderColor = const Color(0xFF7C3AED),
    this.textColor = const Color(0xFFB78AF7),
    this.borderWidth = 1.5,
    this.fontSize = 15,
    this.fontWeight = FontWeight.w700,
    this.letterSpacing = 1.5,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor.withAlpha(120),
          width: borderWidth,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: textColor,
                letterSpacing: letterSpacing,
              ),
            ),
          ],
        ),
      ),
    );
  }
}