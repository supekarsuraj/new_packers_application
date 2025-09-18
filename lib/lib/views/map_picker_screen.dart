import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

const Color mediumBlue = Color(0xFF37b3e7);

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(19.0760, 72.8777); // Default to Mumbai
  LatLng _centerPosition = const LatLng(19.0760, 72.8777);
  String _currentAddress = "Loading...";
  String _detailedAddress = "";
  bool _isLoadingAddress = false;
  bool _mapLoaded = false;
  bool _locationPermissionGranted = false;
  Set<Marker> _markers = {};

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Location> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndInitialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissionsAndInitialize() async {
    if (kDebugMode) {
      print("MapPickerScreen: Checking permissions...");
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) {
        print("Location services are disabled");
      }
      setState(() {
        _currentAddress = "Location services disabled";
      });
      Fluttertoast.showToast(msg: "Please enable location services");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentAddress = "Location permission denied";
        });
        Fluttertoast.showToast(msg: "Location permission is required");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentAddress = "Location permission permanently denied";
      });
      Fluttertoast.showToast(msg: "Please enable location permission in settings");
      return;
    }

    setState(() {
      _locationPermissionGranted = true;
    });

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!_locationPermissionGranted) return;

    try {
      if (kDebugMode) {
        print("Getting current location...");
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (kDebugMode) {
        print("Location found: ${position.latitude}, ${position.longitude}");
      }

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _centerPosition = _currentPosition;
      });

      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentPosition, zoom: 18),
          ),
        );
      }

      _getAddressFromCoordinates(_currentPosition);
    } catch (e) {
      if (kDebugMode) {
        print("Error getting location: $e");
      }
      setState(() {
        _currentAddress = "Error getting location: $e";
      });
      Fluttertoast.showToast(msg: "Error getting current location");
    }
  }

  Future<void> _getAddressFromCoordinates(LatLng position) async {
    if (_isLoadingAddress) return;

    setState(() {
      _isLoadingAddress = true;
      _currentAddress = "Getting address...";
    });

    try {
      if (kDebugMode) {
        print("Getting address for: ${position.latitude}, ${position.longitude}");
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        localeIdentifier: "en_IN",
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        if (kDebugMode) {
          print("Address found: $place");
        }

        // Build main address (like "C/209, Raheja Vihar Circular Road")
        List<String> mainAddressParts = [];
        if (place.name != null && place.name!.isNotEmpty) {
          mainAddressParts.add(place.name!);
        }
        if (place.street != null && place.street!.isNotEmpty && place.street != place.name) {
          mainAddressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          mainAddressParts.add(place.subLocality!);
        }

        String mainAddress = mainAddressParts.isNotEmpty
            ? mainAddressParts.join(", ")
            : (place.locality ?? "Unknown location");

        // Build detailed address (like "Kandivali East, Mumbai, Maharashtra 400101")
        List<String> detailedParts = [];
        if (place.locality != null && place.locality!.isNotEmpty) {
          detailedParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          detailedParts.add(place.administrativeArea!);
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          detailedParts.add(place.postalCode!);
        }

        String detailed = detailedParts.isNotEmpty ? detailedParts.join(", ") : "";

        setState(() {
          _currentAddress = mainAddress;
          _detailedAddress = detailed;
          _isLoadingAddress = false;
        });
      } else {
        setState(() {
          _currentAddress = "Unknown location";
          _detailedAddress = "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting address: $e");
      }
      setState(() {
        _currentAddress = "Unknown location";
        _detailedAddress = "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}";
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng searchedPosition = LatLng(location.latitude, location.longitude);

        setState(() {
          _centerPosition = searchedPosition;
          _searchResults = locations;
        });

        if (_mapController != null) {
          await _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: searchedPosition, zoom: 18),
            ),
          );
        }

        _getAddressFromCoordinates(searchedPosition);

        // Update the search controller with the searched address
        _searchController.text = query;
      } else {
        Fluttertoast.showToast(msg: "Location not found");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Search error: $e");
      }
      Fluttertoast.showToast(msg: "Error searching location");
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _onCameraMove(CameraPosition position) {
    _centerPosition = position.target;
  }

  void _onCameraIdle() {
    if (kDebugMode) {
      print("Camera idle at: ${_centerPosition.latitude}, ${_centerPosition.longitude}");
    }
    _getAddressFromCoordinates(_centerPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 18, // Higher zoom for building details
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              setState(() {
                _mapLoaded = true;
              });
              if (kDebugMode) {
                print("Google Map created successfully");
              }
              _getAddressFromCoordinates(_currentPosition);
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: _locationPermissionGranted,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            buildingsEnabled: true, // Enable 3D buildings
            indoorViewEnabled: true,
            trafficEnabled: false,
            mapType: MapType.normal,
            minMaxZoomPreference: const MinMaxZoomPreference(1.0, 22.0), // Allow maximum zoom
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            markers: _markers,
          ),

          // Top search bar (like Google Maps)
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Search here",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (value) => _searchLocation(value),
                      onChanged: (value) {
                        // Optional: You can add real-time search suggestions here
                      },
                    ),
                  ),
                  if (_isSearching)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.black54),
                      onPressed: () => _searchLocation(_searchController.text),
                    ),
                ],
              ),
            ),
          ),

          // Center pin (medium blue location marker)
          Center(
            child: Container(
              height: 50,
              width: 30,
              alignment: Alignment.topCenter,
              child: Container(
                height: 30,
                width: 30,
                decoration: const BoxDecoration(
                  color: mediumBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          // Control buttons (like Google Maps)
          Positioned(
            right: 16,
            top: 120,
            child: Column(
              children: [
                // Layers button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.layers, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                // My location button
                if (_locationPermissionGranted)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.my_location, color: mediumBlue),
                      onPressed: _getCurrentLocation,
                    ),
                  ),
              ],
            ),
          ),

          // Loading indicator when map is loading
          if (!_mapLoaded)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Loading Map..."),
                  ],
                ),
              ),
            ),

          // Bottom address card (like Google Maps)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag indicator
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: mediumBlue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_isLoadingAddress)
                                    const Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                        SizedBox(width: 8),
                                        Text("Getting address..."),
                                      ],
                                    )
                                  else ...[
                                    Text(
                                      _currentAddress,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (_detailedAddress.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        _detailedAddress,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Add button with medium blue color
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (kDebugMode) {
                                print("Adding location: $_centerPosition");
                                print("Address: $_currentAddress");
                              }
                              String fullAddress = _currentAddress;
                              if (_detailedAddress.isNotEmpty) {
                                fullAddress += ", $_detailedAddress";
                              }
                              Navigator.pop(context, {
                                'coordinates': _centerPosition,
                                'address': fullAddress,
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mediumBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Add',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Safe area padding for bottom
                        SizedBox(height: MediaQuery.of(context).padding.bottom),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}