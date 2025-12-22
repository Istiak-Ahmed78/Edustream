import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Register with email & password
  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;

    // create firestore document
    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'email': email,
      'role': 'student',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  // Sign in with email & password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential;
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // cancelled

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;

    // create or update user doc
    final doc = _firestore.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'name': user.displayName ?? 'Google User',
        'email': user.email ?? '',
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return userCredential;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}
