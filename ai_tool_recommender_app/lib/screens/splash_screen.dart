import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../services/local_search_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _particleCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _particleCtrl = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack),
    );
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _logoCtrl,
          curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
    );
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fadeCtrl.forward();
    });

    _initApp();
  }

  Future<void> _initApp() async {
    final auth = context.read<AuthProvider>();
    final localSearch = LocalSearchService();

    await Future.wait([
      localSearch.init(), // preload the bundled dataset
      auth.tryAutoLogin(),
      Future.delayed(const Duration(milliseconds: 2500)),
    ]);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, a1, a2) => const HomeScreen(),
          transitionsBuilder: (_, anim, a3, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) {
              final t = _particleCtrl.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      sin(t * pi * 2) * 0.3,
                      -0.3 + cos(t * pi * 2) * 0.15,
                    ),
                    radius: 1.4,
                    colors: [
                      AppColors.cyan.withValues(alpha: 0.08),
                      AppColors.purple.withValues(alpha: 0.04),
                      AppColors.bgDark,
                      AppColors.bgDark,
                    ],
                    stops: const [0, 0.25, 0.55, 1],
                  ),
                ),
              );
            },
          ),

          // Floating particles
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) => CustomPaint(
              painter: _ParticlePainter(
                progress: _particleCtrl.value,
                color1: AppColors.cyan,
                color2: AppColors.purple,
                color3: AppColors.pink,
              ),
              size: MediaQuery.of(context).size,
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pulsing glow behind logo
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, child) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.12 * _pulse.value),
                          blurRadius: 60 + (_pulse.value * 20),
                          spreadRadius: 10 + (_pulse.value * 8),
                        ),
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.08 * _pulse.value),
                          blurRadius: 80 + (_pulse.value * 30),
                          spreadRadius: 20 + (_pulse.value * 10),
                        ),
                      ],
                    ),
                    child: child,
                  ),
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyan.withValues(alpha: 0.3),
                              blurRadius: 32,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _textFade,
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.brandGradient.createShader(bounds),
                    child: const Text(
                      'ToolFinder AI',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeTransition(
                  opacity: _textFade,
                  child: const Text(
                    'Intelligent AI Tool Discovery',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 44),
                FadeTransition(
                  opacity: _textFade,
                  child: _buildLoadingIndicator(),
                ),
              ],
            ),
          ),

          // Bottom version label
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textFade,
              child: const Text(
                'v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.15;
            final value = sin((_pulseCtrl.value + delay) * pi * 2)
                .clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(
                  AppColors.cyan.withValues(alpha: 0.3),
                  AppColors.cyan,
                  value,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Particle Painter ──

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color1;
  final Color color2;
  final Color color3;

  _ParticlePainter({
    required this.progress,
    required this.color1,
    required this.color2,
    required this.color3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final colors = [color1, color2, color3];

    for (int i = 0; i < 20; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.3 + random.nextDouble() * 0.7;
      final offset = random.nextDouble() * pi * 2;
      final radius = 1.5 + random.nextDouble() * 2.5;

      final x = baseX + sin((progress * speed + offset) * pi * 2) * 20;
      final y = baseY + cos((progress * speed + offset) * pi * 2) * 15;
      final alpha = (0.15 + sin((progress + offset) * pi * 2) * 0.1)
          .clamp(0.05, 0.3);

      final paint = Paint()
        ..color = colors[i % 3].withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress;
}
