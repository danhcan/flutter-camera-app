import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/camera_model.dart';

class CameraProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CameraModel> _cameras = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  List<CameraModel> get cameras => _cameras;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    loadCameras();
  }

  Future<void> loadCameras() async {
    if (_currentUserId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('cameras')
          .orderBy('createdAt', descending: true)
          .get();

      _cameras = snapshot.docs.map((doc) => CameraModel.fromFirestore(doc)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCamera({
    required String name,
    required String rtspUrl,
    required String username,
    required String password,
    required String location,
  }) async {
    if (_currentUserId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final cameraId = const Uuid().v4();
      final now = DateTime.now();

      final newCamera = CameraModel(
        id: cameraId,
        name: name,
        rtspUrl: rtspUrl,
        username: username,
        password: password,
        location: location,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('cameras')
          .doc(cameraId)
          .set(newCamera.toFirestore());

      _cameras.insert(0, newCamera);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCamera(String cameraId, {
    String? name,
    String? rtspUrl,
    String? username,
    String? password,
    String? location,
    bool? isActive,
  }) async {
    if (_currentUserId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final cameraIndex = _cameras.indexWhere((c) => c.id == cameraId);
      if (cameraIndex == -1) return;

      final updatedCamera = _cameras[cameraIndex].copyWith(
        name: name,
        rtspUrl: rtspUrl,
        username: username,
        password: password,
        location: location,
        isActive: isActive,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('cameras')
          .doc(cameraId)
          .update(updatedCamera.toFirestore());

      _cameras[cameraIndex] = updatedCamera;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCamera(String cameraId) async {
    if (_currentUserId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('cameras')
          .doc(cameraId)
          .delete();

      _cameras.removeWhere((c) => c.id == cameraId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  CameraModel? getCameraById(String cameraId) {
    try {
      return _cameras.firstWhere((c) => c.id == cameraId);
    } catch (e) {
      return null;
    }
  }
}
