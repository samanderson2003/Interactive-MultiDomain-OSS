import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import '../controller/auth_controller.dart';
import '../../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    // Sparkle animation controller
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    // Glow pulse animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _initializeApp();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.checkAuthStatus();
  }

  void _handleGetStarted() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final isLoggedIn = authController.isLoggedIn;

    if (isLoggedIn) {
      final route = authController.getDashboardRoute();
      Navigator.of(context).pushReplacementNamed(route);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const double sizeFactor = 1.2;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fullscreen Lottie animation
            Positioned.fill(
              child: OverflowBox(
                alignment: Alignment.center,
                child: SizedBox(
                  width: screenWidth * sizeFactor,
                  height: screenHeight * sizeFactor,
                  child: Lottie.asset(
                    'assets/Hathora World Map.json',
                    fit: BoxFit.cover,
                    repeat: true,
                    animate: true,
                    alignment: Alignment.center,
                    frameRate: FrameRate.max,
                  ),
                ),
              ),
            ),

            // Animated sparkles overlay
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _sparkleController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: SparklePainter(_sparkleController.value),
                  );
                },
              ),
            ),

            // Radial gradient overlay for depth
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF000000).withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),

            // Content overlay
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Animated glow effect behind title
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(
                                0.3 + (_glowController.value * 0.3),
                              ),
                              blurRadius: 80 + (_glowController.value * 40),
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: _buildTitle(),
                  ),

                  const SizedBox(height: 20),

                  _buildTagline(),

                  const SizedBox(height: 14),

                  _buildDecorativeLine(),

                  const SizedBox(height: 70),

                  _buildGetStartedButton(),

                  const Spacer(flex: 1),

                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      delay: const Duration(milliseconds: 400),
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [
            Color(0xFF00D4FF), // Cyan
            Color(0xFF7B61FF), // Purple
            Color(0xFFFF61E6), // Pink
            Color(0xFF00D4FF), // Cyan
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: Text(
          AppConstants.appName,
          style: GoogleFonts.exo2(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 5.0,
            height: 1.1,
            shadows: [
              Shadow(
                color: const Color(0xFF00D4FF).withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      delay: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF00D4FF).withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D4FF).withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          AppConstants.appTagline,
          textAlign: TextAlign.center,
          style: GoogleFonts.rajdhani(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFFFFFF),
            letterSpacing: 3.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDecorativeLine() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      delay: const Duration(milliseconds: 800),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            width: 140,
            height: 3,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xFF00D4FF),
                  Color(0xFF7B61FF),
                  Color(0xFFFF61E6),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF00D4FF,
                  ).withOpacity(0.4 + (_glowController.value * 0.4)),
                  blurRadius: 15 + (_glowController.value * 10),
                  spreadRadius: 2,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1200),
      delay: const Duration(milliseconds: 1200),
      child: Center(
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              constraints: const BoxConstraints(maxWidth: 340),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF00D4FF,
                    ).withOpacity(0.4 + (_glowController.value * 0.3)),
                    blurRadius: 30 + (_glowController.value * 20),
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleGetStarted,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 60,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00D4FF),
                          Color(0xFF7B61FF),
                          Color(0xFFFF61E6),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'GET STARTED',
                          style: GoogleFonts.rajdhani(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 4.0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      delay: const Duration(milliseconds: 1400),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            Text(
              AppConstants.appVersion,
              style: GoogleFonts.sourceCodePro(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF00D4FF).withOpacity(0.7),
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFooterDot(),
                const SizedBox(width: 8),
                Text('SECURE', style: _footerTextStyle()),
                const SizedBox(width: 8),
                _buildFooterDot(),
                const SizedBox(width: 8),
                Text('RELIABLE', style: _footerTextStyle()),
                const SizedBox(width: 8),
                _buildFooterDot(),
                const SizedBox(width: 8),
                Text('FAST', style: _footerTextStyle()),
                const SizedBox(width: 8),
                _buildFooterDot(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterDot() {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFF00D4FF).withOpacity(0.6),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  TextStyle _footerTextStyle() {
    return GoogleFonts.rajdhani(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFAAAAAA),
      letterSpacing: 2.5,
    );
  }
}

// Custom painter for animated sparkles
class SparklePainter extends CustomPainter {
  final double animationValue;
  final math.Random random = math.Random(42); // Fixed seed for consistency

  SparklePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Generate sparkle positions (fixed positions, animated opacity)
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      // Create staggered animation effect
      final sparklePhase = (animationValue + (i * 0.1)) % 1.0;
      final opacity = (math.sin(sparklePhase * math.pi * 2) * 0.5 + 0.5) * 0.6;

      // Randomize colors
      final colorIndex = i % 3;
      Color sparkleColor;
      if (colorIndex == 0) {
        sparkleColor = const Color(0xFF00D4FF);
      } else if (colorIndex == 1) {
        sparkleColor = const Color(0xFF7B61FF);
      } else {
        sparkleColor = const Color(0xFFFF61E6);
      }

      paint.color = sparkleColor.withOpacity(opacity);

      // Draw sparkle
      final sparkleSize = 1.5 + (random.nextDouble() * 2);
      canvas.drawCircle(Offset(x, y), sparkleSize, paint);

      // Draw cross sparkle effect
      if (opacity > 0.5) {
        paint.strokeWidth = 1;
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(Offset(x - 4, y), Offset(x + 4, y), paint);
        canvas.drawLine(Offset(x, y - 4), Offset(x, y + 4), paint);
        paint.style = PaintingStyle.fill;
      }
    }
  }

  @override
  bool shouldRepaint(SparklePainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}
