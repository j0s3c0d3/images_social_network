import 'package:flutter/foundation.dart';

class AppModel extends ChangeNotifier {

  bool? _isLogged;
  bool? get isLogged => _isLogged;
  set isLogged(bool? isLogged) {
    _isLogged = isLogged;
    notifyListeners();
  }

  String? _password;
  String? get password => _password;
  set password(String? password) {
    _password = password;
    notifyListeners();
  }

  String? _email;
  String? get email => _email;
  set email(String? email) {
    _email = email;
    notifyListeners();
  }

}