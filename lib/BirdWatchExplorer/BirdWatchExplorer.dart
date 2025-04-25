import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:url_launcher/url_launcher.dart';

class BirdHotspot {
  final String id;
  final String country;
  final String state;
  final String county;
  final double latitude;
  final double longitude;
  final String name;
  final String lastObservation;
  final int totalSpecies;

  BirdHotspot({
    required this.id,
    required this.country,
    required this.state,
    required this.county,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.lastObservation,
    required this.totalSpecies,
  });
}

class BirdWatchExplorer extends StatefulWidget {
  @override
  _BirdWatchExplorerState createState() => _BirdWatchExplorerState();
}

class _BirdWatchExplorerState extends State<BirdWatchExplorer> {
  Position? _currentPosition;
  List<dynamic> _recentSightings = [];
  List<BirdHotspot> _birdHotspots = [];
  double _searchRadius = 10.0;
  MapController _mapController = MapController();
  double? customLat;
  double? customLong;
  bool _useCustomLocation = false;
  TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //_mapController = MapController(); // Initialize here
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
      customLat = _currentPosition?.latitude;
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: "Enter a location...",
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: _searchLocation,
            child: Text("Find"),
          ),
        ],
      ),
    );
  }

  Future<void> _searchLocation() async {
    String location = _locationController.text;
    if (location.isEmpty) return;

    String url =
        "https://nominatim.openstreetmap.org/search?q=$location&format=json";

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data.isNotEmpty) {
        double lat = double.parse(data[0]["lat"]);
        double lng = double.parse(data[0]["lon"]);

        _useCustomLocation = true;

        setState(() {
          customLat = lat;
          customLong = lng;
        });


        _fetchBirdData();
      } else {
        print("Location not found");
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      if (mounted) {
        Future.delayed(Duration(milliseconds: 500), () {
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            15.0, // Zoom level
          );
        });
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  // 🌟 Parses CSV response
  List<BirdHotspot> parseCsvResponse(String csvData) {
    List<List<dynamic>> csvTable = const CsvToListConverter(
      eol: "\n",
      fieldDelimiter: ",",
      shouldParseNumbers: false, // Prevents misinterpretation of numbers
    ).convert(csvData);

    List<BirdHotspot> hotspots = [];

    for (var row in csvTable) {
      if (row.length < 9) continue; // Skip incomplete or malformed rows

      hotspots.add(BirdHotspot(
        id: row[0].toString(),
        country: row[1].toString(),
        state: row[2].toString(),
        county: row[3].toString(),
        latitude: double.tryParse(row[4].toString()) ?? 0.0,
        longitude: double.tryParse(row[5].toString()) ?? 0.0,
        name: row[6].toString(),
        lastObservation: row[7].toString(),
        totalSpecies: int.tryParse(row[8].toString()) ?? 0,
      ));
    }

    return hotspots;
  }

  double _selectedRadius = 10.0; // Default radius value

  Future<void> _fetchBirdData() async {
    double latitude =
        _useCustomLocation ? customLat ?? 0 : (_currentPosition?.latitude ?? 0);
    double longitude = _useCustomLocation
        ? customLong ?? 0
        : (_currentPosition?.longitude ?? 0);

    String apiKey = "lv9ldei00jf0";

    String sightingsUrl =
        "https://api.ebird.org/v2/data/obs/geo/recent?lat=$latitude&lng=$longitude&dist=${_selectedRadius}";
    String hotspotsUrl =
        "https://api.ebird.org/v2/ref/hotspot/geo?lat=$latitude&lng=$longitude&dist=${_selectedRadius}";

    try {
      final sightingsResponse = await http
          .get(Uri.parse(sightingsUrl), headers: {'X-eBirdApiToken': apiKey});
      final hotspotsResponse = await http
          .get(Uri.parse(hotspotsUrl), headers: {'X-eBirdApiToken': apiKey});

      if (sightingsResponse.statusCode == 200) {
        setState(() {
          _recentSightings = json.decode(sightingsResponse.body);
        });
      }

      if (hotspotsResponse.statusCode == 200) {
        List<BirdHotspot> hotspots = parseCsvResponse(hotspotsResponse.body);
        setState(() {
          _birdHotspots = hotspots;
        });
      }

       _mapController.move(
            LatLng(latitude, longitude),
            15.0, // Zoom level
          );


    } catch (e) {
      print("Error fetching bird data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BirdWatch Explorer",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchBirdData,
          ),
        ],
      ),
      body:
       Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.blue[50]!],
          ),
        ),
        
        child: Column(
          children: [
            _buildSearchBar(),
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _useCustomLocation
                        ? LatLng(customLat??0, customLong??0) // Use custom location if set
                        : _currentPosition != null
                            ? LatLng(_currentPosition!.latitude,
                                _currentPosition!.longitude)
                            : LatLng(20.5937, 78.9629), // Default to India
                    initialZoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.birdz',
                    ),
                    // Show marker for the selected location
                    if (_useCustomLocation )
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 50,
                            height: 50,
                            point: LatLng(customLat??0, customLong??0),
                            child: Icon(Icons.location_pin,
                                color: Colors.blue, size: 40),
                          ),
                        ],
                      )
                    else if (_currentPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 50,
                            height: 50,
                            point: LatLng(_currentPosition!.latitude,
                                _currentPosition!.longitude),
                            child: Icon(Icons.location_pin,
                                color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 20),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.green[200],
                            thumbColor: Colors.green,
                            overlayColor: Colors.green.withAlpha(0x28),
                          ),
                          child: Slider(
                            value: _selectedRadius,
                            min: 1,
                            max: 50,
                            divisions: 49,
                            activeColor: Colors.green,
                            inactiveColor: Colors.grey[300],
                            onChanged: (double value) {
                              setState(() {
                                _selectedRadius = value;
                              });
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text("${_searchRadius.toStringAsFixed(0)} km",
                            style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: Icon(Icons.search, size: 24),
                    label: Text("Find Birds Nearby",
                        style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      _useCustomLocation = false;
                      _fetchBirdData();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      indicatorColor: Colors.green[800],
                      labelColor: Colors.green[800],
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(
                            text:
                                "Recent Sightings (${_recentSightings.length})"),
                        Tab(text: "Hotspots (${_birdHotspots.length})"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildSightingsList(),
                          _buildHotspotsList(_birdHotspots),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
      ),
    );
  }

  Widget _buildSightingsList() {
    if (_recentSightings.isEmpty) {
      return Center(
        child: Text(
          "No recent sightings found.",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      itemCount: _recentSightings.length,
      itemBuilder: (context, index) {
        final sighting = _recentSightings[index];

        String formattedDate = _formatDate(sighting["obsDt"]);
        String location = sighting["locName"];
        int count = sighting["howMany"] ?? 1;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            leading: Icon(Icons.air, color: Colors.green[700], size: 30),
            title: Text(
              sighting["comName"],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sighting["sciName"],
                    style: TextStyle(fontStyle: FontStyle.italic)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.place, color: Colors.redAccent, size: 18),
                    SizedBox(width: 5),
                    GestureDetector(
                      onTap: () =>
                          _openGoogleMaps(sighting["lat"], sighting["lng"]),
                      child: Text(
                        location,
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                    SizedBox(width: 5),
                    Text(formattedDate,
                        style: TextStyle(color: Colors.black87)),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.confirmation_number,
                        color: Colors.orange, size: 16),
                    SizedBox(width: 5),
                    Text("Count: $count",
                        style: TextStyle(color: Colors.black87)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Open location in Google Maps
  void _openGoogleMaps(double lat, double lng) {
    String url = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    launchUrl(Uri.parse(url));
  }

  Widget _buildHotspotsList(List<BirdHotspot> hotspots) {
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: hotspots.length,
      itemBuilder: (context, index) {
        final hotspot = hotspots[index];

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotspot.name,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900]),
                ),
                SizedBox(height: 6),
                _buildInfoRow(Icons.calendar_today,
                    "Observed on: ${hotspot.lastObservation}"),
                _buildInfoRow(Icons.info_outline,
                    "${hotspot.totalSpecies} species observed"),
                _buildInfoRow(Icons.location_on,
                    "Lat: ${hotspot.latitude}, Lng: ${hotspot.longitude}"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.black87)),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.parse(dateString);
    return "${date.day}/${date.month}/${date.year}";
  }
}
