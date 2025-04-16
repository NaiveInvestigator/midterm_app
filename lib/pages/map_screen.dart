import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'image_page.dart'; // Import your ImagePage for navigation

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _center = LatLng(23.6850, 90.3563); // Center the map over Bangladesh
  double _zoom = 7;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _fetchMarkers();
  }

  Future<void> _fetchMarkers() async {
    final response = await http.get(
      Uri.parse('https://labs.anontech.info/cse489/t3/api.php'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<Marker> fetchedMarkers = [];

      for (var item in data) {
        try {
          double lat =
              item['lat'].toDouble(); // Attempt to convert lat to double
          double lon =
              item['lon'].toDouble(); // Attempt to convert lon to double

          fetchedMarkers.add(
            Marker(
              point: LatLng(lat, lon),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  // Show the details in a modal bottom sheet when a marker is tapped
                  _showDetails(item['title'], item['image']);
                },
                child: Image(
                  image: AssetImage('assets/marker.png'),
                ), // Marker icon
              ),
            ),
          );
        } catch (e) {
          // If conversion fails, just skip the marker
          print('Skipping marker due to invalid coordinates: $e');
          continue; // Skip this marker and move to the next
        }
      }

      setState(() {
        _markers = fetchedMarkers;
      });
    } else {
      throw Exception('Failed to load markers');
    }
  }

  // Function to show a bottom sheet with the marker's details
  void _showDetails(String title, String image) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image of the marker
                GestureDetector(
                  onTap: () {
                    // When image is tapped, navigate to the new page with title and image URL
                    _navigateToImagePage(title, image);
                  },
                  child: Image.network(
                    'https://labs.anontech.info/cse489/t3/$image', // Modify this URL if needed
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                ),
                SizedBox(height: 16),
                // Title of the marker
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to navigate to the image page with title and image URL
  void _navigateToImagePage(String title, String image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ImagePage(
              imageUrl: 'https://labs.anontech.info/cse489/t3/$image',
              title: title,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(initialCenter: _center, initialZoom: _zoom),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: _markers, // Display markers fetched from the API
          ),
        ],
      ),
    );
  }
}
