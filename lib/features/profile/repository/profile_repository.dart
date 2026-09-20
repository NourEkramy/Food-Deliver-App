import 'dart:convert';

import 'package:dio/dio.dart';

/// Changes the signed-in user's password, or deletes their account.
///
/// The update endpoint takes a single `[FromBody] string NewPassword`:
///
///     PUT /User/{apikey}
///     "<new password>"
///
/// The body is a bare JSON string, not an object — an object returns
/// "The JSON value could not be converted to System.String", and the companion
/// "The NewPassword field is required" is the same parameter reported again
/// rather than a second, separate one.
///
/// Note what is *not* here: nothing changes an email address. A password is
/// the only server-side field a user can alter, which is why editing a profile
/// is otherwise a purely local operation.
class ProfileRepository {
  final Dio dio;

  ProfileRepository(this.dio);

  /// The API key identifies the user, so it goes in the path rather than being
  /// left to the interceptor to attach as a query parameter.
  ///
  /// [jsonEncode] is not decoration. Dio serialises a Map for you but sends a
  /// String body verbatim, assuming you already encoded it — so passing the
  /// password directly puts `hunter2` on the wire where the server expects
  /// `"hunter2"`. A numeric-looking password then fails as
  /// "'N' is an invalid end of a number", because the parser reads the digits
  /// as a number and chokes on the first letter.
  Future<void> changePassword({
    required String apiKey,
    required String newPassword,
  }) async {
    try {
      await dio.put('/User/$apiKey', data: jsonEncode(newPassword));
    } on DioException catch (e) {
      throw Exception(
        _readableError(e, fallback: 'Could not change your password'),
      );
    }
  }

  Future<void> deleteAccount(String apiKey) async {
    try {
      await dio.delete('/User/$apiKey');
    } on DioException catch (e) {
      throw Exception(
        _readableError(e, fallback: 'Could not delete your account'),
      );
    }
  }

  String _readableError(DioException e, {required String fallback}) {
    final data = e.response?.data;

    if (data is Map) {
      if (data['message'] is String) return data['message'] as String;

      final errors = data['errors'];
      if (errors is Map) {
        final first = errors.values
            .whereType<List>()
            .expand((list) => list)
            .whereType<String>()
            .firstOrNull;
        if (first != null) return first;
      }
    }

    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => 'The server took too long to respond.',
      DioExceptionType.connectionError =>
        'No internet connection. Please check your network.',
      _ => fallback,
    };
  }
}
