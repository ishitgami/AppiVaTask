import 'package:appivatask/logic/model/firebaseUser.dart';
import 'package:appivatask/logic/service/authError.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;


class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  FirebaseFirestore _db = FirebaseFirestore.instance;

   getcurrentUser()  {
    return  _firebaseAuth.currentUser;
  }

  FireBaseUser? _userFromFirebase(auth.User? user) {
    if (user == null) {
      return null;
    }
    return FireBaseUser(uid: user.uid, email: user.email);
  }

  Stream<FireBaseUser?>? get user {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  Future<FireBaseUser?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return _userFromFirebase(credential.user);
    } on auth.FirebaseAuthException catch (error) {
      if(error.code == "user-not-found") {
        return createUserWithEmailAndPassword( email, password);
      }
      final errorMessage =
          ErrorHangling().throwErrorMesg(errorCode: error.code);
      throw errorMessage;
    }
  }

  Future<FireBaseUser?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return _userFromFirebase(credential.user);
    } on auth.FirebaseAuthException catch (error) {
      final errorMessage =
          ErrorHangling().throwErrorMesg(errorCode: error.code);
      throw errorMessage;
    }
  }

  Future<void> addUserToFirestore(
      {uid, location, imgPath, email}) {
    return _db.collection('User').add({
      'id': uid,
      'imgPath' : imgPath,
      'Email': email,
      'DateTime' : DateTime.now(),
      'Location' : location,
    });
  }

  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }
}
