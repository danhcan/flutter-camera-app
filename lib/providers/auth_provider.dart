import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = true;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  AuthProvider() {
    _initAuthState();
  }

  void _initAuthState() {
    _firebaseAuth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserData(user);
      } else {
        _currentUser = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _loadUserData(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
      } else {
        // Create new user document
        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'User',
          photoUrl: user.photoURL ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(newUser.toFirestore());
        _currentUser = newUser;
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(displayName);

      await _loadUserData(userCredential.user!);
      _error = null;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _loadUserData(userCredential.user!);
      _error = null;
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> updateUserProfile(String displayName, String photoUrl) async {
    try {
      if (_currentUser == null) return;

      await _firebaseAuth.currentUser?.updateDisplayName(displayName);
      if (photoUrl.isNotEmpty) {
        await _firebaseAuth.currentUser?.updatePhotoURL(photoUrl);
      }

      final updatedUser = _currentUser!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .update(updatedUser.toFirestore());

      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }
}
