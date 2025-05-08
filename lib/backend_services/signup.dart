import 'package:firebase_auth/firebase_auth.dart';

class SignUpAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> signUpWithEmail({
    required String email,
    required String password,   
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword( 
        email: email,
        password: password,
      );
      return null; 
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unknown error occurred.";
    }
  }
}
