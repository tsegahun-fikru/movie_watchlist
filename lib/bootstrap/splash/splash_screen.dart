// lib/bootstrap/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:movie_watchlist/bootstrap/splash/widgets/zigzag_painter.dart';
import 'package:movie_watchlist/core/constants/constants.dart';
import 'package:movie_watchlist/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            Positioned(
              bottom: 100,
              child: Container(
                width: 255,
                height: 255,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
            ),
            // Person asset
            Positioned(
              left: -25,
              bottom: -50,
              child: Image.asset(Constants.splashPersonAsset, width: 440),
            ),
            // "Movie TIME" text
            Positioned(
              top: 60,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Movie",
                    style: TextStyle(
                      fontSize: 65,
                      color: AppColors.textPrimary,
                      fontStyle: FontStyle.italic,
                      height: 1.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 80),
                    child: Column(
                      children: [
                        const Text(
                          "TIME",
                          style: TextStyle(
                            fontSize: 32,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            height: 0.6,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: 70,
                          height: 5,
                          child: CustomPaint(painter: const ZigZagPainter(color: AppColors.star)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Centered brand tagline
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "Philm",
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "watch and let your soul drift",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
