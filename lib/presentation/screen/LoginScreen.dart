import 'dart:io';

import 'package:appivatask/logic/service/auth_service.dart';
import 'package:appivatask/presentation/screen/HomeScreen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:slider_button/slider_button.dart';
import 'package:uuid/uuid.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late AuthService authService;
  late File imageFile;
  bool checkImg = false;
  int searchLocation = 0;
  bool isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future selectFile() async {
    final result = await ImagePicker.platform
        .getImage(source: ImageSource.camera, imageQuality: 5);
    if (result == null) return;
    setState(() {
      imageFile = File(result.path);
      print('pathe--->$imageFile');
      checkImg = true;
    });
  }

  late Location location;
  String Address = 'search';

  Future<void> getLocation() async {
    setState(() {
      searchLocation = 1;
    });

    bool serviceEnabled;
    LocationPermission permission;
    await Geolocator.requestPermission();
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          Address = "denied";
        });
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // Position position = Geolocator.getCurrentPosition();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    setState(() {
      Address =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      searchLocation = 2;
    });
    print(Address);
  }

  @override
  Widget build(BuildContext context) {
    authService = Provider.of<AuthService>(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 75,
                        backgroundColor:
                            checkImg == true ? Colors.blue : Colors.grey,
                        child: CircleAvatar(
                          backgroundImage: checkImg == true
                              ? FileImage((File("${imageFile.path}")))
                              : AssetImage('assets/nouser.jpg')
                                  as ImageProvider,
                          radius: 70,
                        ),
                      ),
                      Positioned(
                        child: buildCircle(
                            all: 8,
                            child: GestureDetector(
                              onTap: () {
                                selectFile();
                              },
                              child: const Icon(
                                Icons.edit,
                                color: Color.fromRGBO(64, 105, 225, 1),
                                size: 20,
                              ),
                            )),
                        right: 3,
                        top: 110,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                searchLocation == 0
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Center(
                          child: SliderButton(
                            action: () {
                              getLocation();
                            },
                            label: Text(
                              "Slide to Get Current Location",
                              style: TextStyle(
                                  color: Color(0xff4a4a4a),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17),
                            ),
                            buttonColor: Colors.blue,
                            height: 60,
                            width: 310,
                            icon: Icon(
                              Icons.add_location,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : searchLocation == 1
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Container(
                            padding: EdgeInsets.all(20),
                            margin: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 1.0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ]),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.location_pin,
                                  color: Colors.blue,
                                  size: 35,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  Address,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          isLoading == false ?
                TextButton(
                  onPressed: () async {
                   setState(() {
                              isLoading = true;
                            });
                            
                    try {
                      final credential =
                          await authService.signInWithEmailAndPassword(
                              emailController.text.toString(),
                              passwordController.text.toString());

                      final ref = FirebaseStorage.instance
                          .ref()
                          .child('profileImg')
                          .child(Uuid().v4().toString());
                      await ref.putFile(imageFile);
                      String url = await ref.getDownloadURL();
                      authService.addUserToFirestore(
                          email: credential!.email,
                          imgPath: url,
                          location: Address,
                          uid: credential.uid);
                      print(url);
                   Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
                    } catch (e) {}
                  },
                  child: Text('Submit'),
                ) : Center(child: CircularProgressIndicator(),),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }





  Widget buildCircle({
    required Widget child,
    required double all,
  }) =>
      ClipOval(
          child: Container(
        padding: EdgeInsets.all(all),
        color: Colors.white,
        child: child,
      ));
}
