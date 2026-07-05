import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  
  double _loadingProgress = 0.0;
  bool _isLoaded = false;
  bool _isTransitioning = false;
  
  final List<String> _loadingTips = [
    "COMPILING CORE LOGIC...",
    "CALIBRATING PET SANCTUARY...",
    "LOADING SKILL TREE PATHS...",
    "SYNCING WITH MONGO DATABASE...",
    "INITIALIZING AVATAR SYSTEMS...",
    "READY TO ENTER THE GRID."
  ];
  String _currentTip = "BOOTING SYSTEMS...";

  @override
  void initState() {
    super.initState();
    
    // Progress controller for the loading bar (2.5 seconds loading)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addListener(() {
        setState(() {
          _loadingProgress = _progressController.value;
          
          // Update loading texts based on progress
          int tipIndex = (_loadingProgress * (_loadingTips.length - 1)).floor();
          _currentTip = _loadingTips[tipIndex];
        });
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isLoaded = true;
          });
          _pulseController.repeat(reverse: true);
        }
      });

    // Pulse controller for "TAP TO START" text
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Fade controller for logo entry
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onTapStart() {
    if (!_isLoaded || _isTransitioning) return;

    setState(() {
      _isTransitioning = true;
    });

    // Play a scale-out transition and navigate to MainAuthShell
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var curve = Curves.easeInOut;

          var fade = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: curve),
          );

          var scale = Tween<double>(begin: 1.15, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: curve),
          );

          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: scale,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RpgColors.background,
      body: GestureDetector(
        onTap: _onTapStart,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Data Analyst stats dashboard background image
            Positioned.fill(
              child: Image.asset(
                'assets/data_stats_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            
            // Vignette Overlay for premium cyber atmosphere
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      RpgColors.background.withValues(alpha: 0.8),
                      RpgColors.background,
                    ],
                    stops: const [0.3, 0.8, 1.0],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Game Title / Logo Crest with Glow
                  AnimatedBuilder(
                    animation: _fadeController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeController.value,
                        child: Transform.scale(
                          scale: 0.9 + (_fadeController.value * 0.1),
                          child: child,
                        ),
                      );
                    },
                    child: Center(
                      child: Column(
                        children: [
                          // Neon Emblem
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: RpgColors.accent.withValues(alpha: 0.3),
                                  blurRadius: 25,
                                  spreadRadius: 5,
                                ),
                              ],
                              border: Border.all(color: RpgColors.accent, width: 3),
                              gradient: LinearGradient(
                                colors: [
                                  RpgColors.accent,
                                  RpgColors.accent.withValues(alpha: 0.3),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.school,
                                size: 55,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          // Game Name
                          Text(
                            'MyCareer',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  color: RpgColors.accent,
                                  offset: Offset(0, 0),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'E-LEARNING PLATFORM',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: RpgColors.textSecondary,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Loading and Interactive Tap Actions
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      children: [
                        if (!_isLoaded) ...[
                          // Custom Loading Progress Bar
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: _loadingProgress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [RpgColors.accent, Colors.cyan],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: RpgColors.accent.withValues(alpha: 0.5),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                        
                        // Status or Interactive prompt
                        SizedBox(
                          height: 50,
                          child: Center(
                            child: _isLoaded
                                ? FadeTransition(
                                    opacity: _pulseController,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'PRESS TO START',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 4,
                                            shadows: [
                                              Shadow(
                                                color: Colors.cyan,
                                                offset: Offset(0, 0),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'TAP ANYWHERE ON SCREEN',
                                          style: TextStyle(
                                            color: Colors.cyan.withValues(alpha: 0.7),
                                            fontSize: 10,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Text(
                                    _currentTip,
                                    style: TextStyle(
                                      color: RpgColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for Matrix Rain Effect
class DigitalRainPainter extends CustomPainter {
  final List<RainDrop> _drops = List.generate(25, (index) => RainDrop());
  final Random _random = Random();

  DigitalRainPainter() {
    // Periodically update to animate
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      for (var drop in _drops) {
        drop.update();
      }
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var drop in _drops) {
      if (drop.x == 0) {
        drop.init(size.width, _random);
      }
      
      final paint = Paint()
        ..color = RpgColors.accent.withValues(alpha: drop.opacity)
        ..style = PaintingStyle.fill;

      // Draw trailing neon binary symbols
      for (int i = 0; i < drop.length; i++) {
        double yPos = drop.y - (i * 18);
        if (yPos < 0 || yPos > size.height) continue;

        double symbolOpacity = drop.opacity * (1.0 - (i / drop.length));
        paint.color = (i == 0) 
            ? Colors.cyan.withValues(alpha: symbolOpacity) // head is bright cyan
            : RpgColors.accent.withValues(alpha: symbolOpacity * 0.4);

        final textPainter = TextPainter(
          text: TextSpan(
            text: drop.symbols[(drop.symbolOffset + i) % drop.symbols.length],
            style: TextStyle(
              color: paint.color,
              fontSize: drop.fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
              shadows: [
                if (i == 0)
                  Shadow(
                    color: Colors.cyan.withValues(alpha: 0.8),
                    blurRadius: 5,
                  ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(canvas, Offset(drop.x, yPos));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RainDrop {
  double x = 0;
  double y = 0;
  double speed = 0;
  double fontSize = 0;
  double opacity = 0;
  int length = 0;
  int symbolOffset = 0;
  List<String> symbols = [];

  void init(double maxWidth, Random rand) {
    x = rand.nextDouble() * maxWidth;
    y = -rand.nextDouble() * 200;
    speed = 3 + rand.nextDouble() * 7;
    fontSize = 9 + rand.nextInt(6).toDouble();
    opacity = 0.3 + rand.nextDouble() * 0.5;
    length = 5 + rand.nextInt(8);
    symbolOffset = rand.nextInt(100);
    symbols = List.generate(length + 5, (index) => rand.nextBool() ? "1" : "0");
  }

  void update() {
    y += speed;
    symbolOffset++;
    if (y > 900) {
      y = -100;
    }
  }
}


