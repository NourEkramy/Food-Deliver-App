import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// On-device storage for things the API cannot hold.
///
/// Addresses, saved cards and the "has seen onboarding" flag have no endpoint,
/// so they live here. One store rather than three keeps the JSON encoding and
/// the failure handling in a single place.
///
/// It reuses [FlutterSecureStorage], already a dependency for the session. Card
/// details in particular should never sit in plain SharedPreferences — and note
/// that the card screens deliberately keep only the last four digits.
class LocalStore {
  static const keyOnboardingSeen = 'onboarding_seen';
  static const keyAddresses = 'saved_addresses';
  static const keyCards = 'saved_cards';

  final FlutterSecureStorage _storage;

  const LocalStore([this._storage = const FlutterSecureStorage()]);

  /// Reads a flag, treating an unavailable store as "not set".
  Future<bool> readFlag(String key) async {
    try {
      return await _storage.read(key: key) == 'true';
    } catch (_) {
      return false;
    }
  }

  Future<void> writeFlag(String key, {required bool value}) async {
    try {
      await _storage.write(key: key, value: value.toString());
    } catch (_) {
      // Losing a preference is not worth failing a user action over.
    }
  }

  /// Reads a stored list, returning empty rather than throwing.
  ///
  /// Corrupt or outdated JSON is treated as "nothing saved": losing a list of
  /// addresses is a far better outcome than an app that cannot start.
  Future<List<Map<String, dynamic>>> readList(String key) async {
    try {
      // The read is inside the try as well as the decode: on a platform where
      // secure storage is unavailable it throws rather than returning null.
      final raw = await _storage.read(key: key);
      if (raw == null || raw.isEmpty) return const [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded.whereType<Map>().map(Map<String, dynamic>.from).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> items) async {
    try {
      await _storage.write(key: key, value: jsonEncode(items));
    } catch (_) {
      // The in-memory state is already updated; persistence is best effort.
    }
  }
}
