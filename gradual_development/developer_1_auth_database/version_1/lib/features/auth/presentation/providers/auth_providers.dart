// lib/features/auth/presentation/providers/auth_providers.dart
// VERSION 1 - Simple state management, no Firebase, no Riverpod.
// Uses a plain ChangeNotifier to track login state.

import 'package:flutter/material.dart';
import 'package:movie_watchlist/core/auth/auth_repository.dart';

/// Simple auth state notifier - no Firebase in v1.
/// TODO v2: Replace with Riverpod providers + Firebase
class AuthNotifier extends ChangeNotifier {
  final AuthRepository _authRepository = MockAuthRepository();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await _authRepository.signInWithEmailAndPassword(
      email,
      password,
    );

    _isLoggedIn = success;
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final success = await _authRepository.signUpWithEmailAndPassword(
      email,
      password,
    );

    _isLoggedIn = success;
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _isLoggedIn = false;
    notifyListeners();
  }
}
