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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
      customLat = _currentPosition?.latitude;
    });
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: "Search for a location...",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.green[700]),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.my_location, color: Colors.green[700]),
              onPressed: () {
                _locationController.clear();
                _useCustomLocation = false;
                _getCurrentLocation().then((_) => _fetchBirdData());
              },
            ),
            IconButton(
              icon: Icon(Icons.search, color: Colors.green[700]),
              onPressed: _searchLocation,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchLocation() async {
    String location = _locationController.text;
    if (location.isEmpty) return;

    setState(() => _isLoading = true);
    
    String url = "https://nominatim.openstreetmap.org/search?q=$location&format=json";

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);

      if (data.isNotEmpty) {
        double lat = double.parse(data[0]["lat"]);
        double lng = double.parse(data[0]["lon"]);

        setState(() {
          _useCustomLocation = true;
          customLat = lat;
          customLong = lng;
        });

        await _fetchBirdData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location not found"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching location"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enable location services"), backgroundColor: Colors.red),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permissions are permanently denied"), backgroundColor: Colors.red),
        );
        return;
      }
    }

    try {
      setState(() => _isLoading = true);
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
            15.0,
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<BirdHotspot> parseCsvResponse(String csvData) {
    List<List<dynamic>> csvTable = const CsvToListConverter(
      eol: "\n",
      fieldDelimiter: ",",
      shouldParseNumbers: false,
    ).convert(csvData);

    List<BirdHotspot> hotspots = [];

    for (var row in csvTable) {
      if (row.length < 9) continue;

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

  double _selectedRadius = 10.0;

  Future<void> _fetchBirdData() async {
    setState(() => _isLoading = true);
    
    double latitude = _useCustomLocation ? customLat ?? 0 : (_currentPosition?.latitude ?? 0);
    double longitude = _useCustomLocation ? customLong ?? 0 : (_currentPosition?.longitude ?? 0);

    String apiKey = "lv9ldei00jf0";

    String sightingsUrl = "https://api.ebird.org/v2/data/obs/geo/recent?lat=$latitude&lng=$longitude&dist=${_selectedRadius}";
    String hotspotsUrl = "https://api.ebird.org/v2/ref/hotspot/geo?lat=$latitude&lng=$longitude&dist=${_selectedRadius}";

    try {
      final sightingsResponse = await http.get(Uri.parse(sightingsUrl), headers: {'X-eBirdApiToken': apiKey});
      final hotspotsResponse = await http.get(Uri.parse(hotspotsUrl), headers: {'X-eBirdApiToken': apiKey});

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
        15.0,
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching bird data"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 300,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text("BirdWatch Explorer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                background: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _useCustomLocation
                            ? LatLng(customLat??0, customLong??0)
                            : _currentPosition != null
                                ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                                : LatLng(20.5937, 78.9629),
                        initialZoom: 12,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.birdz',
                        ),
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: _useCustomLocation
                                  ? LatLng(customLat ?? 0, customLong ?? 0)
                                  : _currentPosition != null
                                      ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                                      : LatLng(0, 0),
                              color: Colors.green.withOpacity(0.3),
                              borderStrokeWidth: 2,
                              borderColor: Colors.green,
                              radius: _selectedRadius * 1000, // Convert km to meters
                            ),
                          ],
                        ),
                        if (_useCustomLocation)
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 50,
                                height: 50,
                                point: LatLng(customLat ?? 0, customLong ?? 0),
                                child: Icon(Icons.location_pin, color: Colors.blue, size: 40),
                              ),
                            ],
                          )
                        else if (_currentPosition != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 50,
                                height: 50,
                                point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                              ),
                            ],
                          ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.green))
            : Column(
                children: [
                  _buildSearchBar(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text("Search Radius: ", style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
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
                                    // Trigger map update to reflect the new radius
                                    _mapController.move(
                                      _useCustomLocation
                                          ? LatLng(customLat ?? 0, customLong ?? 0)
                                          : _currentPosition != null
                                              ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                                              : LatLng(0, 0),
                                      _mapController.zoom,
                                    );
                                  });
                                },
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Text("${_selectedRadius.toStringAsFixed(0)} km",
                                  style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _fetchBirdData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            minimumSize: Size(double.infinity, 0),
                          ),
                          child: Text("SEARCH BIRDS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: TabBar(
                              indicator: UnderlineTabIndicator(
                                borderSide: BorderSide(width: 3, color: Colors.green[700]!),
                                insets: EdgeInsets.symmetric(horizontal: 16),
                              ),
                              labelColor: Colors.green[800],
                              unselectedLabelColor: Colors.grey,
                              labelStyle: TextStyle(fontWeight: FontWeight.bold),
                              tabs: [
                                Tab(text: "Recent Sightings (${_recentSightings.length})"),
                                Tab(text: "Hotspots (${_birdHotspots.length})"),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: Colors.white,
                              child: TabBarView(
                                children: [
                                  _buildSightingsList(),
                                  _buildHotspotsList(_birdHotspots),
                                ],
                              ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.air, size: 50, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              "No recent sightings found",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            TextButton(
              onPressed: _fetchBirdData,
              child: Text("Try again", style: TextStyle(color: Colors.green[700])),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 8),
      itemCount: _recentSightings.length,
      itemBuilder: (context, index) {
        final sighting = _recentSightings[index];
        String formattedDate = _formatDate(sighting["obsDt"]);
        String location = sighting["locName"];
        int count = sighting["howMany"] ?? 1;

        return Container(
          margin: EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openGoogleMaps(sighting["lat"], sighting["lng"]),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.air, color: Colors.green[700], size: 30),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sighting["comName"],
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          sighting["sciName"],
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.place, size: 16, color: Colors.redAccent),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(color: Colors.blue[700]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(formattedDate, style: TextStyle(color: Colors.grey[700])),
                            Spacer(),
                            Icon(Icons.confirmation_number, size: 16, color: Colors.orange),
                            SizedBox(width: 4),
                            Text("$count", style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHotspotsList(List<BirdHotspot> hotspots) {
    if (hotspots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 50, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              "No hotspots found",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            TextButton(
              onPressed: _fetchBirdData,
              child: Text("Try again", style: TextStyle(color: Colors.green[700])),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 8),
      itemCount: hotspots.length,
      itemBuilder: (context, index) {
        final hotspot = hotspots[index];

        return Container(
          margin: EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openGoogleMaps(hotspot.latitude, hotspot.longitude),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.location_on, color: Colors.blue[700], size: 30),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          hotspot.name,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildHotspotInfoRow(Icons.calendar_today, "Last observation: ${hotspot.lastObservation}"),
                  _buildHotspotInfoRow(Icons.air, "${hotspot.totalSpecies} species recorded"),
                  _buildHotspotInfoRow(Icons.pin_drop, "${hotspot.latitude.toStringAsFixed(4)}, ${hotspot.longitude.toStringAsFixed(4)}"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHotspotInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blue[700]),
          SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }

  void _openGoogleMaps(double lat, double lng) {
    String url = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    launchUrl(Uri.parse(url));
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.parse(dateString);
    return "${date.day}/${date.month}/${date.year}";
  }
}