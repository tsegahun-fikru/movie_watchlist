// lib/core/providers/core_providers.dart
// Miscellaneous core Riverpod providers shared across features.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

/// Singleton [FirebaseFirestore] instance used by feature-level services.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Derives the device's country code from the platform locale.
/// Falls back to `'US'` when no country code is available.
/// Used by the "Where to Watch" section to fetch region-specific providers.
final currentRegionProvider = Provider<String>((ref) {
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final countryCode = locale.countryCode;
  return (countryCode != null && countryCode.isNotEmpty) ? countryCode : 'US';
});
