import 'package:flutter/material.dart';
import 'package:location/location.dart';

class CurrentLocationPickerScreen extends StatefulWidget {
  const CurrentLocationPickerScreen({Key? key}) : super(key: key);

  @override
  _CurrentLocationPickerScreenState createState() => _CurrentLocationPickerScreenState();
}

class _CurrentLocationPickerScreenState extends State<CurrentLocationPickerScreen> {
  LocationData? _currentLocation;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });

    final location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

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
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
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
      _isFetchingLocation = false;
    });
  }

  void _confirmLocation() {
    if (_currentLocation != null) {
      Navigator.pop(context, _currentLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Current Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _confirmLocation,
          ),
        ],
      ),
      body: Center(
        child: _isFetchingLocation
            ? CircularProgressIndicator()
            : _currentLocation != null
                ? Text('Location: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}')
                : Text('Failed to get location'),
      ),
    );
  }
}
