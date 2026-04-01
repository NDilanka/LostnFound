import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_and_found/models/item_model.dart';

void main() {
  group('ItemModel constructor', () {
    test('creates model with all fields populated', () {
      final timestamp = Timestamp.fromDate(DateTime(2024, 3, 15, 14, 30));
      final location = const GeoPoint(6.9271, 79.8612);

      final item = ItemModel(
        id: 'doc123',
        itemName: 'Black Leather Wallet',
        description: 'Lost near the library',
        type: 'lost',
        location: location,
        imageUrls: ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
        userId: 'user456',
        posterName: 'John Doe',
        posterEmail: 'john@example.com',
        createdAt: timestamp,
      );

      expect(item.id, 'doc123');
      expect(item.itemName, 'Black Leather Wallet');
      expect(item.description, 'Lost near the library');
      expect(item.type, 'lost');
      expect(item.location!.latitude, 6.9271);
      expect(item.location!.longitude, 79.8612);
      expect(item.imageUrls.length, 2);
      expect(item.imageUrls[0], 'https://example.com/img1.jpg');
      expect(item.userId, 'user456');
      expect(item.posterName, 'John Doe');
      expect(item.posterEmail, 'john@example.com');
      expect(item.createdAt, timestamp);
    });

    test('creates model with only required fields', () {
      final item = ItemModel(
        id: 'doc789',
        itemName: 'Keys',
        description: 'Found in hallway',
        type: 'found',
        imageUrls: [],
      );

      expect(item.id, 'doc789');
      expect(item.itemName, 'Keys');
      expect(item.type, 'found');
      expect(item.location, isNull);
      expect(item.imageUrls, isEmpty);
      expect(item.userId, isNull);
      expect(item.posterName, isNull);
      expect(item.posterEmail, isNull);
      expect(item.createdAt, isNull);
    });

    test('stores type field exactly as provided', () {
      final lost = ItemModel(
        id: '1', itemName: 'a', description: 'b', type: 'lost', imageUrls: [],
      );
      final found = ItemModel(
        id: '2', itemName: 'a', description: 'b', type: 'found', imageUrls: [],
      );

      expect(lost.type, 'lost');
      expect(found.type, 'found');
    });

    test('imageUrls stores list correctly', () {
      final item = ItemModel(
        id: '1',
        itemName: 'Item',
        description: 'Desc',
        type: 'lost',
        imageUrls: ['url1', 'url2', 'url3'],
      );

      expect(item.imageUrls.length, 3);
      expect(item.imageUrls, ['url1', 'url2', 'url3']);
    });

    test('GeoPoint location stores coordinates', () {
      final item = ItemModel(
        id: '1',
        itemName: 'Item',
        description: 'Desc',
        type: 'found',
        imageUrls: [],
        location: const GeoPoint(50.3755, -4.1427),
      );

      expect(item.location, isNotNull);
      expect(item.location!.latitude, closeTo(50.3755, 0.0001));
      expect(item.location!.longitude, closeTo(-4.1427, 0.0001));
    });
  });
}
