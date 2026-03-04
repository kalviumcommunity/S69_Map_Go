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
          var photoUrl = (routeData['photos'] as List<dynamic>?)?.first;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                      image: photoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(photoUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: photoUrl == null
                        ? const Center(child: Text('No Photos Available'))
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Name and Directions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              routeData['name'] ?? 'Unnamed Route',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  '${routeData['rating']?.toStringAsFixed(1) ?? 'N/A'} (${reviews.length} reviews)',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final location = routeData['location'] as GeoPoint?;
                          if (location != null) {
                            _launchMaps(location.latitude, location.longitude);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Text('Directions'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Comments
                  const Text(
                    'Comments',
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
                    const Text('No comments yet.'),
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
          );
        },
      ),
    );
  }
}
