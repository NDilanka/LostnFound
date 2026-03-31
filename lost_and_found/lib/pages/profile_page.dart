import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found/main.dart';
import 'package:lost_and_found/models/item_model.dart';


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
  List<ItemModel> _myItems = [];
  bool _isLoadingItems = true;

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
      _fetchMyItems();
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

  Future<void> _fetchMyItems() async {
    try {
      final results = await Future.wait([
        FirebaseFirestore.instance
            .collection('lost_items')
            .where('userId', isEqualTo: _userId)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .get(),
        FirebaseFirestore.instance
            .collection('found_items')
            .where('userId', isEqualTo: _userId)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .get(),
      ]);

      final lostItems = results[0].docs
          .map((doc) => ItemModel.fromFirestore(doc, 'lost'))
          .toList();
      final foundItems = results[1].docs
          .map((doc) => ItemModel.fromFirestore(doc, 'found'))
          .toList();

      final allItems = [...lostItems, ...foundItems];
      allItems.sort((a, b) =>
          (b.createdAt?.millisecondsSinceEpoch ?? 0)
              .compareTo(a.createdAt?.millisecondsSinceEpoch ?? 0));

      if (mounted) {
        setState(() {
          _myItems = allItems;
          _isLoadingItems = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoadingItems = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load your items: $e')),
        );
      }
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Date unknown';
    final date = timestamp.toDate();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
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
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/signin');
                }
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
      body: SingleChildScrollView(
        child: Padding(
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

              // My Posted Items section
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'My Posted Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (_isLoadingItems)
                const Center(child: CircularProgressIndicator())
              else if (_myItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'You haven\'t posted any items yet',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
                )
              else
                ..._myItems.map((item) => InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/details', arguments: item);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.itemName,
                                  style: const TextStyle(fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(_formatDate(item.createdAt),
                                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.type == 'lost'
                                ? const Color.fromARGB(255, 214, 128, 23)
                                : const Color(0xFF6CB523),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.type == 'lost' ? 'Lost' : 'Found',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }
}
