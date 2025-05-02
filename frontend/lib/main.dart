// //main.dart
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import 'screens/landing_page.dart';
// import 'screens/home_page.dart';
// import 'screens/profile_setup_page.dart';
// import 'screens/create_project_page.dart';
// import 'screens/profile_page.dart';
// import 'screens/settings_page.dart';
// import 'services/api_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load();
//   await Supabase.initialize(
//     url: dotenv.env['host_URL']!,
//     anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
//   );
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Dolphin Finder',
//       debugShowCheckedModeBanner: false,
//       home: EntryPoint(),
//     );
//   }
// }

// class EntryPoint extends StatefulWidget {
//   @override
//   _EntryPointState createState() => _EntryPointState();
// }

// class _EntryPointState extends State<EntryPoint> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//     HomePage(),
//     CreateProjectPage(),
//     ProfilePage(),
//     SettingsPage(),
//   ];

//   Future<Map?> fetchBackendProfile() async {
//     final token = await ApiService.getToken();
//     final res = await http.get(
//       Uri.parse('${ApiService.baseUrl}me/'),
//       headers: {'Authorization': 'Bearer $token'},
//     );
//     return res.statusCode == 200 ? jsonDecode(res.body) : null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final session = Supabase.instance.client.auth.currentSession;
//     if (session == null) {
//       return LandingPage();
//     } else {
//       return FutureBuilder(
//         future: fetchBackendProfile(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Scaffold(body: Center(child: CircularProgressIndicator()));
//           }
//           if (snapshot.data == null) {
//             return ProfileSetupPage();
//           }
//           return Scaffold(
//             body: _pages[_selectedIndex],
//             bottomNavigationBar: BottomNavigationBar(
//               currentIndex: _selectedIndex,
//               onTap: (index) => setState(() => _selectedIndex = index),
//               items: const [
//                 BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//                 BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.person),
//                   label: 'Profile',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.settings),
//                   label: 'Settings',
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     }
//   }
// }
