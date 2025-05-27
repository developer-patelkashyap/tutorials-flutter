import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/user.provider.dart';
import '../widgets/custom_text_field.widget.dart';
import 'home.screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
  bool isLoading = false;

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      return showAlert('Validation Error', 'Enter both phone and password.');
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await storage.write(key: 'authToken', value: data['token']);
        context.read<UserProvider>().setUser(data['user']);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        showAlert(
          'Login Failed',
          data['error'] ?? data['message'] ?? 'Unknown error',
        );
      }
    } catch (e) {
      showAlert('Network Error', 'Could not login: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> showAlert(String title, String message) async {
    if (!mounted) return;
    return showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomTextField(label: 'Phone', controller: phoneController),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Password',
              controller: passwordController,
              obscure: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: loginUser,
                  child: const Text('Login'),
                ),
          ],
        ),
      ),
    );
  }
}
