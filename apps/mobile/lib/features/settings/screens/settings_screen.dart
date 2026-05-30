import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/features/auth/cubit/auth_cubit.dart';
import 'package:mquiz/features/profile/cubit/profile_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _languages = <_Lang>[
    _Lang(code: 'en', label: 'English'),
    _Lang(code: 'yo', label: 'Yoruba'),
    _Lang(code: 'ha', label: 'Hausa'),
    _Lang(code: 'ig', label: 'Igbo'),
  ];

  String? _selectedLang;

  @override
  void initState() {
    super.initState();
    final ps = context.read<ProfileCubit>().state;
    if (ps is ProfileLoaded) {
      _selectedLang = ps.profile.appLanguage ?? 'en';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // ── Notifications ───────────────────────────────────────────────
          _SectionHeader('Notifications'),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Manage Notifications'),
            subtitle: const Text('Tap to open OS notification settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              // Request permission (iOS); on Android this opens app settings.
              await FirebaseMessaging.instance.requestPermission(
                alert: true,
                badge: true,
                sound: true,
              );
            },
          ),
          const Divider(height: 1),
          // ── Language ────────────────────────────────────────────────────
          _SectionHeader('Language'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: _selectedLang,
              decoration: InputDecoration(
                labelText: 'App Language',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _languages.map((l) {
                return DropdownMenuItem(value: l.code, child: Text(l.label));
              }).toList(),
              onChanged: (code) {
                if (code == null) return;
                setState(() => _selectedLang = code);
                context
                    .read<ProfileCubit>()
                    .updateProfile({'appLanguage': code});
              },
            ),
          ),
          const Divider(height: 1),
          // ── Account ─────────────────────────────────────────────────────
          _SectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.textSecondary),
            title: const Text('Sign Out'),
            onTap: () => _confirmSignOut(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined,
                color: AppColors.wrong),
            title: const Text('Delete Account',
                style: TextStyle(color: AppColors.wrong)),
            subtitle: const Text('Permanently removes your account data'),
            onTap: () => _confirmDeleteAccount(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
            'You will need to sign in again to access your account.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.wrong),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AuthCubit>().signOut();
      if (context.mounted) context.go('/login');
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This is permanent. All your progress, coins, and data will be lost. '
          'You may be asked to re-enter your password to confirm.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.wrong),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!context.mounted) return;

    try {
      // Firebase enforces recent-sign-in before deletion — prevents
      // session-hijack account deletion (throws requiresRecentLogin if stale).
      await FirebaseAuth.instance.currentUser?.delete();
      if (context.mounted) {
        await context.read<AuthCubit>().signOut();
        if (context.mounted) context.go('/login');
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      final msg = e.code == 'requires-recent-login'
          ? 'Please sign out and sign in again before deleting your account.'
          : 'Could not delete account: ${e.message}';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _Lang {
  const _Lang({required this.code, required this.label});
  final String code;
  final String label;
}
