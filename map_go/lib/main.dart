import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Go',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          return HomePage(user: snapshot.data!);
        }
        return const LoginPage();
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/MapGo_Logo.png',
                height: 90,
              ),

              const SizedBox(height: 24),

              // App name
              const Text(
                'MapGo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Tagline
              const Text(
                'Find safer routes.\nRun & ride with confidence.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 40),

              // Google sign-in button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.black12),
                      ),
                      ),
                      child: const Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          ),
                          ),
                          ),
                          ),


              const SizedBox(height: 24),

              const Text(
                'By continuing, you agree to our Terms & Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class HomePage extends StatelessWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.8,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset(
              'assets/images/MapGo_Logo.png',
              height: 50,
            ),
      const SizedBox(width: 10),
      const Text(
        'MapGo',
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
      ),
    ],
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () async {
        await GoogleSignIn().signOut();
        await FirebaseAuth.instance.signOut();
      },
    ),
  ],
),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.displayName ?? 'User'} 👋',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Discover and share safe running & cycling routes',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 20),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search area (e.g. Indiranagar)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                _ActionCard(
                  icon: Icons.map,
                  label: 'Explore Routes',
                  onTap: () {
                    // TODO: Navigate to map screen
                  },
                ),
                const SizedBox(width: 12),
                _ActionCard(
                  icon: Icons.add_location_alt,
                  label: 'Upload Route',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UploadRoutePage(),
                        ),
                        );
                        },

                ),
              ],
            ),

            const SizedBox(height: 30),

            Text(
              'Popular Routes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: [
                  _RouteTile(
                    name: 'Cubbon Park Loop',
                    area: 'Bangalore',
                    rating: 4.8,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RouteDetailPage(),
                          ),
                          );
                          },
                          ),
                          _RouteTile(
                            name: 'MG Road Stretch',
                            area: 'Central Bangalore',
                            rating: 4.5,
                            onTap: () {},
                            ),
                            _RouteTile(
                              name: 'Indiranagar Streets',
                              area: 'Indiranagar',
                              rating: 4.2,
                              onTap: () {},
                              ),
                              ],
                              ),
                              ),

          ],
        ),
      ),
    );
  }
}

// ---------- ACTION CARD ----------

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- ROUTE TILE ----------

class _RouteTile extends StatelessWidget {
  final String name;
  final String area;
  final double rating;
  final VoidCallback onTap;

  const _RouteTile({
    required this.name,
    required this.area,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.route),
        title: Text(name),
        subtitle: Text(area),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(rating.toString()),
          ],
        ),
        onTap: onTap, 
      ),
    );
  }
}


// ================= ROUTE DETAIL PAGE =================

class RouteDetailPage extends StatelessWidget {
  const RouteDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cubbon Park Loop',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Bangalore • 4.8 ⭐',
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 24),

            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: const [
                  ReviewTile(
                    userName: 'Aditi',
                    rating: 5,
                    comment: 'Very safe and peaceful in the mornings.',
                  ),
                  ReviewTile(
                    userName: 'Rahul',
                    rating: 4,
                    comment: 'Good route, traffic increases after 8am.',
                  ),
                  ReviewTile(
                    userName: 'Neha',
                    rating: 5,
                    comment: 'Loved it! Well lit and clean.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.rate_review),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddReviewDialog(),
          );
        },
      ),
    );
  }
}

// ================= REVIEW TILE =================

class ReviewTile extends StatelessWidget {
  final String userName;
  final int rating;
  final String comment;

  const ReviewTile({
    super.key,
    required this.userName,
    required this.rating,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Row(
                  children: List.generate(
                    rating,
                    (_) => const Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment),
          ],
        ),
      ),
    );
  }
}

// ================= ADD REVIEW DIALOG =================

class AddReviewDialog extends StatelessWidget {
  const AddReviewDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Review'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Rate this route'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (_) => const Icon(Icons.star_border),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write your experience (optional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Later: connect to Firestore
            Navigator.pop(context);
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

// ================= UPLOAD ROUTE PAGE =================

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

              // Route name
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

              // Area
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

              // Distance
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

              // Safety rating
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
                      index < safetyRating
                          ? Icons.star
                          : Icons.star_border,
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

              // Submit button
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
