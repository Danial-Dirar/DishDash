import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/app_drawer.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  GoogleMapController? mapController;
  Location location = Location();
  LatLng? currentLocation;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    var locData = await location.getLocation();
    setState(() {
      currentLocation = LatLng(locData.latitude!, locData.longitude!);
    });
    _fetchCompanies();
  }

  Future<void> _fetchCompanies() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('companies')
        .get();
    final Set<Marker> loadedMarkers = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final lat = (data['lat'] ?? 0).toDouble();
      final lon = (data['lon'] ?? 0).toDouble();
      final name = data['name'] ?? 'Company';

      final marker = Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(lat, lon),
        infoWindow: InfoWindow(
          title: name,
          snippet: 'Tap to view offers',
          onTap: () {
            _showOffersDialog(doc.id, name);
          },
        ),
      );

      loadedMarkers.add(marker);
    }

    setState(() {
      markers = loadedMarkers;
    });
  }

  void _showOffersDialog(String companyId, String companyName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .collection('offers')
        .orderBy('createdAt', descending: true)
        .get();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Offers from $companyName'),
        content: SizedBox(
          width: double.maxFinite,
          child: snapshot.docs.isEmpty
              ? const Text('No offers available.')
              : ListView(
                  children: snapshot.docs.map((doc) {
                    final data = doc.data();
                    return ListTile(
                      title: Text(data['title'] ?? 'No title'),
                      subtitle: Text(data['description'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.bookmark_add_outlined),
                        onPressed: () async {
                          final userId = FirebaseAuth.instance.currentUser?.uid;
                          if (userId != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('saved_offers')
                                .doc(doc.id)
                                .set({
                                  'title': data['title'],
                                  'description': data['description'],
                                  'companyId': companyId,
                                  'savedAt': Timestamp.now(),
                                });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Offer saved!')),
                            );
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DishDash'),
        backgroundColor: Colors.deepOrange,
      ),
      drawer: const AppDrawer(userType: 'user'),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: CameraPosition(
                target: currentLocation!,
                zoom: 13,
              ),
              myLocationEnabled: true,
              markers: markers,
            ),
    );
  }
}
