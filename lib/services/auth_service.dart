import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> register(String name, String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    await credential.user?.reload();
    final uid = credential.user?.uid;
    if (uid != null) {
      final now = DateTime.now().toIso8601String();
      await Future.wait([
        _db.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'createdAt': now,
        }),
        _db.collection('userProfiles').doc(uid).set({
          'uid': uid,
          'displayName': name,
          'displayNameLower': name.toLowerCase(),
          'email': email,
          'createdAt': now,
        }),
      ]);
    }
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}

final authService = AuthService();
