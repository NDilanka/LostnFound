import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String itemName;
  final String description;
  final String type; // 'lost' or 'found'
  final GeoPoint? location;
  final List<String> imageUrls;
  final String? userId;
  final String? posterName;
  final String? posterEmail;
  final Timestamp? createdAt;

  ItemModel({
    required this.id,
    required this.itemName,
    required this.description,
    required this.type,
    this.location,
    required this.imageUrls,
    this.userId,
    this.posterName,
    this.posterEmail,
    this.createdAt,
  });

  factory ItemModel.fromFirestore(DocumentSnapshot doc, String type) {
    final rawData = doc.data();
    if (rawData == null) {
      throw StateError('Document ${doc.id} does not exist');
    }
    final data = rawData as Map<String, dynamic>;
    return ItemModel(
      id: doc.id,
      itemName: data['itemName'] ?? '',
      description: data['description'] ?? '',
      type: type,
      location: data['location'] as GeoPoint?,
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      userId: data['userId'],
      posterName: data['posterName'],
      posterEmail: data['posterEmail'],
      createdAt: data['createdAt'] as Timestamp?,
    );
  }
}
