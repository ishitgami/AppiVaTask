import 'package:appivatask/logic/model/userModel.dart';
import 'package:appivatask/logic/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Users? userData;
    final authService = Provider.of<AuthService>(context);
    User user = authService.getcurrentUser();
    List<Users> userDataList = [];
    final userDataListRaw = Provider.of<List<Users>?>(context);
    print(userDataListRaw);
    userDataListRaw?.forEach((element) {
      if (user.uid == element.id) {
        userDataList.add(element);
      }
      ;
    });
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: userDataList.length,
          itemBuilder: ((context, index) {
            return Card(
              margin: EdgeInsets.all(10),
              child: Container(
                
                child: Row(
                children: [
                  Image.network(userDataList[index].imagePath,width: 50,height: 50,),
                  Column(
                    children: [
                      Text(userDataList[index].dateTime.toString()),
                      Text(userDataList[index].email),
                    ],
                  ),
                ],
              )),
            );
          })
          ),
      ),
    );
  }
}
