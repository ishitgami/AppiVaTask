import 'package:appivatask/logic/model/userModel.dart';
import 'package:appivatask/logic/service/auth_service.dart';
import 'package:appivatask/logic/service/userDataFirestoreService.dart';
import 'package:appivatask/presentation/screen/HomeScreen.dart';
import 'package:appivatask/presentation/screen/LoginScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
       providers: [
       StreamProvider<List<Users>>.value(
          value: UserDataFirestoreService().getUserData(),
          initialData: const [],
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        
       ],
      child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}
