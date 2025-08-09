import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GuestViewScreen extends StatefulWidget {
  const GuestViewScreen({Key? key}) : super(key: key);

  @override
  State<GuestViewScreen> createState() => _GuestViewScreenState();
}

class _GuestViewScreenState extends State<GuestViewScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadCompanyMarkers();
  }

  Future<void> _loadCompanyMarkers() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('companies')
        .get();
    final List<Marker> markers = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final String name = data['name'] ?? 'Unnamed';
      final double lat = (data['lat'] ?? 0).toDouble();
      final double lon = (data['lon'] ?? 0).toDouble();

      markers.add(
        Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(lat, lon),
          infoWindow: InfoWindow(
            title: name,
            onTap: () {
              _showOffersDialog(doc.id, name);
            },
          ),
        ),
      );
    }

    setState(() {
      _markers.addAll(markers);
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
      builder: (context) {
        return AlertDialog(
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
                      );
                    }).toList(),
                  ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browse as Guest')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(23.8103, 90.4125), // Centered on Dhaka
          zoom: 12,
        ),
        markers: _markers,
        onMapCreated: (controller) => _mapController = controller,
      ),
    );
  }
}
