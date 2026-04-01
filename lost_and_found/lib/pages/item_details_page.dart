import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lost_and_found/models/item_model.dart';
import 'package:lost_and_found/utils/date_helpers.dart';
import 'package:lost_and_found/theme/app_theme.dart';
import 'package:lost_and_found/widgets/app_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailsPage extends StatefulWidget {
  const ItemDetailsPage({super.key});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  ItemModel? _item;
  int _currentPhotoIndex = 0;

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
      drawer: const AppDrawer(currentRoute: '/details'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photos
            if (item.imageUrls.isNotEmpty) _buildPhotoSection(item),

            Padding(
              padding: const EdgeInsets.all(AppTheme.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item name + type badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.itemName,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: AppTheme.badgeDecoration(item.type),
                        child: Text(
                          item.type == 'lost' ? 'Lost' : 'Found',
                          style: const TextStyle(
                              color: AppTheme.onPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space16),

                  // Description
                  Text('Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppTheme.space8),
                  Text(item.description,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: AppTheme.space16),

                  // Location map (conditional)
                  if (item.location != null) ...[
                    Text('Location',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppTheme.space8),
                    ClipRRect(
                      borderRadius: AppTheme.radiusMedium,
                      child: SizedBox(
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
                    ),
                    const SizedBox(height: AppTheme.space16),
                  ],

                  // Posting date and time
                  Text('Posted',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppTheme.space8),
                  Text(formatFullDate(item.createdAt),
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: AppTheme.space16),

                  // Poster info
                  Text('Posted by',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppTheme.space8),
                  Text(item.posterName ?? 'Unknown poster',
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  Text(item.posterEmail ?? 'Contact info not available',
                      style: Theme.of(context).textTheme.bodySmall),

                  // Contact Poster button
                  if (item.posterEmail != null) ...[
                    const SizedBox(height: AppTheme.space16),
                    ElevatedButton.icon(
                      onPressed: () => _showContactDialog(item),
                      icon: const Icon(Icons.email),
                      label: const Text('Contact Poster'),
                    ),
                  ],

                  const SizedBox(height: AppTheme.space32),
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
    return Column(
      children: [
        Container(
          color: AppTheme.muted,
          height: 250,
          child: PageView.builder(
            itemCount: item.imageUrls.length,
            onPageChanged: (index) {
              setState(() { _currentPhotoIndex = index; });
            },
            itemBuilder: (context, index) {
              return Image.network(
                item.imageUrls[index],
                fit: BoxFit.contain,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.image_not_supported, size: 60, color: AppTheme.textSecondary),
                ),
              );
            },
          ),
        ),
        if (item.imageUrls.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: AppTheme.space8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(item.imageUrls.length, (i) => Container(
                width: 8, height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _currentPhotoIndex ? AppTheme.primary : AppTheme.border,
                ),
              )),
            ),
          ),
      ],
    );
  }

}
