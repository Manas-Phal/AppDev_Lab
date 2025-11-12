import 'package:cloud_functions/cloud_functions.dart';

class FirebaseFunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Calls the 'setUserRole' Cloud Function with the given [uid] and [role].
  ///
  /// Returns a success message string if successful.
  /// Throws an exception if the call fails.
  Future<String> assignUserRole(String uid, String role) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('setUserRole');
      final results = await callable.call(<String, dynamic>{
        'uid': uid,
        'role': role,
      });
      
      // Handle the response data safely
      if (results.data != null && results.data is Map) {
        final data = results.data as Map<String, dynamic>;
        return data['message'] as String? ?? 'Role assigned successfully';
      }
      return 'Role assigned successfully';
    } on FirebaseFunctionsException catch (e) {
      // Handle Firebase Functions specific errors
      throw Exception('Firebase Functions error: ${e.code} - ${e.message}');
    } catch (e) {
      // Handle other errors
      throw Exception('Failed to assign role: $e');
    }
  }
}
