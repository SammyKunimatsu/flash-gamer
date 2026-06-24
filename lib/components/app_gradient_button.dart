import 'package:flutter/material.dart';
class AppGradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double borderRadius;
  final List<Color> gradientColors;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final EdgeInsetsGeometry? padding;
  const AppGradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.height = 52,
    this.borderRadius = 14,
    this.gradientColors = const [Color(0xFF7C3AED), Color(0xFF9333EA)],
    this.fontSize = 15,
    this.fontWeight = FontWeight.w700,
    this.letterSpacing = 1.5,
    this.padding,
  });
  factory AppGradientButton.pill({
    Key? key,
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool isLoading = false,
    List<Color> gradientColors = const [Color(0xFF7C3AED), Color(0xFF9333EA)],
  }) {
    return AppGradientButton(
      key: key,
      label: label,
      icon: icon,
      onPressed: onPressed,
      isLoading: isLoading,
      borderRadius: 30,
      gradientColors: gradientColors,
      fontWeight: FontWeight.w800,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    );
  }
  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;
    final colors = isDisabled && !isLoading
        ? [Colors.grey.shade400, Colors.grey.shade500]
        : gradientColors;
    return Container(
      height: padding != null ? null : height,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(colors: colors),
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: gradientColors.first.withAlpha(80),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: padding != null
          ? GestureDetector(
              onTap: isDisabled ? null : onPressed,
              child: _buildContent(isDisabled),
            )
          : ElevatedButton(
              onPressed: isDisabled ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: _buildContent(isDisabled),
            ),
    );
  }
  Widget _buildContent(bool isDisabled) {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: padding != null ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: Colors.white,
            letterSpacing: letterSpacing,
          ),
        ),
      ],
    );
  }
}