import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lost_and_found/models/item_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailsPage extends StatefulWidget {
  const ItemDetailsPage({super.key});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  ItemModel? _item;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _item ??= ModalRoute.of(context)!.settings.arguments as ItemModel;
  }

  @override
  Widget build(BuildContext context) {
    if (_item == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final item = _item!;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.itemName, overflow: TextOverflow.ellipsis, maxLines: 1),
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photos
            if (item.imageUrls.isNotEmpty) _buildPhotoSection(item),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item name + type badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.itemName,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: item.type == 'lost'
                              ? const Color.fromARGB(255, 214, 128, 23)
                              : const Color(0xFF6CB523),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.type == 'lost' ? 'Lost' : 'Found',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text('Description',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(item.description,
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 16),

                  // Location map (conditional)
                  if (item.location != null) ...[
                    const Text('Location',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                              item.location!.latitude, item.location!.longitude),
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('item_location'),
                            position: LatLng(item.location!.latitude,
                                item.location!.longitude),
                          ),
                        },
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: false,
                        scrollGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Posting date and time
                  const Text('Posted',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_formatFullDate(item.createdAt),
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 16),

                  // Poster info
                  const Text('Posted by',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(item.posterName ?? 'Unknown poster',
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(item.posterEmail ?? 'Contact info not available',
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),

                  // Contact Poster button
                  if (item.posterEmail != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showContactDialog(item),
                        icon: const Icon(Icons.email),
                        label: const Text('Contact Poster'),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactDialog(ItemModel item) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Contact Poster'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Email address:'),
              const SizedBox(height: 8),
              SelectableText(
                item.posterEmail!,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: item.posterEmail!));
                Navigator.pop(dialogContext);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Copy Email'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: item.posterEmail,
                  queryParameters: {
                    'subject': 'Lost and Found: ${item.itemName}',
                  },
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open email app'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: const Text('Open Email App'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPhotoSection(ItemModel item) {
    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: item.imageUrls.length,
        itemBuilder: (context, index) {
          return Image.network(
            item.imageUrls[index],
            fit: BoxFit.contain,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu',
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            title: const Text('Home'),
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          ListTile(
            title: const Text('Browse Items'),
            onTap: () => Navigator.pushReplacementNamed(context, '/items'),
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () => Navigator.pushReplacementNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Date unknown';
    final date = timestamp.toDate();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:$minute $amPm';
  }
}
