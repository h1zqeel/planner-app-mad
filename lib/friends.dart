import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:planerio/Misc/getdata.dart';


class FriendsList extends StatefulWidget {

  FriendsListState createState() => FriendsListState();
}

class FriendsListState extends State<FriendsList> {
  final user = FirebaseAuth.instance.currentUser;
  var loading = true;
  List<Friend> friends = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('xd');
    getFriends().then((value) {
        // print(value);
      value.forEach((element) {
        print(element);
        setState(()  {
         friends.add(element);
         loading = false;
    print('xd');
        });


      });
      if(value.isEmpty){
        setState(() {
          loading=false;
        });
      }


    });


  }


  Widget makeList(){


    var rng = new Random();
    final times = [1, 2,rng.nextInt(100)];
    return ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              margin: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                  bottom: index == friends.length- 1 ? 10 : 0),
              child: Padding(
                padding: EdgeInsets.all(1),
                child:
                   ListTile(
                  title: Text(
                      friends[index].email.toString()
                  ),
                ),
               ),
              );
        });
  }





  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: PreferredSize(

            preferredSize: Size.fromHeight(50.0),
            child: AppBar(
              brightness: Brightness.dark,
              elevation: 0.0,
              backgroundColor: Colors.indigo[900],
              title: Text('Your Friends', style: TextStyle(fontSize: 22)),
            )),
      body:loading?Center(child: CircularProgressIndicator(),) : friends.isNotEmpty?  makeList():Center(child: Text('You have No Friends'),) ,
    );
  }

}
