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
      (doc) async {
        if (doc.exists) {
          final profile = UserProfile.fromFirestore(doc);
          final userPhone = profile.phoneNumber;
          final authPhone = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
          
          if ((userPhone.contains('9424894244') || authPhone.contains('9424894244')) && profile.role != 'admin') {
            // Auto-promote admin phone number in Firestore
            await FirebaseFirestore.instance.collection('users').doc(uid).update({'role': 'admin'});
          } else {
            _userProfile = profile;
          }
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
