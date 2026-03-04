import 'package:flutter/material.dart';

class UploadRoutePage extends StatefulWidget {
  const UploadRoutePage({super.key});

  @override
  State<UploadRoutePage> createState() => _UploadRoutePageState();
}

class _UploadRoutePageState extends State<UploadRoutePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController routeNameController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController distanceController = TextEditingController();

  int safetyRating = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Route'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Add a new route',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: routeNameController,
                decoration: const InputDecoration(
                  labelText: 'Route Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter route name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: areaController,
                decoration: const InputDecoration(
                  labelText: 'Area',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter area' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: distanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Distance (km)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter distance' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                'Safety Rating',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    icon: Icon(
                      index < safetyRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        safetyRating = index + 1;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Later: Save to Firestore

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Route uploaded successfully!'),
                        ),
                      );

                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Submit Route',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
