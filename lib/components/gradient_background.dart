import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final List<double>? stops;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    super.key,
    required this.child,
    required this.colors,
    this.stops,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  factory GradientBackground.darkPurple({Key? key, required Widget child}) {
    return GradientBackground(
      key: key,
      colors: const [
        Color(0xFF1A0533),
        Color(0xFF2D1B69),
        Color(0xFF4A1A8A),
        Color(0xFF1A0533),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
      child: child,
    );
  }

  factory GradientBackground.lightPurple({Key? key, required Widget child}) {
    return GradientBackground(
      key: key,
      colors: const [Color(0xFFF5F0FF), Color(0xFFF5F0FF)],
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
          stops: stops,
        ),
      ),
      child: child,
    );
  }
}
