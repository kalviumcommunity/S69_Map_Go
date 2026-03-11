import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_go/screens/profile_page.dart';
import 'package:map_go/screens/explore_routes.dart';
import 'package:map_go/screens/upload_route_page.dart';
//minor update to home page UI and added quick action buttons
class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? _currentPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enable location services")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission permanently denied")),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {

      _currentPosition = position;

      _markers.add(
        Marker(
          markerId: const MarkerId("me"),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: "My Location"),
        ),
      );

    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          "Hi, ${widget.user.displayName?.split(" ")[0] ?? "User"} 👋",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade800,
              backgroundImage: widget.user.photoURL != null
                  ? NetworkImage(widget.user.photoURL!)
                  : null,
              child: widget.user.photoURL == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          )
        ],
      ),

      drawer: Drawer(
        backgroundColor: const Color(0xFF1E1E1E),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black87),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  CircleAvatar(
                    radius: 28,
                    backgroundImage: widget.user.photoURL != null
                        ? NetworkImage(widget.user.photoURL!)
                        : null,
                    child: widget.user.photoURL == null
                        ? const Icon(Icons.person)
                        : null,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.user.displayName ?? "User",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),

                  Text(
                    widget.user.email ?? "",
                    style: const TextStyle(color: Colors.white70),
                  ),

                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.route, color: Colors.white),
              title: const Text("Start Route"),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    title: const Text("Coming Soon"),
                    content: const Text(
                      "Live route tracking is coming in a future update!",
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK", style: TextStyle(color: Color(0xFF4CAF50))),
                      ),
                    ],
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.cloud_upload, color: Colors.white),
              title: const Text("Upload Route"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UploadRoutePage(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.explore, color: Colors.white),
              title: const Text("Explore Routes"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExploreRoutesPage(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text("Profile Settings"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfilePage(),
                  ),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text("Log Out"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),

          ],
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              TextField(
                decoration: InputDecoration(
                  hintText: "Search routes or areas",
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

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _currentPosition == null
                        ? const Center(child: CircularProgressIndicator())
                        : GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                              zoom: 15,
                            ),
                            markers: _markers,
                            myLocationEnabled: true,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              _buildQuickActions(context),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionCard(
          context,
          Icons.route, "Start", () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                title: const Text("Coming Soon"),
                content: const Text(
                  "Live route tracking is coming in a future update!",
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK", style: TextStyle(color: Color(0xFF4CAF50))),
                  ),
                ],
              ),
            );
          }),
        _buildActionCard(
          context,
          Icons.upload, "Upload", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UploadRoutePage(),
              ),
            );
          }),
        _buildActionCard(
          context,
          Icons.explore, "Explore", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ExploreRoutesPage(),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildActionCard(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF1E1E1E),
            child: Icon(icon, size: 28, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}