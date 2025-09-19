// File: lib/user_list_page.dart
import 'package:flutter/material.dart';
import 'user_model.dart';
import 'dart:io';

class UserListPage extends StatelessWidget {
  final List<User> users;

  const UserListPage({super.key, required this.users});

  // Fungsi untuk mendapatkan background image dengan SANGAT aman
  ImageProvider? _getProfileImage(User user) {
    if (user.profileImagePath != null && user.profileImagePath!.isNotEmpty) {
      try {
        final file = File(user.profileImagePath!);
        if (file.existsSync()) {
          return FileImage(file);
        }
      } catch (e) {
        // Jika terjadi error saat mengakses file (mis. izin, path salah),
        // jangan lakukan apa-apa dan kembalikan null.
        // print("Error loading image: $e"); // Untuk debug
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 0, 24), // Match HomePage padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Management',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Total ${users.length} users registered in the system.',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final profileImage = _getProfileImage(user);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12, right: 24), // Add right margin
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: profileImage,
                      backgroundColor: theme.colorScheme.primary.withAlpha(51),
                      child: profileImage == null
                          ? Text(
                              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    title: Text(
                      user.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                    ),
                    subtitle: Text(user.email, style: theme.textTheme.bodySmall),
                    trailing: user.isAdmin
                        ? Chip(
                            avatar: Icon(Icons.shield, size: 16, color: theme.colorScheme.primary),
                            label: const Text('Admin'),
                            backgroundColor: theme.colorScheme.primary.withAlpha(26),
                            side: BorderSide.none,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
