// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, avoid_print, unused_import, unused_field

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:light_sensor/light_sensor.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:smart_home_app/components/theme_provider.dart';

class LightSensorPage extends StatefulWidget {
  @override
  _LightSensorPageState createState() => _LightSensorPageState();
}

class _LightSensorPageState extends State<LightSensorPage> {
  double _lightIntensity = 0.0;
  bool _showHighIntensityNotification = true;
  bool _showLowIntensityNotification = true;
  bool _showMiddleIntensityNotification = true;
  bool _isBulbOn = false;
  late StreamSubscription<int> _lightSubscription;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _startListeningToLightSensor();
  }

  @override
  void dispose() {
    _lightSubscription.cancel();
    super.dispose();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _startListeningToLightSensor() {
    LightSensor.hasSensor().then((hasSensor) {
      if (hasSensor) {
        _lightSubscription = LightSensor.luxStream().listen((int luxValue) {
          setState(() {
            _lightIntensity = luxValue.toDouble();
            checkAndTriggerNotifications();
          });
        });
      } else {
        print("Device does not have a light sensor");
      }
    });
  }

  void checkAndTriggerNotifications() {
    if (_lightIntensity >= 20000.0) {
      if (_showHighIntensityNotification) {
        _showNotification('High Light Intensity', 'Ambient light is at a very high level.');
        _showHighIntensityNotification = false;
        _showMiddleIntensityNotification = true;
        _showLowIntensityNotification = true;
      }
      _isBulbOn = true;
    } else if (_lightIntensity <= 100) {
      if (_showLowIntensityNotification) {
        _showNotification('Low Light Intensity', 'Ambient light is at a very low level.');
        _showLowIntensityNotification = false;
        _showMiddleIntensityNotification = true;
        _showHighIntensityNotification = true;
      }
      _isBulbOn = false;
    } else {
      if (_showMiddleIntensityNotification) {
        _showNotification('Middle Light Intensity', 'Ambient light is at a middle level.');
        _showMiddleIntensityNotification = false;
        _showHighIntensityNotification = true;
        _showLowIntensityNotification = true;
      }
      _isBulbOn = false;
    }
  }

  void _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Test Payload',
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: themeProvider.currentTheme,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.pinkAccent,
          title: Text(
            'Light Level Sensing\nand Automation',
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop(); // Navigate back to the previous screen
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
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: themeProvider.isDarkMode
                ? null
                : DecorationImage(
                    image: AssetImage('lib/assets/9.jpg'),
                    fit: BoxFit.cover,
                  ),
            color: themeProvider.isDarkMode ? Colors.black : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Current Light Intensity',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.purpleAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '${_lightIntensity.toStringAsFixed(2)} lux',
                  style: TextStyle(
                    fontSize: 48,
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                if (_lightIntensity >= 20000.0)
                  Image.asset('lib/assets/high.png', width: 230, height: 230)
                else if (_lightIntensity <= 100)
                  Image.asset('lib/assets/low.png', width: 230, height: 230)
                else
                  Image.asset('lib/assets/middle.png', width: 230, height: 230),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: themeProvider.currentTheme,
            home: LightSensorPage(),
          );
        },
      ),
    ),
  );
}
