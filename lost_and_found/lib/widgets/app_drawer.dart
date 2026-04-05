import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found/theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Lost&Found',
                  style: AppTheme.logoOnPrimary(fontSize: 20),
                ),
              ],
            ),
          ),
          _buildTile(context, 'Home', Icons.home_outlined, '/home'),
          _buildTile(context, 'Browse Items', Icons.search, '/items'),
          _buildTile(context, 'Report Lost', Icons.report_problem_outlined, '/lost'),
          _buildTile(context, 'Report Found', Icons.check_circle_outline, '/found'),
          _buildTile(context, 'Profile', Icons.person_outline, '/profile'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.error),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/signin');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, String title, IconData icon, String route) {
    final isActive = currentRoute == route;
    return ListTile(
      leading: Icon(icon, color: isActive ? AppTheme.primary : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          color: isActive ? AppTheme.primary : null,
        ),
      ),
      selected: isActive,
      selectedTileColor: AppTheme.muted,
      onTap: isActive ? null : () => Navigator.pushReplacementNamed(context, route),
    );
  }
}
