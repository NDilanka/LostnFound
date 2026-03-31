import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found/pages/profile_page.dart';

import 'firebase_options.dart';
import 'pages/found_page.dart';
import 'pages/lost_items.dart';
import 'pages/signinpage.dart';
import 'pages/signuppage.dart';
import 'pages/item_listing_page.dart';
import 'pages/item_details_page.dart';
import 'pages/splashscreen.dart';
import 'seed_demo_data.dart';

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
      title: 'Hathi App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/LF_logo.png',
                      width: 200.0,
                      height: 200.0,
                    ),
                    const SizedBox(height: 10.0),
                    // Description text
                    const Text(
                      'You can Find or Post Lost and Found Items!',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: 'Poppins',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    // Browse Items — primary action
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/items');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 214, 128, 23),
                        minimumSize: const Size(325, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: const Text(
                        'Browse Items',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    // Report Lost Item — secondary
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/lost');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 214, 128, 23),
                        minimumSize: const Size(325, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: const Text(
                        'Report Lost Item',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    // Report Found Item — secondary
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/found');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6CB523),
                        minimumSize: const Size(325, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: const Text(
                        'Report Found Item',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    TextButton(
                      onPressed: () async {
                        try {
                          await seedDemoData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Demo data seeded successfully!')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to seed data: $e')),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Seed Demo Data (remove before demo)',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }
}

