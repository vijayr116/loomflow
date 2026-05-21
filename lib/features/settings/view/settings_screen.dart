import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loomflow/features/settings/settings_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? selectedImage;

  final repository = SettingsRepository();
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final file = File(picked.path);

    setState(() {
      selectedImage = file;
    });

    await repository.uploadProfileImage(file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ================= PROFILE SECTION =================
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickImage,

                    child: CircleAvatar(
                      radius: 55,

                      backgroundImage: selectedImage != null
                          ? FileImage(selectedImage!)
                          : null,

                      child: selectedImage == null
                          ? const Icon(Icons.person, size: 55)
                          : null,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    currentUser?.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    currentUser?.email ?? '',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(.1),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: const Text(
                      "Admin",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // ================= APPEARANCE =================
            const Text(
              "Appearance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Card(
              child: SwitchListTile(
                value: false,
                onChanged: (value) {},
                title: const Text("Dark Mode"),
                secondary: const Icon(Icons.dark_mode),
              ),
            ),

            const SizedBox(height: 25),

            // ================= ACCOUNT =================
            const Text(
              "Account",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Edit Profile"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {},
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.lock),
                title: const Text("Change Password"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {},
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ),

            const SizedBox(height: 20),

            // ================= APP INFO =================
            Center(
              child: Text(
                "LoomFlow v1.0.0",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
