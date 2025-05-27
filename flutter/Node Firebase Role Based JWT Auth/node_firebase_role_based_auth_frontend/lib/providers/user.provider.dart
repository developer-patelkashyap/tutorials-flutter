import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String? name;
  String? email;
  String? phone;
  String? role;
  String? photo;

  void setUser(Map<String, dynamic> userData) {
    name = userData['name'];
    email = userData['email'];
    phone = userData['phone'];
    role = userData['role'];
    photo = userData['photo'];
    notifyListeners();
  }

  void clearUser() {
    name = null;
    email = null;
    phone = null;
    role = null;
    notifyListeners();
  }

  bool get isAdmin => role == 'ADMIN';
}
