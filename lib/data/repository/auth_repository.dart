import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserModel> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In canceled by user');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user == null) {
      throw Exception('Google Sign-In failed: Firebase user is null');
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }

    final role = UserModel.determineRoleFromEmail(user.email ?? '');
    final userModel = UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? (user.email ?? 'USER').split('@').first.toUpperCase(),
      role: role,
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toJson());
    return userModel;
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Sign up failed: User is null');
    }

    final role = UserModel.determineRoleFromEmail(email);
    final userModel = UserModel(
      id: user.uid,
      email: email.trim(),
      name: name.trim().isEmpty ? email.split('@').first.toUpperCase() : name.trim(),
      role: role,
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toJson());
    return userModel;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Sign in failed: User is null');
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }

    final role = UserModel.determineRoleFromEmail(email);
    final userModel = UserModel(
      id: user.uid,
      email: email.trim(),
      name: email.split('@').first.toUpperCase(),
      role: role,
    );
    await _firestore.collection('users').doc(user.uid).set(userModel.toJson());
    return userModel;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<UserModel?> getCurrentUserModel() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }

    final role = UserModel.determineRoleFromEmail(firebaseUser.email ?? '');
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: (firebaseUser.email ?? 'USER').split('@').first.toUpperCase(),
      role: role,
    );
  }
}
