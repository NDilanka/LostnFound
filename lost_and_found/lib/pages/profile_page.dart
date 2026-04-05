import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found/models/item_model.dart';
import 'package:lost_and_found/utils/date_helpers.dart';
import 'package:lost_and_found/theme/app_theme.dart';
import 'package:lost_and_found/widgets/app_drawer.dart';


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

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      _fetchMyItems();
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

  Future<void> _updateUserData() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      drawer: const AppDrawer(currentRoute: '/profile'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Profile',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppTheme.space24),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppTheme.space16),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: AppTheme.space16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: AppTheme.space16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppTheme.space24),
              ElevatedButton(
                onPressed: _updateUserData,
                child: const Text('Save Changes'),
              ),

              // My Posted Items section
              const SizedBox(height: AppTheme.space32),
              const Divider(),
              const SizedBox(height: AppTheme.space8),
              Text('My Posted Items',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppTheme.space12),
              if (_isLoadingItems)
                const Center(child: Padding(
                  padding: EdgeInsets.all(AppTheme.space24),
                  child: CircularProgressIndicator(),
                ))
              else if (_myItems.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.space24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.inbox_outlined, size: 48, color: AppTheme.textSecondary),
                        const SizedBox(height: AppTheme.space8),
                        Text(
                          'You haven\'t posted any items yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._myItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.space8),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/details', arguments: item);
                    },
                    borderRadius: AppTheme.radiusMedium,
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.space12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: AppTheme.radiusMedium,
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.itemName,
                                    style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 2),
                                Text(formatShortDate(item.createdAt),
                                    style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: AppTheme.badgeDecoration(item.type),
                            child: Text(
                              item.type == 'lost' ? 'Lost' : 'Found',
                              style: AppTheme.badgeTextStyle,
                            ),
                          ),
                        ],
                      ),
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
