import 'dart:async';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:planerio/Misc/getdata.dart';
import 'package:planerio/addFriend.dart';
import 'package:planerio/addTask.dart';
import 'package:planerio/transition/Slide.dart';
import 'package:planerio/widget/drawer.dart';
import 'package:planerio/widget/fieldSearch.dart';

import 'package:rounded_loading_button/rounded_loading_button.dart';

import 'package:weekday_selector/weekday_selector.dart';
import 'package:badges/badges.dart' as badges;

class TaskList extends StatefulWidget {
  TaskListState createState() => TaskListState();
}

void resetRequests() {
  TaskListState().refresh();
}

class TaskListState extends State<TaskList> with WidgetsBindingObserver {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  var accepting = false;
  var loading = true;
  var showBadge = false;
  List<String> userNames = [];
  @override
  List<Plan> userPlans = [];

  void refresh() {
    var requests = getRequests();
    requests.then((value) {
      print(value.length);
      if (value.length > 0) {
        setState(() {
          showBadge = true;
        });
      } else {
        setState(() {
          showBadge = false;
        });
      }
    });
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    print(state);
    // var requests = getRequests();
    // requests.then((value)  {
    //   print(value.length);
    //   if(value.length>0){
    //     setState(() {
    //       showBadge = true;
    //     });
    //   } else {
    //     setState(() {
    //       showBadge = false;
    //     });
    //   }
    // });
    if (state.toString() == 'AppLifecycleState.resumed') {
      // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) {
      //
      //   if(event.data['msgId']== 'msg_req'){
      //     print('yes goo');
      //     Navigator.push(
      //       context,
      //       Slide(builder: (context) => AddFriend()),
      //     );
      //   }
      //
      // });

      checkConnection();
      var requests = getRequests();
      requests.then((value) {
        print(value.length);
        if (value.length > 0) {
          setState(() {
            showBadge = true;
          });
        } else {
          setState(() {
            showBadge = false;
          });
        }
      });
      setState(() {
        loading = true;
      });
      getPlans().then((value) => {
            setState(() {
              userPlans = value;
              loading = false;
            })
            // value.forEach((element) {
            //   setState(() {
            //     userPlans.add(element);
            //   });
            //
            // })
          });
    }
    //

    messaging.getToken().then((value) => print(value));

    // FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    //   print('its working');
    //
    //   print(event.notification!.title);
    //   // print(event);
    // });
  }

