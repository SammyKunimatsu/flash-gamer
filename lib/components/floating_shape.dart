import 'dart:math';
import 'package:flutter/material.dart';
class FloatingShape extends StatelessWidget {
  final Animation<double> animation;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final Color color;
  final BoxShape shape;
  final double borderRadius;
  final double rotationAngle;
  final double amplitude;
  final double phaseOffset;
  final int alpha;
  const FloatingShape({
    super.key,
    required this.animation,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.size = 40,
    required this.color,
    this.shape = BoxShape.circle,
    this.borderRadius = 10,
    this.rotationAngle = 0,
    this.amplitude = 10,
    this.phaseOffset = 0,
    this.alpha = 180,
  });
  factory FloatingShape.fractional({
    Key? key,
    required Animation<double> animation,
    double? topFrac,
    double? bottomFrac,
    double? leftFrac,
    double? rightFrac,
    double size = 40,
    required Color color,
    BoxShape shape = BoxShape.rectangle,
    double borderRadius = 14,
    double rotationAngle = 0,
    double amplitude = 12,
    double phaseOffset = 0.3,
    int alpha = 150,
  }) {
    return _FractionalFloatingShape(
      key: key,
      animation: animation,
      topFrac: topFrac,
      bottomFrac: bottomFrac,
      leftFrac: leftFrac,
      rightFrac: rightFrac,
      size: size,
      color: color,
      shape: shape,
      borderRadius: borderRadius,
      rotationAngle: rotationAngle,
      amplitude: amplitude,
      phaseOffset: phaseOffset,
      alpha: alpha,
    );
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (ctx, _) {
        final v = sin((animation.value + phaseOffset) * pi * 2) * amplitude;
        return Positioned(
          top: top != null ? top! + v : null,
          bottom: bottom != null ? bottom! + v : null,
          left: left,
          right: right,
          child: Transform.rotate(
            angle: rotationAngle,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: shape,
                borderRadius: shape == BoxShape.rectangle
                    ? BorderRadius.circular(borderRadius)
                    : null,
                color: color.withAlpha(alpha),
              ),
            ),
          ),
        );
      },
    );
  }
}
class _FractionalFloatingShape extends FloatingShape {
  final double? topFrac;
  final double? bottomFrac;
  final double? leftFrac;
  final double? rightFrac;
  const _FractionalFloatingShape({
    super.key,
    required super.animation,
    this.topFrac,
    this.bottomFrac,
    this.leftFrac,
    this.rightFrac,
    super.size,
    required super.color,
    super.shape,
    super.borderRadius,
    super.rotationAngle,
    super.amplitude,
    super.phaseOffset,
    super.alpha,
  });
  @override
  Widget build(BuildContext context) {
    final sz = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: animation,
      builder: (ctx, _) {
        final v =
            sin((animation.value + phaseOffset) * pi * 2) * amplitude;
        return Positioned(
          top: topFrac != null ? sz.height * topFrac! + v : null,
          bottom: bottomFrac != null ? sz.height * bottomFrac! + v : null,
          left: leftFrac != null ? sz.width * leftFrac! : null,
          right: rightFrac != null ? sz.width * rightFrac! : null,
          child: Transform.rotate(
            angle: rotationAngle,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: shape,
                borderRadius: shape == BoxShape.rectangle
                    ? BorderRadius.circular(borderRadius)
                    : null,
                color: color.withAlpha(alpha),
              ),
            ),
          ),
        );
      },
    );
  }
}