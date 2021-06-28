import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:planerio/Misc/getdata.dart';
import 'package:planerio/google/firebase_notification.dart';
import 'package:planerio/taskList.dart';
import 'package:planerio/widget/drawer.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class AddFriend extends StatefulWidget {
  AddFriendState createState() => AddFriendState();
}

class AddFriendState extends State<AddFriend> with WidgetsBindingObserver{
  bool loading = true;
  bool adding = false;
  // Color colorConvert(String color) {
  //   color = color.replaceAll("#", "");
  //   if (color.length == 6) {
  //     return Color(int.parse("0xFF" + color));
  //   } else if (color.length == 8) {
  //     return Color(int.parse("0x" + color));
  //   }
  //   return Color(int.parse(color));
  // }
  late List<Request> requests = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addObserver(this);


    setState(() {
      loading = true;
    });
    getRequests().then((value)   {
     setState(() {
       requests = value;
     });
    });
    setState(() {
      loading = false;
    });


//   print(requests.length);


  }





  final TextEditingController usernameTextController = TextEditingController();
  final roundedButtonController = RoundedLoadingButtonController();
  Widget build(BuildContext build) {
    return Scaffold(


      // backgroundColor: colorConvert('F46FD'),
      appBar: PreferredSize(

          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            brightness: Brightness.dark,
            elevation: 0.0,
            backgroundColor: Colors.indigo[900],
            title: Text('Friend Request', style: TextStyle(fontSize: 22)),
          )),
      body: Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(

          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Text(
                  'You can add friends to schedule Events with your Friends'),
            ),
            Form(
                child: Column(
                  children: [
                    Padding(
                      padding:
                      EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 15),
                      child: TextFormField(
                          decoration: InputDecoration(labelText: 'Email'),
                          controller: usernameTextController),
                    ),
                    RoundedLoadingButton(
                        color: Colors.blueAccent,
                        height: 30,
                        loaderSize: 14,
                        width: 100,
                        controller: roundedButtonController,
                        onPressed: () async {
                          // print(usernameTextController.text);

                          FirebaseFirestore firestore = FirebaseFirestore.instance;

                          final user = FirebaseAuth.instance.currentUser;
                          var alreadySent = false;
                          var connections =
                          FirebaseFirestore.instance.collection('awaitingConnections');
                          await connections

                              .get()
                              .then((value) => value.docs.forEach((element) {
                            if (element['to'] ==
                                usernameTextController.text && element['from'] == user!.email) {
                              final snackBar = SnackBar(
                                  content: Text('Request Already Sent'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                              alreadySent = true;
                              print('yes');
                            }
                          }));
                          var friends = FirebaseFirestore.instance.collection('connections');
                          await friends.doc(user!.email).collection('Friends').get().then((value) => {
                            value.docs.forEach((element) {
                              if(element['email'] == usernameTextController.text){
                                alreadySent = true;
                                final snackBar = SnackBar(
                                    content: Text('Already your Friend'));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                                print('already your friend');
                              }
                            })
                          });
                          
                          if (!alreadySent) {
                            var reqUserToken;
                            final userToken = FirebaseFirestore.instance
                                .collection('deviceTokens');
                            await userToken.get()
                                .then((value) {
                              value.docs.forEach((element) {
                                var ut = element
                                    .data()
                                    .keys
                                    .toString()
                                    .replaceAll('(', '')
                                    .replaceAll(')', '');
                                print(ut);
                                if (ut == usernameTextController.text) {
                                  // print(element[ut]);
                                  reqUserToken = element
                                      .data()
                                      .values
                                      .toString()
                                      .replaceAll('(', '')
                                      .replaceAll(')', '');
                                }
                              });
                            });

                            if (reqUserToken != null) {
                              await connections

                                  .add({'to': usernameTextController.text,
                                        'from':user.email,
                                        'accepted':false
                                  });
                              print(reqUserToken);
                              sendNotification(
                                  'You have a new Friend Request', 'From ${user
                                  .email}', [reqUserToken],'msg_req');
                              final snackBar =
                              SnackBar(content: Text('Request Sent'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  snackBar);
                            }
                          } else{
                            print('Error Occured');
                          }
                          roundedButtonController.stop();
// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.

                          //   tasks
                          //       .doc(user.uid)
                          //       .collection('userTask')
                          //       .add({'title': 'no', 'date': DateTime.now()});

                          //   Navigator.push(context, Slide(builder: (context) => AddTask()));
                        },
                        child: Text('Add')),

                  ],
                )
            ),
           Container(child: Text('Friends Requests',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),margin: EdgeInsets.only(top: 20),),
           loading ? Container(margin: EdgeInsets.only(top: 40),child:Center(child:CircularProgressIndicator())):
           Expanded(child: requests.length==0?Center(child:Text('No Requests')) : ListView.builder(itemCount:requests.length,itemBuilder: (context,index){

             return ListTile(title: Text(requests[index].email), trailing: adding?Container(width: 15,height: 15,margin: EdgeInsets.only(right: 15),child:CircularProgressIndicator(strokeWidth: 1,)):IconButton(icon: Icon(Icons.add),
               onPressed: ()  async {
               setState(() {
                 adding = true;
               });
             await acceptRequest(user!.email.toString(), requests[index].email);
             await closeAwaiting(requests[index].id);
               final snackBar =
               SnackBar(content: Text('Friend Added'));
               ScaffoldMessenger.of(context).showSnackBar(
                   snackBar);
               resetRequests();
             setState(() {
               adding = false;
             });
               setState(() {
                 requests.remove(requests[index]);
               });

             },),);
           }
           ),
           )
          ],
        ),

      ),
    );
  }
}
