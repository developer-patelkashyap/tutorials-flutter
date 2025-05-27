import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:node_firebase_role_based_auth_frontend/providers/user.provider.dart';
import 'package:provider/provider.dart';
import 'screens/home.screen.dart';
import 'screens/login.screen.dart';
import 'screens/register.screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Node Firebase Role Based JWT Auth',
      home: AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String? initialRoute;
  bool isLoading = true;
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final token = await storage.read(key: 'authToken');
    setState(() {
      initialRoute = token == null ? '/login' : '/home';
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final userProvider = context.read<UserProvider>();

        userProvider.setUser(userData);

        setState(() {
          isAuthenticated = true;
          isLoading = false;
        });
      } else {
        await storage.deleteAll();
        redirectToLogin();
      }
    } catch (e) {
      await storage.deleteAll();
      redirectToLogin();
    }
  }

  void redirectToLogin() {
    setState(() {
      isLoading = false;
      isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => UserProvider())],
      child: MaterialApp(
        title: 'Node Firebase Role Based JWT Auth',
        theme: ThemeData(primarySwatch: Colors.blue),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
        },
        home: isAuthenticated ? HomeScreen() : const LoginScreen(),
      ),
    );
  }
}
