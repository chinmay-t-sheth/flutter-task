// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'fd_provider.dart';
import 'home_screen.dart';
import 'theme_provider.dart';
import 'dart:math' as math;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FDProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FD Tracker',
        theme: themeProvider.lightTheme,
        darkTheme: themeProvider.darkTheme,
        themeMode: themeProvider.themeMode,
        home: const ProfessionalSplashScreen(),
      ),
    );
  }
}

class ProfessionalSplashScreen extends StatefulWidget {
  const ProfessionalSplashScreen({super.key});

  @override
  State<ProfessionalSplashScreen> createState() => _ProfessionalSplashScreenState();
}

class _ProfessionalSplashScreenState extends State<ProfessionalSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  bool _dataLoaded = false;
  bool _shouldNavigate = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000), // Increased to 3 seconds
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
    ));

    // Start the animation
    _controller.forward();

    // Load data in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FDProvider>(context, listen: false).fetchFDsAndLogs().then((_) {
        if (mounted) {
          setState(() {
            _dataLoaded = true;
          });
          _checkNavigationReady();
        }
      });
    });

    // Set up navigation when both animation and data are complete
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkNavigationReady();
      }
    });

    // Minimum display time - ensure splash screen is visible for at least 2 seconds
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _shouldNavigate = true;
        });
        _checkNavigationReady();
      }
    });
  }

  void _checkNavigationReady() {
    if (_shouldNavigate && _dataLoaded && _controller.status == AnimationStatus.completed) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Subtle background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.background,
                      colorScheme.background.withOpacity(0.98),
                      colorScheme.surface.withOpacity(0.95),
                    ],
                  ),
                ),
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with elegant animation
                    _buildLogo(colorScheme),

                    const SizedBox(height: 40),

                    // App title with fade animation
                    _buildAppTitle(),

                    const SizedBox(height: 60),

                    // Progress indicator
                    _buildProgressIndicator(colorScheme),

                    const SizedBox(height: 20),

                    // Loading text
                    _buildLoadingText(colorScheme),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogo(ColorScheme colorScheme) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Background glow effect
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.1, 0.8],
                ),
              ),
            ),

            // Your logo with proper error handling
            Center(
              child: ClipOval(
                child: Image.asset(
                  'assets/images/app_logo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 32,
                        color: colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Subtle pulse effect when loading completes
            if (_dataLoaded)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppTitle() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Text(
            'FD TRACKER',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Secure Financial Management',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.0,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ColorScheme colorScheme) {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          // Progress bar
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: colorScheme.onBackground.withOpacity(0.1),
              borderRadius: BorderRadius.circular(1),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 120 * _progressAnimation.value,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingText(ColorScheme colorScheme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          key: ValueKey(_dataLoaded),
          _dataLoaded ? 'Ready to use' : 'Loading your data...',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: colorScheme.onBackground.withOpacity(0.6),
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}