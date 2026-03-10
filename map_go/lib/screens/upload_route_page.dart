import 'package:flutter/material.dart';

class UploadRoutePage extends StatefulWidget {
  const UploadRoutePage({super.key});

  @override
  State<UploadRoutePage> createState() => _UploadRoutePageState();
}

class _UploadRoutePageState extends State<UploadRoutePage> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController distanceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String difficulty = "Easy";
  int rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        elevation: 0,
        title: const Text("Upload Route"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            const SizedBox(height: 10),

            const Text(
              "Route Name",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 8),

            _inputField(nameController, "Enter route name"),

            const SizedBox(height: 20),

            const Text(
              "Location",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 8),

            _inputField(locationController, "Enter location"),

            const SizedBox(height: 20),

            const Text(
              "Distance (km)",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 8),

            _inputField(distanceController, "Enter distance"),

            const SizedBox(height: 20),

            const Text(
              "Difficulty",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 8),

            _difficultyDropdown(),

            const SizedBox(height: 20),

            const Text(
              "Description",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 8),

            _descriptionField(),

            const SizedBox(height: 20),

            const Text(
              "Rating",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 8),

            _ratingBar(),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Later we connect to Firebase / database
                print("Route Uploaded");
              },
              child: const Text(
                "Upload Route",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1C1F26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _descriptionField() {
    return TextField(
      controller: descriptionController,
      maxLines: 4,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Describe the route...",
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1C1F26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _difficultyDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1F26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton(
        dropdownColor: const Color(0xFF1C1F26),
        value: difficulty,
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.white),
        items: ["Easy", "Moderate", "Hard"]
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            difficulty = value!;
          });
        },
      ),
    );
  }

  Widget _ratingBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            setState(() {
              rating = index + 1;
            });
          },
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
        );
      }),
    );
  }
}