import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapLocationScreen extends StatefulWidget {
  @override
  _MapLocationScreenState createState() => _MapLocationScreenState();
}

class _MapLocationScreenState extends State<MapLocationScreen> {
  MapController mapController = MapController();
  LatLng currentCenter = LatLng(31.5204, 74.3587);
  String selectedAddress = 'Move map to select location';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        currentCenter = LatLng(position.latitude, position.longitude);
      });

      mapController.move(currentCenter, 15.0);
      getAddressFromLatLng(currentCenter);

    } catch (e) {
      print('Error getting location: $e');
    }
  }


  Future<void> getAddressFromLatLng(LatLng position) async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          selectedAddress =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        backgroundColor: Color(0xFFE4002B),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: currentCenter,
              zoom: 15.0,
              onPositionChanged: (MapPosition position, bool hasGesture) {
                if (hasGesture && position.center != null) {
                  currentCenter = position.center!;
                  getAddressFromLatLng(currentCenter);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=WPOtzxomxHL6aGU4KNVn',
                userAgentPackageName: 'com.example.app',
              ),
            ],
          ),

          Center(
            child: Icon(
              Icons.location_on,
              size: 50,
              color: Color(0xFFE4002B),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: getCurrentLocation,
              child: Icon(Icons.my_location, color: Color(0xFFE4002B)),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isLoading
                        ? Text('Loading address...')
                        : Text(
                      selectedAddress,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'address': selectedAddress,
                          'latitude': currentCenter.latitude,
                          'longitude': currentCenter.longitude,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE4002B),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Confirm Location',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
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

