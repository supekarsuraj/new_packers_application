import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(19.0760, 72.8777); // Default to Mumbai

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _currentPosition, zoom: 15)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 15),
            onMapCreated: (controller) => _mapController = controller,
          ),
          const Center(
            child: Icon(Icons.location_pin, color: Colors.red, size: 40),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_mapController != null) {
            final int centerX = (MediaQuery.of(context).size.width / 2).toInt();
            final int centerY = (MediaQuery.of(context).size.height / 2).toInt();
            final position = await _mapController!.getLatLng(ScreenCoordinate(x: centerX, y: centerY));
            Navigator.pop(context, position);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}