import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final bioController = TextEditingController();

  String userType = "Runner";
  String? profileImageUrl;

  File? imageFile;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // LOAD PROFILE FROM FIRESTORE
  Future<void> loadProfile() async {
    final doc =
        await firestore.collection("users").doc(user.uid).get();

    if (doc.exists) {
      final data = doc.data()!;

      setState(() {
        nameController.text = data["name"] ?? "";
        bioController.text = data["bio"] ?? "";
        userType = data["userType"] ?? "Runner";
        profileImageUrl = data["profileImage"];
      });
    }
  }

  // PICK IMAGE
  Future<void> pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  // UPLOAD IMAGE TO FIREBASE STORAGE
  Future<String?> uploadImage() async {
    if (imageFile == null) return profileImageUrl;

    final ref = FirebaseStorage.instance
        .ref()
        .child("profile_images")
        .child("${user.uid}.jpg");

    await ref.putFile(imageFile!);

    return await ref.getDownloadURL();
  }

  // SAVE PROFILE
  Future<void> saveProfile() async {
    final imageUrl = await uploadImage();

    await firestore.collection("users").doc(user.uid).set({
      "name": nameController.text,
      "email": user.email,
      "bio": bioController.text,
      "userType": userType,
      "profileImage": imageUrl
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Profile Saved")));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [

            // PROFILE IMAGE
            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: imageFile != null
                      ? FileImage(imageFile!)
                      : profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
                          : null,
                  child: profileImageUrl == null && imageFile == null
                      ? const Icon(Icons.camera_alt)
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // NAME
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // EMAIL
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: "Email",
                border: const OutlineInputBorder(),
                hintText: user.email,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "User Type",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            RadioListTile(
              value: "Runner",
              groupValue: userType,
              title: const Text("Runner"),
              onChanged: (value) {
                setState(() {
                  userType = value!;
                });
              },
            ),

            RadioListTile(
              value: "Cyclist",
              groupValue: userType,
              title: const Text("Cyclist"),
              onChanged: (value) {
                setState(() {
                  userType = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            // BIO
            TextField(
              controller: bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Bio",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: saveProfile,
              child: const Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }
}