import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/provider/school_provider.dart';
import 'package:schoolhq_ng/views/auth/select_school_screen.dart';
import 'package:schoolhq_ng/views/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _loadData();
  }

  Future<void> _loadData() async {
    await Provider.of<SchoolProvider>(context, listen: false).fetchSchools();
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeef1f8),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppImages.logo, height: 100), // Your logo
              const SizedBox(height: 20),
              Text(
                "SchoolHQ",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1e1e2f),
                ),
              ),
              const SizedBox(height: 8),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
