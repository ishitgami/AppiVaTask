
import 'package:appivatask/logic/model/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDataFirestoreService { 
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Users>> getUserData() {

    return _db
        .collection('User')
        // .orderBy("DateTime", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((document) => Users.fromFirestore(document.data()))
            .toList());
  }
  
}