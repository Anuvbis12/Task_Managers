import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class SettingsPage extends StatefulWidget {
  final User currentUser;
  final VoidCallback toggleTheme;
  final VoidCallback onLogout;
  final Function(User) onUserUpdated;

  const SettingsPage({
    super.key,
    required this.currentUser,
    required this.toggleTheme,
    required this.onLogout,
    required this.onUserUpdated,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.fullName);
  }

  @override
  void didUpdateWidget(covariant SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUser.fullName != oldWidget.currentUser.fullName) {
      _nameController.text = widget.currentUser.fullName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showEditNameDialog() {
    _nameController.text = widget.currentUser.fullName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile Name'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.trim().isNotEmpty) {
                  final updatedUser = widget.currentUser.copyWith(fullName: _nameController.text.trim());
                  widget.onUserUpdated(updatedUser);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 0, 24), // Sesuaikan padding
      children: [
        Text(
          'Settings',
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24.0),

        // Pengaturan Akun
        Card(
          margin: const EdgeInsets.only(right: 24), // Tambahkan margin kanan
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account', style: theme.textTheme.titleLarge),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: theme.colorScheme.primary.withAlpha(26),
                        child: Icon(Icons.person, size: 50, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Name'),
                  subtitle: Text(widget.currentUser.fullName),
                  trailing: TextButton(
                    onPressed: _showEditNameDialog,
                    child: const Text('Edit'),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(widget.currentUser.email),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20.0),

        // Pengaturan Tampilan
        Card(
          margin: const EdgeInsets.only(right: 24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appearance', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: isDarkMode,
                  onChanged: (value) => widget.toggleTheme(),
                  secondary: Icon(isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20.0),

        // Tombol Logout
        Card(
          margin: const EdgeInsets.only(right: 24),
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: widget.onLogout,
          ),
        ),
      ],
    );
  }
}
