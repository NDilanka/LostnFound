import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lost_and_found/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 2),
      () => Navigator.pushReplacementNamed(context, '/signin'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Lost&Found',
              style: AppTheme.logoOnPrimary(fontSize: 36),
            ),
            const SizedBox(height: AppTheme.space32),
            const SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(
                color: AppTheme.onPrimary,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
