import 'package/flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error
}

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _user;
  AuthStatus _status = AuthStatus.initial;
  String? _error;
  String? _token;

  UserModel? get user => _user;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider(this._apiService) {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token != null) {
      _token = token;
      _apiService.setToken(token);
      await getProfile();
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final String? idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token.');
      }
      
      final response = await _apiService.loginWithFirebase(idToken);
      _token = response['data']['tokens']['accessToken'];
      _user = UserModel.fromMap(response['data']['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', _token!);
      _apiService.setToken(_token!);
      
      _status = AuthStatus.authenticated;
      notifyListeners();

    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
    }
  }

  Future<void> getProfile() async {
    try {
      final response = await _apiService.getProfile();
      _user = UserModel.fromMap(response['data']);
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      // If fetching profile fails, token is likely invalid -> sign out
      await signOut();
    }
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    if (_user == null) return;
    try {
      final response = await _apiService.updateProfile(displayName: displayName, photoUrl: photoUrl);
      _user = UserModel.fromMap(response['data']);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    
    _user = null;
    _token = null;
    _apiService.setToken(null);
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
