// import 'package:daily_tasks/addFriend.dart';
// import 'package:daily_tasks/transition/Slide.dart';
import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:planerio/addFriend.dart';
import 'package:planerio/friends.dart';
import 'package:planerio/google/google_sign_in.dart';
import 'package:planerio/taskList.dart';
import 'package:planerio/transition/Slide.dart';
import 'package:provider/provider.dart';

class myDrawer extends StatelessWidget {
 late bool isNotif;
 late Function x;
myDrawer(i,f){
  isNotif = i;
  x = f;
}


  Color colorConvert(String color) {
    color = color.replaceAll("#", "");
    if (color.length == 6) {
      return Color(int.parse("0xFF" + color));
    } else if (color.length == 8) {
      return Color(int.parse("0x" + color));
    }
    return Color(int.parse(color));
  }

  Widget build(BuildContext context) {


    return buildDrawer(context);

  }
  final user = FirebaseAuth.instance.currentUser;

  Widget buildDrawer(context) => Drawer(

    child: Container(
      color: colorConvert("#ffffff"),
      child: Column(
        children: [
          DrawerHeader(
            child: Wrap(children: [
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(
                    user!.photoURL!.replaceAll('s96-c', 's300-c'),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    user!.displayName!,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                ),
              ),
            ]),
          ),
          SizedBox(height: 30,),
          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  Slide(builder: (context) => AddFriend()),
                ).then((value) => x());
              },
              child: ListTile(title: Text('Add Friends'),trailing: isNotif? Badge():Text(""),)),
          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  Slide(builder: (context) => FriendsList()),
                );
              },
              child: ListTile(title: Text('Friends'),)),
          // ListTile(title: Text('Add a Friend'), onTap: () {}),

          Align(
            alignment: Alignment.bottomLeft,
            child:  TextButton(
                onPressed: () {
                  final provider = Provider.of<GoogleSignInProvider>(context,listen: false);
                  provider.logout();
                },
                child: ListTile(title: Text('Logout'))),
          ),

        ],
      ),
    ),
  );
}
