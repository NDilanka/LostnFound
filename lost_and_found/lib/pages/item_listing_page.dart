import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found/models/item_model.dart';
import 'package:lost_and_found/utils/date_helpers.dart';
import 'package:lost_and_found/theme/app_theme.dart';
import 'package:lost_and_found/widgets/app_drawer.dart';

class ItemListingPage extends StatefulWidget {
  const ItemListingPage({super.key});

  @override
  State<ItemListingPage> createState() => _ItemListingPageState();
}

class _ItemListingPageState extends State<ItemListingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<ItemModel> _lostItems = [];
  List<ItemModel> _foundItems = [];
  List<ItemModel> _allItems = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<ItemModel> _filterItems(List<ItemModel> items) {
    if (_searchQuery.isEmpty) return items;
    final query = _searchQuery.toLowerCase();
    return items.where((item) =>
        item.itemName.toLowerCase().contains(query) ||
        item.description.toLowerCase().contains(query)).toList();
  }

  Future<void> _fetchItems() async {
    setState(() { _isLoading = true; });
    try {
      final results = await Future.wait([
        FirebaseFirestore.instance
            .collection('lost_items')
            .orderBy('createdAt', descending: true)
            .limit(50)
            .get(),
        FirebaseFirestore.instance
            .collection('found_items')
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
          _lostItems = lostItems;
          _foundItems = foundItems;
          _allItems = allItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load items: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search items...',
            filled: false,
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _searchController.clear();
                      setState(() { _searchQuery = ''; });
                    },
                  )
                : null,
            hintStyle: const TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() { _searchQuery = value; });
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Lost'),
            Tab(text: 'Found'),
          ],
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/items'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildItemList(_filterItems(_allItems)),
                _buildItemList(_filterItems(_lostItems)),
                _buildItemList(_filterItems(_foundItems)),
              ],
            ),
    );
  }

  Widget _buildItemList(List<ItemModel> items) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textSecondary),
              const SizedBox(height: AppTheme.space16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No items match your search.\nTry a different keyword.'
                    : 'No items posted yet',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.space8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16, vertical: 6),
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
                  ClipRRect(
                    borderRadius: AppTheme.radiusMedium,
                    child: item.imageUrls.isNotEmpty
                        ? Image.network(
                            item.imageUrls[0],
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 72, height: 72,
                                  color: AppTheme.muted,
                                  child: const Icon(Icons.image_not_supported, size: 32, color: AppTheme.textSecondary),
                                ),
                          )
                        : Container(
                            width: 72, height: 72,
                            color: AppTheme.muted,
                            child: const Icon(Icons.image_not_supported, size: 32, color: AppTheme.textSecondary),
                          ),
                  ),
                  const SizedBox(width: AppTheme.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.itemName,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
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
        );
      },
    );
  }

}
