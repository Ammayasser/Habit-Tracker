import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_page.dart';

class Feature {
  final IconData icon;
  final String text;

  const Feature({
    required this.icon,
    required this.text,
  });
}

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.withOpacity(0.2),
                    const Color(0xFF1A1A1A),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Welcome text with animation
                  Text(
                    'Welcome to',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideX(begin: -30, duration: 600.ms, curve: Curves.easeOut),
                  const SizedBox(height: 8),
                  // App name with animation
                  Text(
                    'Habit Tracker',
                    style: GoogleFonts.poppins(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      height: 1.1,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideX(begin: -30, duration: 600.ms, curve: Curves.easeOut),
                  const SizedBox(height: 16),
                  // Description with animation
                  Text(
                    'Build better habits and achieve your goals.',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[400],
                      height: 1.4,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 600.ms)
                  .slideX(begin: -30, duration: 600.ms, curve: Curves.easeOut),
                  const SizedBox(height: 20),
                  // Lottie animation
                  Center(
                    child: SizedBox(
                      height: 200,
                      child: Lottie.network(
                        'https://assets3.lottiefiles.com/packages/lf20_xqbbyrjo.json',
                        repeat: true,
                        animate: true,
                        errorBuilder: (context, error, stackTrace) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 100,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Track Your Habits',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 800.ms)
                  .scale(begin: const Offset(0.8, 0.8), duration: 800.ms),
                  const SizedBox(height: 20),
                  // Features list with animation
                  ..._buildFeaturesList()
                      .animate(interval: 200.ms)
                      .fadeIn(duration: 600.ms, delay: 1000.ms)
                      .slideY(begin: 30, duration: 600.ms),
                  const Spacer(),
                  // Get Started button with animation
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2196F3), // Blue
                              Color(0xFF448AFF), // Light Blue
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 16,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Get Started',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 1400.ms)
                  .slideY(begin: 30, duration: 600.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeaturesList() {
    final features = [
      const Feature(
        icon: Icons.track_changes,
        text: 'Track your daily habits with ease',
      ),
      const Feature(
        icon: Icons.insights,
        text: 'Get insights into your progress',
      ),
      const Feature(
        icon: Icons.notifications_active,
        text: 'Set reminders to stay on track',
      ),
    ];

    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                feature.icon,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                feature.text,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[300],
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
