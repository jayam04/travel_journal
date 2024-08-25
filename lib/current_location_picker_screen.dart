import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart' as loc;

class CurrentLocationPickerScreen extends StatefulWidget {
  const CurrentLocationPickerScreen({Key? key}) : super(key: key);

  @override
  _CurrentLocationPickerScreenState createState() =>
      _CurrentLocationPickerScreenState();
}

class _CurrentLocationPickerScreenState
    extends State<CurrentLocationPickerScreen> {
  loc.LocationData? _currentLocation;
  bool _isFetchingLocation = false;
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });

    final location = loc.Location();
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _isFetchingLocation = false;
        });
        return;
      }
    }

    // Check for location permission
    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        setState(() {
          _isFetchingLocation = false;
        });
        return;
      }
    }

    // Get the current location
    final locationData = await location.getLocation();

    setState(() {
      _currentLocation = locationData;
      _pickedLocation = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );
      _isFetchingLocation = false;
    });
  }

  void _confirmLocation() {
    if (_pickedLocation != null) {
      Navigator.pop(context, _pickedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a location.')),
      );
    }
  }

  Future<void> _searchLocation(String query) async {
    try {
      List<geo.Location> locations = await geo.locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(location.latitude, location.longitude),
          ),
        );
        setState(() {
          _pickedLocation = LatLng(location.latitude, location.longitude);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not found.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick a Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _confirmLocation,
          ),
        ],
      ),
      body: _isFetchingLocation
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Location',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          _searchLocation(_searchController.text);
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      _searchLocation(value);
                    },
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _pickedLocation ?? LatLng(0, 0),
                      zoom: 15,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    markers: _pickedLocation != null
                        ? {
                            Marker(
                              markerId: MarkerId('picked-location'),
                              position: _pickedLocation!,
                            ),
                          }
                        : {},
                    onTap: (location) {
                      setState(() {
                        _pickedLocation = location;
                      });
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
