import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:map_go/widgets/add_review_dialog.dart';
import 'package:map_go/widgets/review_tile.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteDetailPage extends StatefulWidget {
  final String routeId;

  const RouteDetailPage({super.key, required this.routeId});

  @override
  State<RouteDetailPage> createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends State<RouteDetailPage> {
  late Future<DocumentSnapshot> _routeFuture;

  @override
  void initState() {
    super.initState();
    _routeFuture =
        FirebaseFirestore.instance.collection('routes').doc(widget.routeId).get();
  }

  void _refreshRoute() {
    setState(() {
      _routeFuture =
          FirebaseFirestore.instance.collection('routes').doc(widget.routeId).get();
    });
  }

  void _launchMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _routeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text('Route not found.'));
          }

          var routeData = snapshot.data!.data() as Map<String, dynamic>;
          var reviews = (routeData['reviews'] as List<dynamic>?) ?? [];
          var photoUrls = (routeData['photos'] as List<dynamic>?) ?? [];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    routeData['name'] ?? 'Unnamed Route',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Address, Duration, Description
                  Text('Address: ${routeData['address'] ?? 'Not provided'}'),
                  Text('Duration: ${routeData['duration'] ?? 'Not provided'}'),
                  Text('Description: ${routeData['description'] ?? 'Not provided'}'),
                  const SizedBox(height: 20),

                  // Safety Rating
                  Row(
                    children: [
                      const Text('Safety Rating: '),
                      ...List.generate(5, (index) {
                        return Icon(
                          index < (routeData['safetyRating'] ?? 0)
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Photos
                  const Text(
                    'Photos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (photoUrls.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: photoUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.network(photoUrls[index]),
                          );
                        },
                      ),
                    )
                  else
                    const Text('Photos not uploaded'),
                  const SizedBox(height: 20),

                  // Reviews
                  const Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (reviews.isNotEmpty)
                    ...reviews.map((review) {
                      return ReviewTile(
                        userName: review['userName'] ?? 'Anonymous',
                        rating: review['rating'] ?? 0,
                        comment: review['comment'] ?? '',
                      );
                    }).toList()
                  else
                    const Text('No reviews yet. Be the first to write one!'),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.rate_review),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddReviewDialog(routeId: widget.routeId),
          ).then((_) => _refreshRoute());
        },
      ),
    );
  }
}
