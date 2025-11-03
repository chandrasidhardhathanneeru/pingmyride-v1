import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/theme_service.dart';
import '../../core/services/bus_service.dart';
import '../../core/models/user_type.dart';
import '../../core/models/booking.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final profile = await authService.getCurrentUserProfile();
    setState(() {
      _userProfile = profile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final busService = Provider.of<BusService>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userName = _userProfile?['name'] ?? 'User';
    final userEmail = _userProfile?['email'] ?? authService.currentUserEmail ?? '';
    final userPhone = _userProfile?['phone'] ?? 'Not provided';
    final userType = authService.currentUserType ?? UserType.student;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Professional App Bar with gradient
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userType.label,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Account Information Section
                  _buildSectionHeader(context, 'Account Information'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    context,
                    [
                      _InfoItem(
                        icon: Icons.person_outline,
                        label: 'Full Name',
                        value: userName,
                        isEditable: true,
                        onTap: () => _showEditDialog(context, 'name', userName),
                      ),
                      _InfoItem(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: userEmail,
                      ),
                      _InfoItem(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: userPhone,
                        isEditable: true,
                        onTap: () => _showEditDialog(context, 'phone', userPhone),
                      ),
                      _InfoItem(
                        icon: Icons.badge_outlined,
                        label: 'User Type',
                        value: userType.label,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Statistics Section (for students)
                  if (userType == UserType.student) ...[
                    _buildSectionHeader(context, 'My Statistics'),
                    const SizedBox(height: 12),
                    _buildStatsCard(context, busService),
                    const SizedBox(height: 24),
                  ],

                  // Settings Section
                  _buildSectionHeader(context, 'Preferences'),
                  const SizedBox(height: 12),
                  _buildSettingsCard(context, themeService),

                  const SizedBox(height: 24),

                  // App Information
                  _buildSectionHeader(context, 'About'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    context,
                    [
                      _InfoItem(
                        icon: Icons.info_outline,
                        label: 'Version',
                        value: '1.0.0',
                      ),
                      _InfoItem(
                        icon: Icons.help_outline,
                        label: 'Help & Support',
                        value: 'Contact Support',
                        onTap: () {
                          _showSupportDialog(context);
                        },
                      ),
                      _InfoItem(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        value: 'View Policy',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Privacy Policy - Coming soon')),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleLogout(context, authService),
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<_InfoItem> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: items.map((item) {
            return ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                item.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
              subtitle: Text(
                item.value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              trailing: item.onTap != null
                  ? Icon(
                      item.isEditable ? Icons.edit_outlined : Icons.chevron_right,
                      size: item.isEditable ? 18 : 24,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    )
                  : null,
              onTap: item.onTap,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, BusService busService) {
    final totalBookings = busService.userBookings.length;
    final activeBookings = busService.confirmedBookings.length;
    final cancelledBookings = busService.userBookings
        .where((b) => b.status.name == 'cancelled')
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              icon: Icons.confirmation_number,
              label: 'Total',
              value: totalBookings.toString(),
              color: Theme.of(context).colorScheme.primary,
            ),
            Container(
              height: 40,
              width: 1,
              color: Theme.of(context).dividerColor,
            ),
            _buildStatItem(
              context,
              icon: Icons.check_circle_outline,
              label: 'Active',
              value: activeBookings.toString(),
              color: Colors.green,
            ),
            Container(
              height: 40,
              width: 1,
              color: Theme.of(context).dividerColor,
            ),
            _buildStatItem(
              context,
              icon: Icons.cancel_outlined,
              label: 'Cancelled',
              value: cancelledBookings.toString(),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context, ThemeService themeService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  themeService.themeMode == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                'Theme Mode',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
              subtitle: Text(
                themeService.themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              trailing: Switch(
                value: themeService.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeService.toggleTheme();
                },
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                'Notifications',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
              subtitle: Text(
                'Push notifications enabled',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification settings - Coming soon')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Need help? Contact us:'),
            const SizedBox(height: 16),
            _buildContactItem(Icons.email, 'support@pingmyride.com'),
            const SizedBox(height: 8),
            _buildContactItem(Icons.phone, '+1 (555) 123-4567'),
            const SizedBox(height: 8),
            _buildContactItem(Icons.language, 'www.pingmyride.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context, AuthService authService) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await authService.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });
}
