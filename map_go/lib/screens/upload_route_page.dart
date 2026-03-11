import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UploadRoutePage extends StatefulWidget {
  const UploadRoutePage({super.key});

  @override
  State<UploadRoutePage> createState() => _UploadRoutePageState();
}

class _UploadRoutePageState extends State<UploadRoutePage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final distanceController = TextEditingController();
  final descriptionController = TextEditingController();

  String routeType = "Runner";
  String difficulty = "Easy";
  int safetyRating = 0;
  bool _isUploading = false;

  Future<void> _uploadRoute() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("You must be logged in to upload a route.");

      final Map<String, dynamic> data = {
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'distance': distanceController.text.trim(),
        'description': descriptionController.text.trim(),
        'routeType': routeType,
        'difficulty': difficulty,
        'safetyRating': safetyRating,
        'createdBy': user.displayName ?? 'Anonymous',
        'createdAt': FieldValue.serverTimestamp(),
        'reviews': [],
        'photos': [],
      };

      await FirebaseFirestore.instance
          .collection('routes')
          .add(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Route uploaded successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload route: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        elevation: 0,
        title: const Text("Upload New Route"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(nameController, "Route Name"),
            _buildTextField(addressController, "Address / General Location"),
            _buildTextField(distanceController, "Distance (e.g., 5 km)"),
            _buildDropdown<String>(
              label: "Route Type",
              value: routeType,
              items: ["Runner", "Cyclist", "Both"],
              onChanged: (value) => setState(() => routeType = value!),
            ),
            _buildDropdown<String>(
              label: "Difficulty",
              value: difficulty,
              items: ["Easy", "Moderate", "Hard"],
              onChanged: (value) => setState(() => difficulty = value!),
            ),
            _buildRatingBar(),
            _buildTextField(descriptionController, "Description", maxLines: 4),
            const SizedBox(height: 30),
            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _uploadRoute,
                    child: const Text(
                      "Upload Route",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1C1F26),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown<T>(
      {required String label,
      required T value,
      required List<T> items,
      required ValueChanged<T?> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString()),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1C1F26),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        dropdownColor: const Color(0xFF1C1F26),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildRatingBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Safety Rating", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => safetyRating = index + 1),
                icon: Icon(
                  index < safetyRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}