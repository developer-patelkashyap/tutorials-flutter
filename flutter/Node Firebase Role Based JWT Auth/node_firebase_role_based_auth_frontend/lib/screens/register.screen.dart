import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/custom_text_field.widget.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
// import 'package:path/path.dart';
import 'package:path/path.dart' as Path;
import 'package:http_parser/http_parser.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
  final List<String> roles = ['USER', 'ADMIN'];
  String? selectedRole;
  File? selectedImage;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => selectedImage = File(picked.path));
  }

  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    if ([name, email, phone, password].any((e) => e.isEmpty)) {
      return showAlert('Validation Error', 'Please fill in all fields.');
    }

    final token = await storage.read(key: 'authToken');
    if (token == null) {
      await showAlert('Unauthorized', 'Please log in first.');
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }

    try {
      // final response = await http.post(
      //   Uri.parse('http://localhost:3000/api/auth/signup'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Bearer $token',
      //   },
      //   body: jsonEncode({
      //     'name': name,
      //     'email': email,
      //     'phone': phone,
      //     'password': password,
      //     'role': selectedRole ?? 'USER',
      //   }),
      // );

      final uri = Uri.parse('http://localhost:3000/api/auth/signup');

      final request =
          http.MultipartRequest('POST', uri)
            ..headers['Authorization'] = 'Bearer $token'
            ..fields['name'] = name
            ..fields['email'] = email
            ..fields['phone'] = phone
            ..fields['password'] = password
            ..fields['role'] = selectedRole ?? 'USER';

      final mimeType = lookupMimeType(selectedImage!.path) ?? 'image/jpeg';

      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          selectedImage!.path,
          contentType: MediaType.parse(mimeType),
          filename: Path.basename(selectedImage!.path),
        ),
      );

      final streamedRes = await request.send();
      final response = await http.Response.fromStream(streamedRes);

      final data = jsonDecode(response.body);
      final message =
          data['message'] ?? data['error'] ?? 'Something went wrong';

      if (response.statusCode == 201) {
        await showAlert('Success', message);
        Navigator.pushReplacementNamed(context, '/home');
      } else if (response.statusCode == 403) {
        await showAlert('Access Denied', message);
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      } else {
        await showAlert('Error', message);
      }
    } catch (e) {
      showAlert('Network Error', 'Failed to register: $e');
    }
  }

  Future<void> showAlert(String title, String message) {
    return showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.of(context, rootNavigator: true).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            if (selectedImage != null)
              CircleAvatar(
                radius: 40,
                backgroundImage: FileImage(selectedImage!),
              ),
            TextButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pick Profile Image'),
            ),
            CustomTextField(label: 'Name', controller: nameController),
            const SizedBox(height: 10),
            CustomTextField(label: 'Email', controller: emailController),
            const SizedBox(height: 10),
            CustomTextField(label: 'Phone', controller: phoneController),
            const SizedBox(height: 10),
            CustomTextField(
              label: 'Password',
              controller: passwordController,
              obscure: true,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(
                labelText: 'Select Role',
                border: OutlineInputBorder(),
              ),
              items:
                  roles
                      .map(
                        (role) =>
                            DropdownMenuItem(value: role, child: Text(role)),
                      )
                      .toList(),
              onChanged: (val) => setState(() => selectedRole = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: registerUser,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
