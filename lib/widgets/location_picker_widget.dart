import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// A tappable OpenStreetMap-based location picker.
///
/// Uses [flutter_map] with OpenStreetMap tiles, so it needs no Google Maps
/// API key or billing account. Tapping the map drops a marker and reports the
/// selected coordinates back through [onLocationSelected].
class LocationPickerWidget extends StatefulWidget {
  final void Function(double latitude, double longitude) onLocationSelected;

  /// Optional starting point for the marker (e.g. when editing an existing
  /// location). Defaults to central Dhaka.
  final LatLng? initialLocation;

  const LocationPickerWidget({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  static const LatLng _dhaka = LatLng(23.8103, 90.4125);

  final MapController _mapController = MapController();
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  void _onMapTap(LatLng position) {
    setState(() => _selectedLocation = position);
    widget.onLocationSelected(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 300,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _selectedLocation ?? _dhaka,
            initialZoom: 12,
            onTap: (tapPosition, point) => _onMapTap(point),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.dish_dash',
            ),
            if (_selectedLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation!,
                    width: 44,
                    height: 44,
                    alignment: Alignment.topCenter,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 44,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
