import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:map_go/widgets/route_tile.dart';
import 'package:map_go/screens/route_detail_page.dart';

class ExploreRoutesPage extends StatelessWidget {
  const ExploreRoutesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text("Explore Routes"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // SEARCH BAR
            TextField(
              decoration: InputDecoration(
                hintText: "Search routes...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "All Routes",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("routes")
                    .snapshots(),

                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // SHOW DEMO ROUTES IF DATABASE EMPTY
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {

                    final demoRoutes = [
                      {"name": "Cubbon Park Loop", "area": "Bangalore", "rating": 4.8},
                      {"name": "MG Road Stretch", "area": "Central Bangalore", "rating": 4.5},
                      {"name": "Indiranagar Streets", "area": "Indiranagar", "rating": 4.2},
                    ];

                    return ListView.builder(
                      itemCount: demoRoutes.length,
                      itemBuilder: (context, index) {

                        final route = demoRoutes[index];

                        return RouteTile(
                          name: route["name"] as String,
                          area: route["area"] as String,
                          rating: route["rating"] as double,
                          onTap: () {},
                        );

                      },
                    );
                  }

                  final routes = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: routes.length,
                    itemBuilder: (context, index) {

                      final route = routes[index];

                      return RouteTile(
                        name: route["name"],
                        area: route["area"],
                        rating: (route["rating"] as num).toDouble(),
                        onTap: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RouteDetailPage(
                                routeId: route.id,
                              ),
                            ),
                          );

                        },
                      );

                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}