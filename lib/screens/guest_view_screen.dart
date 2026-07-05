import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Guest browsing screen: shows all registered companies as markers on an
/// OpenStreetMap map. Tapping a marker shows that company's offers.
class GuestViewScreen extends StatefulWidget {
  const GuestViewScreen({super.key});

  @override
  State<GuestViewScreen> createState() => _GuestViewScreenState();
}

class _GuestViewScreenState extends State<GuestViewScreen> {
  static const LatLng _dhaka = LatLng(23.8103, 90.4125);

  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanyMarkers();
  }

  Future<void> _loadCompanyMarkers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('companies').get();

      final markers = <Marker>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final name = (data['name'] ?? 'Unnamed').toString();
        final lat = (data['lat'] ?? 0).toDouble();
        final lon = (data['lon'] ?? 0).toDouble();
        if (lat == 0 && lon == 0) continue; // skip companies without a location

        markers.add(
          Marker(
            point: LatLng(lat, lon),
            width: 44,
            height: 44,
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () => _showOffersDialog(doc.id, name),
              child: const Icon(
                Icons.restaurant,
                color: Colors.red,
                size: 40,
              ),
            ),
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _markers
          ..clear()
          ..addAll(markers);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load companies: $e')),
      );
    }
  }

  Future<void> _showOffersDialog(String companyId, String companyName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .collection('offers')
        .orderBy('createdAt', descending: true)
        .get();

    if (!mounted) return;
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
                    shrinkWrap: true,
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
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
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _dhaka,
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.dish_dash',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          if (_loading)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Loading restaurants…'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
