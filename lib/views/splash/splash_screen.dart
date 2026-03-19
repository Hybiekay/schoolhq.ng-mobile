import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';
import 'package:schoolhq_ng/core/hive/hive_key.dart';
import 'package:schoolhq_ng/core/school/current_school.dart';
import 'package:schoolhq_ng/models/school_model.dart';
import 'package:schoolhq_ng/providers/auth_provider.dart';
import 'package:schoolhq_ng/providers/school_provider.dart';
import 'package:schoolhq_ng/routes/route_names.dart';
import 'package:schoolhq_ng/widget/school_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _loadingController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _loadingFade;

  @override
  void initState() {
    super.initState();

    // Logo animation: scale up and fade in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Loading indicator animation: delayed fade in
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _loadingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeIn),
    );

    // Start animations in sequence
    _startAnimations();
    _loadData();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    _loadingController.forward();
  }

  Future<void> _loadData() async {
    try {
      // Small delay to ensure animations start
      await Future.delayed(const Duration(milliseconds: 500));
      final isWeb = kIsWeb;

      // Use try-catch for Hive operations
      bool onboardingDone = false;
      dynamic schoolSelected;
      bool isLoggedIn = false;
      bool schoolInactive = false;

      try {
        final appBox = Hive.box('app');
        onboardingDone = appBox.get('onboardingDone', defaultValue: false);
        schoolSelected =
            appBox.get(HiveKey.selectedSchool) ??
            appBox.get(HiveKey.userSchool);
        final token = appBox.get(HiveKey.token);
        isLoggedIn = token is String && token.isNotEmpty;
      } catch (e) {
        if (kDebugMode) {
          print('Hive error: $e');
        }
        // Handle Hive initialization error
        _handleNavigation(isWeb: isWeb, hasError: true);
        return;
      }

      final savedSchool = SchoolModel.fromDynamic(schoolSelected);
      final hasSelectedSchool =
          savedSchool != null && savedSchool.id.isNotEmpty;

      if (!isWeb) {
        if (hasSelectedSchool) {
          try {
            final activeSchool = await ref
                .read(schoolDirectoryRepositoryProvider)
                .fetchActiveSchoolById(savedSchool.id);

            if (activeSchool == null) {
              schoolInactive = true;
              await ref.read(authProvider.notifier).logout();
            } else {
              ref.read(schoolProvider.notifier).selectSchool(activeSchool);
              schoolSelected = activeSchool.toJson();
            }
          } catch (e) {
            if (kDebugMode) {
              print('School validation error: $e');
            }
          }
        }
      }

      if (!schoolInactive && hasSelectedSchool) {
        await ref.read(authProvider.notifier).syncBranding();
        if (mounted) {
          setState(() {});
        }
      }

      if (!isWeb && !hasSelectedSchool && isLoggedIn) {
        await ref.read(authProvider.notifier).logout();
        isLoggedIn = false;
      } else if (isLoggedIn &&
          (isWeb || hasSelectedSchool) &&
          !schoolInactive) {
        isLoggedIn = await ref.read(authProvider.notifier).restoreSession();
      }

      _handleNavigation(
        isWeb: isWeb,
        onboardingDone: onboardingDone,
        hasSelectedSchool:
            SchoolModel.fromDynamic(schoolSelected)?.id.isNotEmpty ?? false,
        isLoggedIn: isLoggedIn,
        schoolInactive: schoolInactive,
        hasError: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Load data error: $e');
      }
      final appBox = Hive.box(HiveKey.boxApp);
      final savedSchool = SchoolModel.fromDynamic(
        appBox.get(HiveKey.selectedSchool) ?? appBox.get(HiveKey.userSchool),
      );
      final hasSavedSchool = savedSchool != null && savedSchool.id.isNotEmpty;

      context.go(hasSavedSchool ? RouteNames.login : RouteNames.selectSchool);
    }
  }

  void _handleNavigation({
    required bool isWeb,
    bool hasError = false,
    bool onboardingDone = false,
    bool hasSelectedSchool = false,
    bool isLoggedIn = false,
    bool schoolInactive = false,
  }) {
    if (hasError) {
      // Error handling - navigate to login or error screen
      context.go(RouteNames.login);
      return;
    }

    if (schoolInactive) {
      context.go(RouteNames.schoolInactive);
      return;
    }

    if (!isWeb && !hasSelectedSchool) {
      if (!onboardingDone) {
        context.go(RouteNames.onboarding);
        return;
      }
      context.go(RouteNames.selectSchool);
      return;
    }

    if (!isLoggedIn) {
      context.go(RouteNames.login);
      return;
    }

    context.go(RouteNames.home);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600;
    final isTablet = size.width >= 600 && size.width < 1200;
    final school = currentSchool();

    return Scaffold(
      backgroundColor: const Color(0xFFeef1f8),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 24.0 : 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoFade.value,
                      child: Column(
                        children: [
                          SchoolLogo(
                            logo: school.logo,
                            size: isMobile
                                ? 80
                                : isTablet
                                ? 120
                                : 150,
                            radius: 24,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            school.name,
                            style: TextStyle(
                              fontSize: isMobile
                                  ? 28
                                  : isTablet
                                  ? 36
                                  : 42,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1e1e2f),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              FadeTransition(
                opacity: _loadingFade,
                child: Column(
                  children: [
                    _buildLoadingIndicator(isMobile, isTablet),
                    const SizedBox(height: 16),
                    Text(
                      "Setting things up...",
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isMobile, bool isTablet) {
    return SizedBox(
      width: isMobile
          ? 40
          : isTablet
          ? 48
          : 56,
      height: isMobile
          ? 40
          : isTablet
          ? 48
          : 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: isMobile ? 3.0 : 4.0,
            valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
          ),
          // Optional: Add pulsing effect
          AnimatedBuilder(
            animation: _loadingController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_loadingController.value * 0.1),
                child: Container(
                  width: isMobile ? 12 : 16,
                  height: isMobile ? 12 : 16,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
