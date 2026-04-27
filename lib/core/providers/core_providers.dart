import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final currentRegionProvider = Provider<String>((ref) {
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final countryCode = locale.countryCode;
  return (countryCode != null && countryCode.isNotEmpty) ? countryCode : 'US';
});
