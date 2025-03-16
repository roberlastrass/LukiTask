import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Muestra un mensaje de error detallado
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "El correo ya está en uso.";
      case 'invalid-email':
        return "El formato del correo no es válido.";
      case 'weak-password':
        return "La contraseña es demasiado débil.";
      case 'user-not-found':
        return "No se encontró un usuario con ese correo.";
      case 'wrong-password':
        return "Contraseña incorrecta.";
      case 'too-many-requests':
        return "Demasiados intentos. Intenta más tarde.";
      default:
        return "Ocurrió un error. Inténtalo de nuevo.";
    }
  }

  /// Registro de usuario con email y contraseña
  Future<User?> register(String email, String password, String username) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
      });

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("❌ Error al registrar: ${_handleFirebaseAuthError(e)}");
      return null;
    } catch (e) {
      print("❌ Error desconocido al registrar: $e");
      return null;
    }
  }

  /// Inicio de sesión con email y contraseña
  Future<User?> login(String username, String password) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (query.docs.isEmpty) {
        print("⚠️ Usuario no encontrado.");
        return null;
      }

      String email = query.docs.first['email'];
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("❌ Error al iniciar sesión: ${_handleFirebaseAuthError(e)}");
      return null;
    } catch (e) {
      print("❌ Error desconocido al iniciar sesión: $e");
      return null;
    }
  }

  /// Inicio de sesión con Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print("⚠️ Inicio de sesión con Google cancelado.");
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo!.isNewUser) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': googleUser.displayName,
          'email': googleUser.email,
        });
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("❌ Error al iniciar sesión con Google: ${_handleFirebaseAuthError(e)}");
      return null;
    } catch (e) {
      print("❌ Error desconocido al iniciar sesión con Google: $e");
      return null;
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      print("✅ Sesión cerrada exitosamente.");
    } catch (e) {
      print("❌ Error al cerrar sesión: $e");
    }
  }
}



/*
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registro de usuario
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error al registrar: $e");
      return null;
    }
  }

  // Inicio de sesión
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error al iniciar sesión: $e");
      return null;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }
}
*/