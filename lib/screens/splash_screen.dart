import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../core/theme/app_colors.dart';
import '../utils/responsive_helper.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _pulseScale;
  late Animation<double> _fadeAnimation;

  String _version = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadVersion();
    _startSplashSequence();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = packageInfo.version);
    } catch (_) {
      if (mounted) setState(() => _version = '1.0.0');
    }
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  Future<void> _startSplashSequence() async {
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _pulseController.repeat(reverse: true);
    await Future.delayed(const Duration(seconds: 2));
    await _fadeController.forward();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, _) => const MainScreen(),
          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    final logoSize = responsive.getValue(
      smallPhone: 100.0,
      phone: 120.0,
      largePhone: 130.0,
      tablet: 160.0,
      desktop: 180.0,
      automotive: 140.0,
    );

    final titleFontSize = responsive.getValue(
      smallPhone: 22.0,
      phone: 24.0,
      largePhone: 26.0,
      tablet: 28.0,
      desktop: 32.0,
      automotive: 26.0,
    );

    final subtitleFontSize = responsive.getValue(
      smallPhone: 14.0,
      phone: 16.0,
      largePhone: 17.0,
      tablet: 18.0,
      desktop: 20.0,
      automotive: 18.0,
    );

    final versionFontSize = responsive.getValue(
      smallPhone: 12.0,
      phone: 13.0,
      largePhone: 14.0,
      tablet: 15.0,
      desktop: 16.0,
      automotive: 14.0,
    );

    final loadingSize = responsive.getValue(
      smallPhone: 28.0,
      phone: 32.0,
      largePhone: 36.0,
      tablet: 40.0,
      desktop: 44.0,
      automotive: 36.0,
    );

    final loadingStrokeWidth = responsive.getValue(
      smallPhone: 2.0,
      phone: 2.5,
      tablet: 3.0,
      desktop: 3.5,
      automotive: 3.0,
    );

    final loadingTextSize = responsive.getValue(
      smallPhone: 12.0,
      phone: 14.0,
      largePhone: 15.0,
      tablet: 16.0,
      desktop: 18.0,
      automotive: 16.0,
    );

    final spacing1 = responsive.spacing(32);
    final spacing2 = responsive.spacing(10);
    final spacingVersion = responsive.spacing(4);
    final spacing3 = responsive.spacing(16);
    final spacing4 = responsive.spacing(40);

    final blurRadius = responsive.getValue(
      phone: 20.0,
      tablet: 30.0,
      desktop: 35.0,
      automotive: 25.0,
    );

    final spreadRadius = responsive.getValue(
      phone: 5.0,
      tablet: 10.0,
      desktop: 12.0,
      automotive: 8.0,
    );

    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient, // ✅ Usa gradiente de marca
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    /// 🔴 LOGO ANIMADO
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _logoController,
                        _pulseController,
                      ]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScale.value * _pulseScale.value,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: Container(
                              width: logoSize,
                              height: logoSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.25),
                                    AppColors.secondary.withValues(alpha: 0.15),
                                    AppColors.secondary.withValues(alpha: 0.10),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: blurRadius,
                                    spreadRadius: spreadRadius,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/logo.png',
                                  width: logoSize * 0.7,
                                  height: logoSize * 0.7,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.radio,
                                      color: AppColors.textPrimary,
                                      size: logoSize * 0.5,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: spacing1),

                    /// 🔴 TÍTULO
                    AnimatedBuilder(
                      animation: _logoOpacity,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacity.value,
                          child: Text(
                            'Jóvenes Cristianos',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: spacing2),

                    /// 🔴 SUBTÍTULO
                    AnimatedBuilder(
                      animation: _logoOpacity,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacity.value * 0.8,
                          child: Text(
                            'Colombia',
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: AppColors.textMuted,
                              letterSpacing: 2.0,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: spacingVersion),

                    /// 🔴 VERSIÓN
                    AnimatedBuilder(
                      animation: _logoOpacity,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacity.value * 0.6,
                          child: Text(
                            'v$_version',
                            style: TextStyle(
                              fontSize: versionFontSize,
                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      },
                    ),

                    const Spacer(),

                    /// 🔴 INDICADOR DE CARGA
                    AnimatedBuilder(
                      animation: _logoOpacity,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacity.value,
                          child: Column(
                            children: [
                              SizedBox(
                                width: loadingSize,
                                height: loadingSize,
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: loadingStrokeWidth,
                                ),
                              ),
                              SizedBox(height: spacing3),
                              Text(
                                'Cargando...',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: loadingTextSize,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    SizedBox(height: spacing4),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
