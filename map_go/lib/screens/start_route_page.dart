import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StartRoutePage extends StatefulWidget {
  const StartRoutePage({super.key});

  @override
  State<StartRoutePage> createState() => _StartRoutePageState();
}

class _StartRoutePageState extends State<StartRoutePage> {

  String mode = "Runner";
  Map<String, dynamic>? selectedRoute;

  Future<void> startNavigation() async {

    if (selectedRoute == null) return;

    final lat = selectedRoute!["lat"];
    final lng = selectedRoute!["lng"];

    final Uri url = Uri.parse(
      "google.navigation:q=$lat,$lng",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Start Route"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Select Mode",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Row(
              children: [

                ChoiceChip(
                  label: const Text("Runner"),
                  selected: mode == "Runner",
                  onSelected: (_) {
                    setState(() {
                      mode = "Runner";
                    });
                  },
                ),

                const SizedBox(width: 10),

                ChoiceChip(
                  label: const Text("Cyclist"),
                  selected: mode == "Cyclist",
                  onSelected: (_) {
                    setState(() {
                      mode = "Cyclist";
                    });
                  },
                ),

              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Available Routes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("routes")
                    .snapshots(),

                builder: (context, snapshot) {

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // DEMO ROUTES IF DATABASE EMPTY
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {

                    final demoRoutes = [

                      {
                        "name": "Cubbon Park Loop",
                        "area": "Bangalore",
                        "rating": 4.8,
                        "lat": 12.9716,
                        "lng": 77.5946
                      },

                      {
                        "name": "MG Road Stretch",
                        "area": "Central Bangalore",
                        "rating": 4.5,
                        "lat": 12.9755,
                        "lng": 77.6060
                      },

                      {
                        "name": "Indiranagar Streets",
                        "area": "Indiranagar",
                        "rating": 4.2,
                        "lat": 12.9719,
                        "lng": 77.6412
                      },

                    ];

                    return ListView.builder(
                      itemCount: demoRoutes.length,
                      itemBuilder: (context, index) {

                        final route = demoRoutes[index];

                        return Card(
                          color: const Color(0xFF1E1E1E),

                          child: ListTile(

                            title: Text(route["name"].toString()),
                            subtitle: Text(route["area"].toString()),

                            trailing: Text(
                              "⭐ ${route["rating"].toString()}",
                            ),

                            selected: selectedRoute == route,

                            onTap: () {
                              setState(() {
                                selectedRoute = route;
                              });
                            },

                          ),
                        );

                      },
                    );
                  }

                  final routes = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: routes.length,
                    itemBuilder: (context, index) {

                      final route = routes[index].data()
                      as Map<String, dynamic>;

                      return Card(
                        color: const Color(0xFF1E1E1E),

                        child: ListTile(

                          title: Text(route["name"]),
                          subtitle: Text(route["area"]),

                          trailing: Text(
                            "⭐ ${route["rating"]}",
                          ),

                          selected: selectedRoute == route,

                          onTap: () {
                            setState(() {
                              selectedRoute = route;
                            });
                          },

                        ),
                      );

                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: startNavigation,

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),

                child: const Text("Start Navigation"),

              ),
            ),

          ],
        ),
      ),
    );
  }
}