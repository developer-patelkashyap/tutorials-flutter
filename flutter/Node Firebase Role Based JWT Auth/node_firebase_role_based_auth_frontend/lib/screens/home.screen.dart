import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../providers/user.provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = const FlutterSecureStorage();
  String? error;

  @override
  void initState() {
    super.initState();
  }

  Future<void> logout() async {
    await storage.deleteAll();
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    String? name = context.watch<UserProvider>().name;
    String? email = context.watch<UserProvider>().email;
    String? photo = context.watch<UserProvider>().photo;
    bool? isAuthenticated = context.watch<UserProvider>().isAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(name ?? ''),
              accountEmail: Text(email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    photo != null && photo.isNotEmpty
                        ? NetworkImage(photo)
                        : null,
                child:
                    photo == null || photo.isEmpty
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
              ),
            ),
            if (isAuthenticated)
              const ListTile(
                title: Center(
                  child: Text(
                    'ADMIN',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (isAuthenticated)
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Register User'),
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => logout(),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            error != null
                ? Center(
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
                : name == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back! $name',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
      ),
    );
  }
}
