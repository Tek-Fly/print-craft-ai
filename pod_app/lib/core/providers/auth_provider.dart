import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/subscription_model.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  UserModel? _currentUser;
  SubscriptionModel? _currentSubscription;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  
  // Getters
  UserModel? get currentUser => _currentUser;
  SubscriptionModel? get currentSubscription => _currentSubscription;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  
  // Convenience getters for UI
  bool get hasGenerationsLeft => _currentUser?.hasGenerationsLeft ?? false;
  int get freeGenerationsLeft => _currentUser?.generationsRemaining ?? 0;
  bool get isPro => _currentUser?.isPro ?? false;
  String get userEmail => _currentUser?.email ?? '';
  String get userName => _currentUser?.displayName ?? 'User';
  String get displayName => _currentUser?.displayName ?? 'User';
  
  AuthProvider() {
    _initializeAuth();
  }
  
  // Simple sign in for testing without Firebase
  void signInAsGuest() {
    _currentUser = UserModel.newUser(
      id: 'guest-user',
      email: 'guest@printcraft.ai',
      displayName: 'Guest User',
    );
    _status = AuthStatus.authenticated;
    notifyListeners();
  }
  
  Future<void> _initializeAuth() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();
      
      // Check for existing Firebase user
      final firebaseUser = _auth.currentUser;
      
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
        _status = AuthStatus.authenticated;
      } else {
        // Check for stored session
        final storedUserId = await StorageService.getString('user_id');
        if (storedUserId != null) {
          await _loadUserData(storedUserId);
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
  
  Future<void> _loadUserData(String userId) async {
    try {
      // Load user from Firestore
      final userData = await FirebaseService.getUser(userId);
      if (userData != null) {
        _currentUser = UserModel.fromMap(userData);
        
        // Load subscription if user is pro
        if (_currentUser!.isPro) {
          final subData = await FirebaseService.getActiveSubscription(userId);
          if (subData != null) {
            _currentSubscription = SubscriptionModel.fromMap(subData);
          }
        }
        
        // Store user ID locally
        await StorageService.setString('user_id', userId);
      }
    } catch (e) {
      print('Error loading user data: $e');
      _errorMessage = e.toString();
    }
  }
  
  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();
      
      // Create Firebase user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Create user model
        _currentUser = UserModel.newUser(
          id: credential.user!.uid,
          email: email,
          displayName: displayName,
        );
        
        // Save to Firestore
        await FirebaseService.createUser(_currentUser!.toMap());
        
        // Send verification email
        await credential.user!.sendEmailVerification();
        
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      
      return false;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getAuthErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();
      
      // Sign in with Firebase
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await _loadUserData(credential.user!.uid);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      
      return false;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _getAuthErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await StorageService.remove('user_id');
      _currentUser = null;
      _currentSubscription = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<void> useGeneration() async {
    if (_currentUser == null) return;
    
    if (!_currentUser!.isPro) {
      _currentUser = _currentUser!.copyWith(
        freeGenerationsUsed: _currentUser!.freeGenerationsUsed + 1,
      );
      
      // Update in Firestore
      await FirebaseService.updateUser(_currentUser!.id, {
        'freeGenerationsUsed': _currentUser!.freeGenerationsUsed,
        'lastActiveAt': DateTime.now().toIso8601String(),
      });
      
      notifyListeners();
    }
  }
  
  Future<void> upgradeToPro() async {
    if (_currentUser == null) return;
    
    _currentUser = _currentUser!.copyWith(
      plan: UserPlan.pro,
    );
    
    // Update in Firestore
    await FirebaseService.updateUser(_currentUser!.id, {
      'plan': UserPlan.pro.name,
    });
    
    notifyListeners();
  }
  
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
    Map<String, dynamic>? preferences,
  }) async {
    if (_currentUser == null) return;
    
    _currentUser = _currentUser!.copyWith(
      displayName: displayName ?? _currentUser!.displayName,
      photoUrl: photoUrl ?? _currentUser!.photoUrl,
      preferences: preferences ?? _currentUser!.preferences,
    );
    
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (preferences != null) updates['preferences'] = preferences;
    
    await FirebaseService.updateUser(_currentUser!.id, updates);
    notifyListeners();
  }
  
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
  
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _currentUser != null 
          ? AuthStatus.authenticated 
          : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}
