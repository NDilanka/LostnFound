import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> seedDemoData() async {
  final firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userId = user.uid;

  final userDoc = await firestore.collection('users').doc(userId).get();
  final userData = userDoc.data();
  final posterName = userData != null
      ? '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim()
      : 'Demo User';
  final posterEmail = user.email ?? 'demo@university.edu';

  final now = DateTime.now();

  final lostItems = [
    {
      'itemName': 'Black Leather Wallet',
      'description': 'Lost near the main library entrance. Contains student ID and bank cards. Brown leather with a small scratch on the front.',
      'imageUrls': ['https://picsum.photos/seed/wallet/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
      'location': const GeoPoint(6.9271, 79.8612),
    },
    {
      'itemName': 'Student ID Card',
      'description': 'Lost somewhere between the cafeteria and lecture hall B. Name on card: A. Perera. Please contact if found.',
      'imageUrls': ['https://picsum.photos/seed/studentid/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
    },
    {
      'itemName': 'Sony WH-1000XM4 Headphones',
      'description': 'Black over-ear headphones left in computer lab 3 on the second floor. Has a small sticker on the right ear cup.',
      'imageUrls': ['https://picsum.photos/seed/headphones/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
    },
    {
      'itemName': 'MacBook Charger (USB-C)',
      'description': 'White 67W USB-C charger left plugged in at the study area near the window. Has tape with my name on it.',
      'imageUrls': ['https://picsum.photos/seed/charger/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
    },
    {
      'itemName': 'Car Keys (Toyota)',
      'description': 'Set of car keys with a Toyota fob and a red keychain. Lost in the parking lot near building A.',
      'imageUrls': ['https://picsum.photos/seed/carkeys/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 7))),
      'location': const GeoPoint(6.9147, 79.8624),
    },
    {
      'itemName': 'Blue Umbrella',
      'description': 'Compact blue umbrella with wooden handle. Left in the entrance of the engineering building after the rain.',
      'imageUrls': ['https://picsum.photos/seed/umbrella/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 9))),
    },
    {
      'itemName': 'Prescription Glasses',
      'description': 'Black rectangular frame glasses in a brown case. Very important — cannot see without them. Left in room 204.',
      'imageUrls': ['https://picsum.photos/seed/glasses/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 12))),
    },
  ];

  final foundItems = [
    {
      'itemName': 'Water Bottle (Hydro Flask)',
      'description': 'Found a green 32oz Hydro Flask on the bench outside the sports complex. Has stickers on it.',
      'imageUrls': ['https://picsum.photos/seed/bottle/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1, hours: 5))),
    },
    {
      'itemName': 'Scientific Calculator (Casio)',
      'description': 'Found a Casio fx-991ES PLUS in lecture hall C after the math exam. Has initials "RJ" written on the back.',
      'imageUrls': ['https://picsum.photos/seed/calculator/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 4))),
    },
    {
      'itemName': 'Notebook with Handwritten Notes',
      'description': 'A5 spiral notebook with detailed chemistry notes. Found on a desk in the quiet study zone on the 3rd floor.',
      'imageUrls': ['https://picsum.photos/seed/notebook/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 6))),
    },
    {
      'itemName': 'USB Flash Drive (32GB)',
      'description': 'Black SanDisk flash drive found plugged into a computer in the media lab. Has a red lanyard attached.',
      'imageUrls': ['https://picsum.photos/seed/usb/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 8))),
      'location': const GeoPoint(6.9220, 79.8580),
    },
    {
      'itemName': 'Denim Jacket',
      'description': 'Blue denim jacket size M found draped over a chair in the student lounge. Has a pin on the collar.',
      'imageUrls': ['https://picsum.photos/seed/jacket/400/300'],
      'userId': userId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 11))),
    },
  ];

  final batch = firestore.batch();

  for (final item in lostItems) {
    batch.set(firestore.collection('lost_items').doc(), item);
  }
  for (final item in foundItems) {
    batch.set(firestore.collection('found_items').doc(), item);
  }

  await batch.commit();
}
