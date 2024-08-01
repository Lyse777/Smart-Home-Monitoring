// ignore_for_file: prefer_const_constructors, avoid_print, prefer_const_literals_to_create_immutables, use_super_parameters, use_key_in_widget_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // Import the generated file for Firebase options
import 'package:smart_home_app/screens/motiondetection.dart';
import 'package:smart_home_app/screens/lightsensor.dart';
import 'package:smart_home_app/screens/maps.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_home_app/components/theme_provider.dart';
import 'package:smart_home_app/screens/sign_in_page.dart'; // Import SignInPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initNotifications();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        // Add other providers if needed
      ],
      child: const MyApp(),
    ),
  );
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      // Handle notification tap
    },
  );

  print('Notification plugin initialized');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Smart Home App',
          theme: themeProvider.currentTheme,
          home: AuthenticationWrapper(),
        );
      },
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Show loading indicator while waiting
        }
        if (snapshot.hasData) {
          return MyHomePage(title: 'Smart Home Control'); // Redirect to MyHomePage after sign in
        }
        return SignInPage();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({required this.title, Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Colors.grey[900] : Colors.pinkAccent,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Raleway',
            fontSize: 24,
          ),
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
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: themeProvider.isDarkMode
              ? null
              : DecorationImage(
                  image: AssetImage('lib/assets/ff.jpg'),
                  fit: BoxFit.cover,
                ),
          color: themeProvider.isDarkMode ? Colors.black : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1 / 1.2, // Adjusts the aspect ratio of the buttons
            children: [
              _buildOption(
                context,
                colors: [Colors.pinkAccent.withOpacity(0.8), Colors.pink[200]!.withOpacity(0.8)],
                icon: Icons.lightbulb_rounded,
                label: 'Light Level Sensing\nand Automation',
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LightSensorPage())),
              ),
              _buildOption(
                context,
                colors: [Colors.purpleAccent.withOpacity(0.8), Colors.deepPurple[200]!.withOpacity(0.8)],
                icon: Icons.security,
                label: 'Motion Detection\nand Security',
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MotionDetectionPage())),
              ),
              _buildOption(
                context,
                colors: [Colors.teal.withOpacity(0.8), Colors.blueAccent.withOpacity(0.8)],
                icon: Icons.map,
                label: 'Location Tracking\nand Geofencing',
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MapPage())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context,
      {required List<Color> colors,
      required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50.0, color: Colors.white),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontSize: 14, // Reduced font size for better fitting
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white), // Smaller arrow icon
          ],
        ),
      ),
    );
  }
}
