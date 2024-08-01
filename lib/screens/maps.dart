// ignore_for_file: unused_import, prefer_const_constructors, prefer_final_fields, sort_child_properties_last, no_leading_underscores_for_local_identifiers, avoid_print

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:smart_home_app/components/consts.dart';
import 'package:smart_home_app/components/theme_provider.dart';
import 'package:smart_home_app/main.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  LatLng _kigaliCenter =
      LatLng(-1.9441, 30.0619); // Coordinates for Kigali center
  LatLng? _currentP;
  Map<PolylineId, Polyline> polylines = {};
  Map<PolygonId, Polygon> _polygons = {};
  Map<CircleId, Circle> _circles = {};
  StreamSubscription<LocationData>? _locationSubscription;
  bool _notificationSentKicukiro = false;
  bool _notificationSentGasabo = false;
  MapType _currentMapType = MapType.normal; // Map type toggle

  // Define predefined locations
  final Map<String, LatLng> predefinedLocations = {
    "Home": LatLng(-2.0014377, 30.1263162), // New coordinates for home (Kicukiro)
    "School": LatLng(-1.955922, 30.104149) // New coordinates for school (Gasabo)
  };

  // Define district locations
  final LatLng _kicukiroDistrict = LatLng(-2.0014377, 30.1263162); // Updated coordinates for Kicukiro District
  final LatLng _gasaboDistrict = LatLng(-1.955922, 30.104149); // Updated coordinates for Gasabo District

  // Define notification channel
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  @override
  void initState() {
    super.initState();
    _createNotificationChannel();
    _initializeLocation();
    _createGeofence();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel(); // Cancel location updates subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: themeProvider.currentTheme,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor:
              themeProvider.isDarkMode ? Colors.grey[900] : Colors.pinkAccent,
          title: Text(
            'Location Tracking\nand Geofencing',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.white,
              fontFamily: 'Roboto',
              fontSize: 22,
            ),
          ),
          iconTheme: IconThemeData(
            color: themeProvider.isDarkMode ? Colors.white : Colors.white,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeProvider.isDarkMode
                    ? [Colors.grey[900]!, Colors.black]
                    : [Colors.pinkAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
                color: Colors.white,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
            IconButton(
              icon: Icon(
                _currentMapType == MapType.normal ? Icons.satellite : Icons.map,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _currentMapType = _currentMapType == MapType.normal
                      ? MapType.satellite
                      : MapType.normal;
                });
              },
            ),
          ],
        ),
        body: _currentP == null
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
                ),
              )
            : Stack(
                children: [
                  GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _mapController.complete(controller);
                      _setMapStyle(controller);
                    },
                    initialCameraPosition: CameraPosition(
                      target: _kigaliCenter,
                      zoom: 13,
                    ),
                    polygons: Set<Polygon>.of(_polygons.values),
                    markers: {
                      Marker(
                        markerId: MarkerId("_currentLocation"),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRose),
                        position: _currentP!,
                      ),
                    },
                    circles: Set<Circle>.of(_circles.values),
                    polylines: Set<Polyline>.of(polylines.values),
                    mapType: _currentMapType,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Column(
                      children: [
                        FloatingActionButton(
                          onPressed: _refreshLocation,
                          backgroundColor: themeProvider.isDarkMode
                              ? Colors.grey[900]
                              : Colors.pinkAccent,
                          child: Icon(Icons.refresh, color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                        ),
                        SizedBox(height: 10),
                        FloatingActionButton(
                          onPressed: () => _zoomIn(),
                          backgroundColor: themeProvider.isDarkMode
                              ? Colors.grey[900]
                              : Colors.pinkAccent,
                          child: Icon(Icons.zoom_in, color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                        ),
                        SizedBox(height: 10),
                        FloatingActionButton(
                          onPressed: () => _zoomOut(),
                          backgroundColor: themeProvider.isDarkMode
                              ? Colors.grey[900]
                              : Colors.pinkAccent,
                          child: Icon(Icons.zoom_out, color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
          ],
          currentIndex: 0,
          selectedItemColor: Colors.pinkAccent,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            // Handle navigation logic here
          },
          backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
          showUnselectedLabels: true,
          selectedFontSize: 14,
          unselectedFontSize: 14,
        ),
      ),
    );
  }

  Future<void> _initializeLocation() async {
    await _checkPermissions();
    await getLocationUpdates();
  }

  Future<void> _checkPermissions() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<void> getLocationUpdates() async {
    _locationSubscription = _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        LatLng newLocation =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
        updateMarkerAndCircle(newLocation);
        _cameraToPosition(newLocation);
        _checkGeofence(newLocation);
      }
    });
  }

  void updateMarkerAndCircle(LatLng newLocation) {
    setState(() {
      _currentP = newLocation;
      _circles[CircleId("_currentLocationCircle")] = Circle(
        circleId: CircleId("_currentLocationCircle"),
        center: newLocation,
        radius: 100, // radius in meters
        fillColor: Colors.pinkAccent.withOpacity(0.5),
        strokeColor: Colors.pinkAccent,
        strokeWidth: 1,
      );
    });
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 13,
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(_newCameraPosition),
    );
  }

  void _createGeofence() {
    List<LatLng> kigaliBoundaries = [
      LatLng(-2.0150, 30.0200), // Southwest corner
      LatLng(-2.0150, 30.1400), // Southeast corner
      LatLng(-1.9050, 30.1400), // Northeast corner
      LatLng(-1.9050, 30.0200), // Northwest corner
    ];

    PolygonId polygonId = PolygonId("Kigali");
    Polygon polygon = Polygon(
      polygonId: polygonId,
      points: kigaliBoundaries,
      strokeColor: Colors.pinkAccent,
      strokeWidth: 2,
      fillColor: Colors.pinkAccent.withOpacity(0.15),
    );

    setState(() {
      _polygons[polygonId] = polygon;
    });

    // Define Kicukiro geofence rectangle
    List<LatLng> kicukiroBoundaries = [
      LatLng(-2.0050, 30.1200), // Bottom-left corner
      LatLng(-2.0050, 30.1325), // Bottom-right corner
      LatLng(-1.9980, 30.1325), // Top-right corner
      LatLng(-1.9980, 30.1200), // Top-left corner
    ];

    PolygonId kicukiroPolygonId = PolygonId("Kicukiro");
    Polygon kicukiroPolygon = Polygon(
      polygonId: kicukiroPolygonId,
      points: kicukiroBoundaries,
      strokeColor: Colors.greenAccent,
      strokeWidth: 2,
      fillColor: Colors.greenAccent.withOpacity(0.15),
    );

    setState(() {
      _polygons[kicukiroPolygonId] = kicukiroPolygon;
    });

    // Define Gasabo geofence rectangle
    List<LatLng> gasaboBoundaries = [
      LatLng(-1.9600, 30.1000), // Bottom-left corner
      LatLng(-1.9600, 30.1080), // Bottom-right corner
      LatLng(-1.9510, 30.1080), // Top-right corner
      LatLng(-1.9510, 30.1000), // Top-left corner
    ];

    PolygonId gasaboPolygonId = PolygonId("Gasabo");
    Polygon gasaboPolygon = Polygon(
      polygonId: gasaboPolygonId,
      points: gasaboBoundaries,
      strokeColor: Colors.blueAccent,
      strokeWidth: 2,
      fillColor: Colors.blueAccent.withOpacity(0.15),
    );

    setState(() {
      _polygons[gasaboPolygonId] = gasaboPolygon;
    });
  }

  void _checkGeofence(LatLng currentLocation) {
    double distanceToKicukiro = _calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        _kicukiroDistrict.latitude,
        _kicukiroDistrict.longitude);
    double distanceToGasabo = _calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        _gasaboDistrict.latitude,
        _gasaboDistrict.longitude);

    print('Distance to Kicukiro: $distanceToKicukiro');
    print('Distance to Gasabo: $distanceToGasabo');

    if (distanceToKicukiro < 5.0 && !_notificationSentKicukiro) {
      // Lowered threshold for testing
      print('Triggering Kicukiro notification');
      _triggerLocationNotification('You have reached at Home.');
      _notificationSentKicukiro = true;
      _notificationSentGasabo = false;
    } else if (distanceToGasabo < 5.0 && !_notificationSentGasabo) {
      // Lowered threshold for testing
      print('Triggering Gasabo notification');
      _triggerLocationNotification('You have reached at University AUCA Gishushu Campus.');
      _notificationSentGasabo = true;
      _notificationSentKicukiro = false;
    }
  }

  double _calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void _triggerLocationNotification(String message) {
    String title = 'Location Alert';
    String body = message;

    _showNotification(title, body);
  }

  void _showNotification(String title, String body) {
    flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
        ),
      ),
    );
  }

  void _createNotificationChannel() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _refreshLocation() async {
    // Manually trigger a location update
    LocationData currentLocation = await _locationController.getLocation();
    LatLng newLocation =
        LatLng(currentLocation.latitude!, currentLocation.longitude!);
    updateMarkerAndCircle(newLocation);
    _cameraToPosition(newLocation);
    _checkGeofence(newLocation);
  }

  void _setMapStyle(GoogleMapController controller) async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('lib/assets/map_style.json');
    controller.setMapStyle(style);
  }

  Future<void> _zoomIn() async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.zoomOut());
  }
}
