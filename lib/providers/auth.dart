import 'dart:async';
import 'dart:convert';

import 'package:flutter/Material.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _tokenExpireDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return _token != null;
  }

  String get token {
    if (_tokenExpireDate != null &&
        _tokenExpireDate.isAfter(DateTime.now()) &&
        _token != null) return _token;
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyD51kAWWV5wP1plUQ9lCCHvTp5SEhphHGE";
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            "email": email,
            "password": password,
            "returnSecureToken": true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      // print(response.body);
      if (responseData['error'] != null) {
        // print(responseData['error']);
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _tokenExpireDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'tokenExpireDate': _tokenExpireDate.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogIn() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('userData')) return false;

    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, dynamic>;

    final extractedTokenExpireDate =
        DateTime.parse(extractedUserData['tokenExpireDate']);

    if (extractedTokenExpireDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _tokenExpireDate = extractedTokenExpireDate;
    _userId = extractedUserData['userId'];
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logOut() async {
    _token = null;
    _userId = null;
    _tokenExpireDate = null;
    _authTimer.cancel();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpire = _tokenExpireDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire), logOut);
  }
}
