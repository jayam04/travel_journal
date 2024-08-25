import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/pages/auth/login_screen.dart';
import 'package:travel_journal/pages/auth/signup_screen.dart';
import 'package:travel_journal/pages/home_page.dart';
import 'package:travel_journal/provider/auth_provider.dart';
import 'package:travel_journal/provider/firebase_service.dart';
import 'package:travel_journal/provider/view_providers/entries_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Remove await and make only dependent components await
  await FirebaseService.initializeFirebase(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ViewProvider()),
      ],
      child: MaterialApp(
        title: 'Travel Journal',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
          fontFamily: 'Bricolage Grotesque',
        ),
        home: const HomePage(title: 'Journals'),
        routes: <String, WidgetBuilder>{
          '/auth/login': (BuildContext context) => LoginScreen(),
          '/auth/signup': (BuildContext context) => SignUpScreen(),
        },
      ),
    );
  }
}
