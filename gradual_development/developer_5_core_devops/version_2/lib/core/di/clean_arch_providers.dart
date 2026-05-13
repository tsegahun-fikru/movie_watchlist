// lib/core/di/clean_arch_providers.dart
// VERSION 2 - Basic Riverpod providers for dependency injection.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// HTTP client provider.
/// TODO v3: Add interceptors, logging, retry logic
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

/// Placeholder for other DI providers.
/// TODO v3: Add repository providers, use case providers
class CleanArchProviders {
  // Additional providers will be added in v3
}
