import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flashgamer/components/components.dart';
class InitialPage extends StatefulWidget {
  const InitialPage({super.key});
  @override
  State<InitialPage> createState() => _InitialPageState();
}
class _InitialPageState extends State<InitialPage>
    with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late AnimationController _entranceCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeIn = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));
    _entranceCtrl.forward();
  }
  @override
  void dispose() {
    _floatCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFF5F0FF),
          ),
          FloatingShape(
            animation: _floatCtrl,
            top: 30,
            left: 20,
            size: 40,
            color: const Color(0xFFFDE68A),
            shape: BoxShape.circle,
          ),
          FloatingShape(
            animation: _floatCtrl,
            bottom: 40,
            right: 20,
            size: 45,
            color: const Color(0xFF93C5FD),
            shape: BoxShape.rectangle,
          ),
          FloatingShape.fractional(
            animation: _floatCtrl,
            topFrac: 0.25,
            rightFrac: 0.15,
            size: 50,
            color: const Color(0xFFE9D5FF),
            rotationAngle: 0.3,
          ),
          FloatingShape.fractional(
            animation: _floatCtrl,
            bottomFrac: 0.35,
            leftFrac: 0.2,
            size: 16,
            color: const Color(0xFFFCA5A5),
            shape: BoxShape.circle,
            phaseOffset: 0.6,
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _floatCtrl,
                      builder: (ctx, child) => Transform.translate(
                        offset:
                            Offset(0, -sin(_floatCtrl.value * pi) * 8),
                        child: child,
                      ),
                      child: const AvatarBadge(level: 12, size: 120),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Bem-vindo\nde volta, Herói!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF6B21A8),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sua jornada épica de\naprendizado aguarda. Pronto\npara a próxima fase?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppGradientButton.pill(
                      label: 'COMEÇAR MISSÃO',
                      icon: Icons.rocket_launch_rounded,
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}