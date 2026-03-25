import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found/main.dart';
import 'package:lost_and_found/pages/signinpage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneNumberController;

  late String _userId;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneNumberController = TextEditingController();

    _fetchUserData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _phoneNumberController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      // Fetch user data from Firestore using current user's UID
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(_userId)
          .get();
      Map<String, dynamic>? userData = snapshot.data();
      if (userData != null) {
        setState(() {
          _emailController.text = userData['email'];
          _firstNameController.text = userData['firstName'];
          _lastNameController.text = userData['lastName'];
          _phoneNumberController.text = userData['phone_number'];
        });
      }
    }
  }

  void _updateUserData() async {
    // Update user data in Firestore using current user's UID
    await FirebaseFirestore.instance.collection('users').doc(_userId).update({
      'email': _emailController.text,
      'firstName': _firstNameController.text,
      'phone_number': _phoneNumberController.text,
      'lastName': _lastNameController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: _updateUserData,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromRGBO(232, 99, 70, 1),
        child: ListView(
          children: [
            const InkWell(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 28.0,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        "Menu",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Icon(
                        Icons.home,
                        size: 28.0,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Home",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Icon(
                        Icons.person,
                        size: 28.0,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Profile",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 450.0,
              width: 10.0,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignInPage(),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Icon(
                        Icons.logout,
                        size: 28.0,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Logout",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Email'),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('Full Name'),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                hintText: 'Enter your First name',
              ),
            ),
            const Text('Last Name'),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                hintText: 'Enter your Last name',
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('Phone Number'),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                hintText: 'Enter your phone number',
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
