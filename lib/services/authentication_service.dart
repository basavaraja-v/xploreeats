import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:xploreeats/models/user.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges(); // Add this line

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<GUser?> getUserProfile() async {
    final User? user = _auth.currentUser;
    String username = '';
    bool isVegetarian = false;
    bool isNonVegetarian = false;
    String location = '';
    double postsCount = 0;
    double followersCount = 0;
    double followingCount = 0;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        Map<String, dynamic> data = userData.data()!;
        username = data['username'];
        isVegetarian = data['isVegetarian'];
        isNonVegetarian = data['isNonVegetarian'];
        location = data['location'];
        postsCount = data['postsCount'] ?? 0;
        followersCount = data['followersCount'] ?? 0;
        followingCount = data['followingCount'] ?? 0;
      }
    }
    if (user != null) {
      return GUser(
        uid: user.uid,
        displayName: user.displayName ?? '',
        username: username,
        email: user.email ?? '',
        photoURL: user.photoURL ?? '',
        isVegetarian: isVegetarian,
        isNonVegetarian: isNonVegetarian,
        postsCount: postsCount,
        followersCount: followersCount,
        followingCount: followingCount,
      );
    }
    return null;
  }
}
