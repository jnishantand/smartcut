import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = true;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  UserProvider() {
    _init();
  }

  Future<void> _init() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _fetchUserProfile(user.uid);
      } else {
        _userProfile = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserProfile(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      DocumentSnapshot doc = 
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      
      if (doc.exists) {
        _userProfile = UserProfile.fromFirestore(doc);
      } else {
        _userProfile = null;
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
      _userProfile = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _fetchUserProfile(user.uid);
    }
  }
}
