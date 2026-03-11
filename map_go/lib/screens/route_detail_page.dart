import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  void _getDirections(double lat, double lng) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _routeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data?.data() == null) {
          return const Scaffold(
              body: Center(child: Text('Route not found.')));
        }

        var routeData = snapshot.data!.data() as Map<String, dynamic>;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 250.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: const Color(0xFF121212),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(routeData['name'] ?? 'Unnamed Route',
                          style: const TextStyle(fontSize: 16.0)),
                      background: _buildPhotoGallery(routeData),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      const TabBar(
                        tabs: [
                          Tab(text: 'Overview'),
                          Tab(text: 'Reviews'),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _buildOverviewTab(routeData),
                  _buildReviewsTab(routeData),
                ],
              ),
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
          ),
        );
      },
    );
  }

  Widget _buildPhotoGallery(Map<String, dynamic> routeData) {
    var photoUrls = (routeData['photos'] as List<dynamic>?)?.cast<String>().toList() ?? [];
    if (photoUrls.isEmpty) {
      return Container(
        color: Colors.grey[800],
        child: const Center(
          child: Icon(Icons.photo_camera, color: Colors.white, size: 50),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: photoUrls.length,
      itemBuilder: (BuildContext context, int index) => Image.network(
        photoUrls[index],
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildOverviewTab(Map<String, dynamic> routeData) {
    GeoPoint location = routeData['location'] ?? const GeoPoint(0, 0);
    LatLng position = LatLng(location.latitude, location.longitude);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  routeData['name'] ?? 'Unnamed Route',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Column(
                children: [
                  Text(
                    (routeData['safetyRating'] ?? 0.0).toStringAsFixed(1),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < (routeData['safetyRating'] ?? 0).round()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      );
                    }),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${routeData['routeType'] ?? 'N/A'} • ${routeData['address'] ?? 'No address'}',
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton(Icons.directions, 'Directions', () => _getDirections(position.latitude, position.longitude)),
              _actionButton(Icons.share, 'Share', () {}),
              _actionButton(Icons.bookmark_border, 'Save', () {}),
            ],
          ),
          const SizedBox(height: 24),

          // About
          const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            routeData['description'] ?? 'No description provided.',
            style: TextStyle(fontSize: 16, color: Colors.grey[300]),
          ),
          const SizedBox(height: 24),

          // Map
          SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: position, zoom: 14),
              markers: {Marker(markerId: MarkerId(widget.routeId), position: position)},
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
          const SizedBox(height: 24),

          // Details
          const Text('Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _detailRow('Distance', '${routeData['distance'] ?? 'N/A'} km'),
          _detailRow('Est. Duration', '${routeData['duration'] ?? 'N/A'}'),
          _detailRow('Uploaded by', routeData['createdBy'] ?? 'Anonymous'),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(icon, color: Colors.greenAccent), onPressed: onPressed),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.greenAccent)),
      ],
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[400])),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(Map<String, dynamic> routeData) {
    var reviews = (routeData['reviews'] as List<dynamic>?) ?? [];

    if (reviews.isEmpty) {
      return const Center(
        child: Text('No reviews yet. Be the first to write one!'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ReviewTile(
          userName: review['userName'] ?? 'Anonymous',
          rating: review['rating'] ?? 0,
          comment: review['comment'] ?? '',
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF121212),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

