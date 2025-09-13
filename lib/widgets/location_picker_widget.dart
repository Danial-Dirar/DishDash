import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerWidget extends StatefulWidget {
  final Function(double, double) onLocationSelected;

  const LocationPickerWidget({super.key, required this.onLocationSelected});

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  LatLng? selectedLocation;
  late GoogleMapController mapController;

  void _onMapTap(LatLng position) {
    setState(() {
      selectedLocation = position;
    });
    widget.onLocationSelected(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(23.8103, 90.4125), // Dhaka
          zoom: 12,
        ),
        onTap: _onMapTap,
        markers:
            selectedLocation != null
                ? {
                  Marker(
                    markerId: const MarkerId('selected'),
                    position: selectedLocation!,
                  ),
                }
                : {},
        onMapCreated: (controller) => mapController = controller,
      ),
    );
  }
}
