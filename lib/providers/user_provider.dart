import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = true;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  UserProvider() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _userSubscription?.cancel();
      if (user != null) {
        _listenToUserProfile(user.uid);
      } else {
        _userProfile = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  void _listenToUserProfile(String uid) {
    _isLoading = true;
    notifyListeners();

    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen(
      (doc) {
        if (doc.exists) {
          _userProfile = UserProfile.fromFirestore(doc);
        } else {
          _userProfile = null;
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint("Error listening to user profile: $e");
        _userProfile = null;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> refreshProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _listenToUserProfile(user.uid);
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
