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

  Future<void> pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<String?> uploadImage() async {
    if (imageFile == null) return profileImageUrl;

    final ref = FirebaseStorage.instance
        .ref()
        .child("profile_images")
        .child("${user.uid}.jpg");

    await ref.putFile(imageFile!);

    return await ref.getDownloadURL();
  }

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
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text("Profile Settings"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // PROFILE HEADER CARD
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                )
              ],
            ),

            child: Column(
              children: [

                Stack(
                  alignment: Alignment.bottomRight,
                  children: [

                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Colors.greenAccent,
                              Colors.tealAccent
                            ],
                          ),
                        ),

                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.black,
                          backgroundImage: imageFile != null
                              ? FileImage(imageFile!)
                              : profileImageUrl != null
                                  ? NetworkImage(profileImageUrl!)
                                  : null,
                          child: profileImageUrl == null && imageFile == null
                              ? const Icon(Icons.person, size: 45)
                              : null,
                        ),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.black,
                      ),
                    )

                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  nameController.text.isEmpty
                      ? "Your Name"
                      : nameController.text,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(
                  user.email ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),

              ],
            ),
          ),

          const SizedBox(height: 25),

          // NAME FIELD
          _inputCard(
            child: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // EMAIL
          _inputCard(
            child: TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: "Email",
                border: InputBorder.none,
                hintText: user.email,
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "User Type",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [

                RadioListTile(
                  activeColor: Colors.greenAccent,
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
                  activeColor: Colors.greenAccent,
                  value: "Cyclist",
                  groupValue: userType,
                  title: const Text("Cyclist"),
                  onChanged: (value) {
                    setState(() {
                      userType = value!;
                    });
                  },
                ),

              ],
            ),
          ),

          const SizedBox(height: 20),

          // BIO
          _inputCard(
            child: TextField(
              controller: bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Bio",
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // SAVE BUTTON
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: saveProfile,
              child: const Text(
                "Save Profile",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _inputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}