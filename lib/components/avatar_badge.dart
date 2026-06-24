import 'package:flutter/material.dart';
class AvatarBadge extends StatelessWidget {
  final int? level;
  final double size;
  final Widget? child;
  final List<Color> borderGradient;
  final Color innerColor;
  final Color badgeColor;
  final double borderWidth;
  const AvatarBadge({
    super.key,
    this.level,
    this.size = 120,
    this.child,
    this.borderGradient = const [Color(0xFF7C3AED), Color(0xFFDB2777)],
    this.innerColor = const Color(0xFF3B1564),
    this.badgeColor = const Color(0xFFF59E0B),
    this.borderWidth = 4,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: borderGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: borderGradient.first.withAlpha(60),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: EdgeInsets.all(borderWidth),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: innerColor,
            ),
            child: child ??
                Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: size * 0.5,
                ),
          ),
        ),
        if (level != null)
          Positioned(
            bottom: -8,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withAlpha(80),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    'Nvl $level',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}