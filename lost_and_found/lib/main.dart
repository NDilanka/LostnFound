import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found/pages/profile_page.dart';
import 'package:lost_and_found/theme/app_theme.dart';

import 'firebase_options.dart';
import 'pages/found_page.dart';
import 'pages/lost_items.dart';
import 'pages/signinpage.dart';
import 'pages/signuppage.dart';
import 'pages/item_listing_page.dart';
import 'pages/item_details_page.dart';
import 'pages/splashscreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lost & Found',
      theme: AppTheme.themeData(),
      initialRoute: '/splash', // Set the initial route to SplashScreen
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/signup': (context) => const SignUpPage(),
        '/signin': (context) => const SignInPage(),
        '/lost': (context) => const LostPage(),
        '/found': (context) => const FoundPage(),
        '/profile': (context) => const ProfilePage(),
        '/items': (context) => const ItemListingPage(),
        '/details': (context) => const ItemDetailsPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.space16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/LF_logo.png',
                      width: 160.0,
                      height: 160.0,
                    ),
                    const SizedBox(height: AppTheme.space16),
                    Text(
                      'What would you like to do?',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/items');
                      },
                      child: const Text('Browse Items'),
                    ),
                    const SizedBox(height: AppTheme.space16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/lost');
                      },
                      child: const Text('Report Lost Item'),
                    ),
                    const SizedBox(height: AppTheme.space16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/found');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.foundBadge,
                      ),
                      child: const Text('Report Found Item'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

