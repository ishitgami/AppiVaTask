class Users {
  final String id;
  final String email;
  final String imagePath;
  final DateTime dateTime;
  final String location;

  Users({required this.id, required this.email, required this.imagePath, required this.dateTime, required this.location});

  Map<String, dynamic> createMap() {
    return {
      "Id" : id,
      "Name" : email,
      "ImagePath" : imagePath,
      "DateTime" : dateTime,
      "Location" : location
    };
  }

  Users.fromFirestore(Map<String, dynamic> firestoreMap) 
   : id = firestoreMap["id"],
    email = firestoreMap["Email"],
    imagePath = firestoreMap["imgPath"],
    dateTime = firestoreMap["DateTime"].toDate(),
    location = firestoreMap["Location"];
}