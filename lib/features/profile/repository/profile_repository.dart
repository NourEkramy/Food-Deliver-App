import 'package:dio/dio.dart';

/// Updates and deletes the signed-in user.
///
/// The endpoint has an unusual shape, worked out by probing it: the new
/// password is a **query parameter** and the new email is the request body as a
/// bare JSON string, not an object.
///
///     PUT /User/{apikey}?NewPassword=<password>
///     "<new email>"
///
/// Sending an object instead produces
/// "The JSON value could not be converted to System.String", and omitting
/// NewPassword produces "The NewPassword field is required" — which is why the
/// edit form always asks for a password, even when only the email changed.
class ProfileRepository {
  final Dio dio;

  ProfileRepository(this.dio);

  /// The API key is the user's identity here, so it is in the path rather than
  /// left to the interceptor.
  Future<void> updateProfile({
    required String apiKey,
    required String email,
    required String newPassword,
  }) async {
    try {
      await dio.put(
        '/User/$apiKey',
        queryParameters: {'NewPassword': newPassword},
        data: email,
      );
    } on DioException catch (e) {
      throw Exception(
        _readableError(e, fallback: 'Could not save your profile'),
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