  void checkConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      showDialog(
          context: context,
          builder: (builder) {
            return AlertDialog(
              title: Text('This app cannot work properly without Internet'),
              actions: [
                TextButton(
                    onPressed: () {
                      // Navigator.pop(context);
                      SystemNavigator.pop();
                    },
                    child: Text('ok'))
              ],
            );
          });
    }
  }

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  @override
  void initState() {
    super.initState();
    checkConnection();
    initializeDateFormatting();
    // Intl.defaultLocale = 'pk';
    setState(() {
      loading = true;
    });
    // refresh();
    getPlans().then((value) => {
          setState(() {
            userPlans = value;
            loading = false;
          })
        });

    WidgetsBinding.instance!.addObserver(this);
    var requests = getRequests();

    requests.then((value) {
      print(value.length);
      if (value.length > 0) {
        setState(() {
          showBadge = true;
        });
      } else {
        setState(() {
          showBadge = false;
        });
      }
    });

    messaging.getToken().then((value) => print(value));

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print('its working');

      print(event.notification!.title);
      // print(event);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) {
      if (event.data['msgId'] == 'msg_req') {
        print('yes goo');
        Navigator.push(
          context,
          Slide(builder: (context) => AddFriend()),
        );
      } else if (event.data['msgId'] == 'msg_tag') {
        setState(() {
          loading = true;
        });
        getPlans().then((value) => {
              setState(() {
                userPlans = value;
                loading = false;
              })
            });
      }
    });

    var androidInitilize = AndroidInitializationSettings('app_icon');
    var initializationSettings =
        new InitializationSettings(android: androidInitilize);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (notifSelected) async {});
  }

  @override
  // ignore: must_call_super
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  void showNotif() async {
    // flutterLocalNotificationsPlugin.zonedSchedule(0, title, body, scheduledDate, notificationDetails, uiLocalNotificationDateInterpretation: uiLocalNotificationDateInterpretation, androidAllowWhileIdle: androidAllowWhileIdle)
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

  void addTaggedFriends(String f) {
    print('XD LOL');
    setState(() {
      userNames.add(f);
    });
  }

  final times = [1, 2];

  Widget makeList() {
    return ListView.builder(
        itemCount: userPlans.length,
        itemBuilder: (context, index) {
          return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              margin: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 10,
                  bottom: index == userPlans.length - 1 ? 10 : 0),
              child: Padding(
                padding: EdgeInsets.all(1),
                child: ListTile(
                  title: Text(
                    userPlans[index].title,
                  ),
                  subtitle: Text(userPlans[index].details),
                  trailing: !userPlans[index].isDate
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            userPlans[index].repeat
                                ? IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      CupertinoIcons.repeat,
                                      size: 20,
                                      color: Colors.indigo,
                                    ))
                                : SizedBox(
                                    height: 0,
                                    width: 0,
                                  ),
                            Material(
                              color: Colors.transparent,
                              child: IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        var x = userPlans[index].repeat
                                            ? '. It was set to repeat for ' +
                                                userPlans[index]
                                                    .numRepDays
                                                    .toString() +
                                                ' weeks.'
                                            : '.';
                                        return new AlertDialog(
                                            content: Text(
                                                'This Plan is Scheduled for ' +
                                                    userPlans[index]
                                                        .days
                                                        .join(', ') +
                                                    ' at ' +
                                                    DateFormat.jm()
                                                        .format(userPlans[index]
                                                            .time)
                                                        .replaceAll(' ', '') +
                                                    x));
                                      });
                                },
                                icon: Icon(FontAwesomeIcons.infoCircle),
                                iconSize: 20,
                                color: Colors.indigo,
                              ),
                            )
                          ],
                        )
                      :
                      // Text(
                      //
                      //   userPlans[index].days.join(', '),
                      //
                      //   textAlign: TextAlign.right,
                      //   style: TextStyle(color: Colors.grey[400]),
                      // ):
                      !userPlans[index].accept
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                accepting
                                    ? Container(
                                        height: 10,
                                        width: 10,
                                        margin: EdgeInsets.only(right: 20),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1,
                                        ),
                                      )
                                    : Material(
                                        color: Colors.transparent,
                                        child: IconButton(
                                          onPressed: () async {
                                            setState(() {
                                              accepting = true;
                                            });
                                            // print(userPlans[index].id);
                                            print(userPlans[index].id);
                                            var plans = FirebaseFirestore
                                                .instance
                                                .collection('plans')
                                                .doc(user!.email)
                                                .collection('plan');
                                            await plans
                                                .doc(userPlans[index].id)
                                                .update({
                                              'accept': true,
                                            });
                                            var androidDetails =
                                                new AndroidNotificationDetails(
                                                    "plan", "Plan is Due",
                                                    channelDescription:
                                                        "Your Plan",
                                                    importance:
                                                        Importance.high);
                                            var generalNotifDetails =
                                                new NotificationDetails(
                                                    android: androidDetails);

                                            tz.initializeTimeZones();
                                            var loc =
                                                tz.getLocation('Asia/Karachi');
                                            var scheduledTime =
                                                tz.TZDateTime.from(
                                                    userPlans[index].time, loc);

                                            await flutterLocalNotificationsPlugin
                                                .zonedSchedule(
                                                    userPlans[index]
                                                        .id
                                                        .hashCode,
                                                    'Reminder: ' +
                                                        userPlans[index].title,
                                                    userPlans[index].details,
                                                    scheduledTime,
                                                    generalNotifDetails,
                                                    uiLocalNotificationDateInterpretation:
                                                        UILocalNotificationDateInterpretation
                                                            .absoluteTime,
                                                    androidAllowWhileIdle:
                                                        true);
                                            getPlans().then((value) => {
                                                  setState(() {
                                                    userPlans = value;
                                                    accepting = false;
                                                  })
                                                });
                                          },
                                          icon: Icon(Icons.notifications),
                                          color: Colors.indigo,
                                        ),
                                      ),
                                Material(
                                  color: Colors.transparent,
                                  child: IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            final DateFormat formatter =
                                                DateFormat('dd-MM-yyyy');
                                            return AlertDialog(
                                              content: Text(userPlans[index]
                                                      .people
                                                      .join(', ')
                                                      .replaceAll(
                                                          '@gmail.com', '') +
                                                  ' are included in this Plan.'),
                                            );
                                          });
                                    },
                                    icon: Icon(
                                      FontAwesomeIcons.userFriends,
                                    ),
                                    iconSize: 20,
                                    color: Colors.indigo,
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            final DateFormat formatter =
                                                DateFormat('dd-MM-yyyy');
                                            return AlertDialog(
                                              content: Text(
                                                  'This Plan is Scheduled for ' +
                                                      formatter.format(
                                                          userPlans[index]
                                                              .time) +
                                                      ' at ' +
                                                      DateFormat.jm()
                                                          .format(
                                                              userPlans[index]
                                                                  .time)
                                                          .replaceAll(' ', '') +
                                                      '.'),
                                            );
                                          });
                                    },
                                    icon: Icon(
                                      FontAwesomeIcons.infoCircle,
                                    ),
                                    iconSize: 20,
                                    color: Colors.indigo,
                                  ),
                                )
                              ],
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            final DateFormat formatter =
                                                DateFormat('dd-MM-yyyy');
                                            return AlertDialog(
                                              content: Text(userPlans[index]
                                                      .people
                                                      .join(', ')
                                                      .replaceAll(
                                                          '@gmail.com', '') +
                                                  ' are included in this Plan.'),
                                            );
                                          });
                                    },
                                    icon: Icon(
                                      FontAwesomeIcons.userFriends,
                                    ),
                                    iconSize: 20,
                                    color: Colors.indigo,
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            final DateFormat formatter =
                                                DateFormat('dd-MM-yyyy');
                                            return AlertDialog(
                                              content: Text(
                                                  'This Plan is Scheduled for ' +
                                                      formatter.format(
                                                          userPlans[index]
                                                              .time) +
                                                      ' at ' +
                                                      DateFormat.jm()
                                                          .format(
                                                              userPlans[index]
                                                                  .time)
                                                          .replaceAll(' ', '') +
                                                      '.'),
                                            );
                                          });
                                    },
                                    icon: Icon(
                                      FontAwesomeIcons.infoCircle,
                                    ),
                                    iconSize: 20,
                                    color: Colors.indigo,
                                  ),
                                )
                              ],
                            ),
                ),
              ));
        });
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          showNotif();
          Navigator.push(
            context,
            Slide(builder: (context) => AddTask()),
          ).then((value) {
            setState(() {
              loading = true;
            });
            getPlans().then((value) => {
                  setState(() {
                    userPlans = value;
                    loading = false;
                  })
                });
          });
          //
        },
      ),
      drawer: myDrawer(showBadge, refresh),
      backgroundColor: colorConvert('F4F6FD'),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            leading: IconButton(
              icon: badges.Badge(
                badgeContent: Text(''),
                showBadge: showBadge,
                child: Icon(CupertinoIcons.bars),
                position: BadgePosition.bottomEnd(),
              ),
              onPressed: () => scaffoldKey.currentState!.openDrawer(),
            ),
            // brightness: Brightness.dark,
            backgroundColor: Colors.indigo[900],
            elevation: 0.0,
            title: Text('Your Plans', style: TextStyle(fontSize: 22)),
          )),
      body: loading ? Center(child: CircularProgressIndicator()) : makeList(),
    );
  }

  // Future notifSelected(String payload) async {}
}
