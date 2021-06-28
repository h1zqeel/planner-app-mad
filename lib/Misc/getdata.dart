import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:planerio/google/firebase_notification.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;


import 'package:weekday_selector/weekday_selector.dart';


class Request{


  late String email;
  late var id;
  Request(e,i){
    id = i;
    email = e;
  }
}
class Friend{
  late String email;
  Friend(e){

    email = e;
  }
}
class Plan{
  late String title;
  late String details;
  late DateTime time;
  late bool repeat;
  late bool isDate;
  late bool accept;
  late String id;
  late List days = [];
  late int numRepDays;
  late List people = [];
  Plan(iden,t,d,ti,r,isdate,dys,noRD){
    id = iden;
    title = t;
    details = d;
    time = DateTime.fromMicrosecondsSinceEpoch(ti.microsecondsSinceEpoch);
    repeat = r;
    isDate = isdate;
    days = dys;
    numRepDays = noRD;
  }
  Plan.withAccept(iden,t,d,ti,r,isdate,a,p){
    id = iden;
    title = t;
    details = d;
    time = DateTime.fromMicrosecondsSinceEpoch(ti.microsecondsSinceEpoch);
    repeat = r;
    isDate = isdate;
    accept = a;
    people = p;
  }
}
final user = FirebaseAuth.instance.currentUser;
Future<List<Request>> getRequests() async{
  List<Request> requests = [];

  var connections = FirebaseFirestore.instance.collection('awaitingConnections');
  await connections.get()
  .then((value) => {
    value.docs.forEach((element) {
      // print(element['to']);
      print(user!.email);
      if(element['to'] == user!.email){

        var x = Request(element['from'],element.id);
        requests.add(x);
      }
    })
  });
  return requests;

}

Future<bool> acceptRequest(String to, String from) async{
  var connections1 = FirebaseFirestore.instance.collection('connections').doc(to);
  await connections1.collection('Friends').add({
    'email':from
  });
  var connections2 = FirebaseFirestore.instance.collection('connections').doc(from);
  await connections2.collection('Friends').add({
    'email':to
  });
  return true;
}

Future<bool> closeAwaiting(id) async{
  bool toReturn = false;
  var closeAwaiting = FirebaseFirestore.instance.collection('awaitingConnections');
    await closeAwaiting.doc(id).delete().then((e) => {
     print('suc')
    });
    return toReturn;
}


Future<List<Friend>> getFriends() async{
  List<Friend> friends = [];
  print('getting friends');
  var connections = FirebaseFirestore.instance.collection('connections');
  await connections.doc(user!.email).collection('Friends').get().then((value)  {
    if(value.docs.isNotEmpty) {
      value.docs.forEach((element) {
        friends.add(Friend(element['email']));
      });
    }
  });

  return friends;
}


Future<List<String>> getFriendString(p) async{
  List<String> friends = [];
  List<String> newFriends = [];
  print('getting freinds');
  var connections = FirebaseFirestore.instance.collection('connections');
  await connections.doc(user!.email).collection('Friends').get().then((value) => {
    value.docs.forEach((element) {
      friends.add(element['email']);
    })
  });
  friends.where((element) => element.contains(p)).forEach((element) {

    newFriends.add(element);
  });
  return newFriends;
}


Future<List<Plan>> getPlans() async{
  List<Plan> userPlans = [];
  var plans = FirebaseFirestore.instance.collection('plans').doc(user!.email).collection('plan');
  await plans.get().then((value) => {
    value.docs.forEach((element) {
      if(!element['isDaily']){
        List days = element['days'];
        List deleteAfter = element['deleteAfter'];
        for(int i = 0; i < days.length; i++){
          DateTime toDelete = DateTime.fromMicrosecondsSinceEpoch(deleteAfter[i].microsecondsSinceEpoch);
          if(toDelete.isBefore(DateTime.now())){
            deleteAfter.remove(deleteAfter[i]);
            days.remove(days[i]);
          }
        }
        if(deleteAfter.length != element['deleteAfter'] && deleteAfter.length > 0){
          plans.doc(element.id).update({
            'deleteAfter':deleteAfter,
            'days':days
          });
        } else if(deleteAfter.length == 0) {
          plans.doc(element.id).delete();
        }
      }
      else if(!element['repeat'] && element['isDaily']){
        DateTime toDelete = DateTime.fromMicrosecondsSinceEpoch(element['time'].microsecondsSinceEpoch);
        if(toDelete.isBefore(DateTime.now())){
          plans.doc(element.id).delete();
        }

      }
      if(element['isDaily'] == false) {
        userPlans.add(Plan(element.id,element['title'], element['desc'], element['time'],
            element['repeat'], element['isDaily'],element['days'], element['noRepeatDays']));
      } else {
        print(element.id.toString());
        userPlans.add(Plan.withAccept(element.id,element['title'], element['desc'], element['time'],
            element['repeat'], element['isDaily'],element['accept'],element['people']));
      }

    })
  });
  return userPlans;
}

Future<void> insertPlan(title,details,date,TimeOfDay time,repeat,isDate,[repeatDays = 0]) async {
  var androidInitilize = AndroidInitializationSettings('app_icon');
  var initializationSettings = new InitializationSettings(
      android: androidInitilize);
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (notifSelected) async {

      });

  var androidDetails = new AndroidNotificationDetails(
      "plan", "Plan is Due", "Your Plan",
      importance: Importance.high);
  var generalNotifDetails = new NotificationDetails(
      android: androidDetails);
  var scheduledTime;
  if(!isDate) {
    List<String> days = [];
    DateTime dayTime = DateTime.now();
   List<bool> dateBool = date;
   List<tz.TZDateTime> weekly = [];
   for (int i = 0 ; i < 7; i++){
     if(dateBool[i]){
       var dayOfWeek = i;
       if(dayOfWeek == 0){
         dayOfWeek = 7;
       }
       DateTime datee = DateTime.now();
       var day = datee.subtract(Duration(days: datee.weekday - dayOfWeek));
       dayTime = DateTime(day.year,day.month,day.day, time.hour, time.minute);
       if (dayTime.isBefore(DateTime.now())) {

         dayTime = dayTime.add(Duration(days: 7));

       }
       tz.initializeTimeZones();
       var loc = tz.getLocation('Asia/Karachi');
       scheduledTime = tz.TZDateTime.from(dayTime, loc);
       weekly.add(scheduledTime);
       print('weekday:: '+scheduledTime.weekday.toString());
       print(scheduledTime);
       switch(scheduledTime.weekday){
         case 7: {
           print('lul');
          days.add('Sunday');
        }
        break;
         case 1: {
           days.add('Monday');
         }
         break;
         case 2: {
           days.add('Tuesday');
         }
         break;
         case 3: {
           days.add('Wednesday');
         }
         break;
         case 4: {
           days.add('Thursday');
         }
         break;
         case 5:{
           days.add('Friday');
         }
         break;
         case 6:{
           days.add('Saturday');
         }
       }
     }
   }
   if(!repeat && !isDate) {
     var plans = FirebaseFirestore.instance.collection('plans').doc(
         user!.email);
     await plans.collection('plan').add({
       'title': title,
       'desc': details,
       'days': days,
       'deleteAfter': weekly,
       'time':dayTime,
       'repeat': repeat,
       'isDaily': isDate,
       'noRepeatDays':0

     }).then((value) {
       weekly.forEach((time1) async {
         await flutterLocalNotificationsPlugin.zonedSchedule(
             value.id.hashCode+time1.hashCode, 'Reminder: ' + title, details,
             time1,
             generalNotifDetails,
             uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
                 .absoluteTime, androidAllowWhileIdle: true);
         print('notification set for ${time1}');
       });
     });
   }
   else if(repeat && !isDate){
     if(repeatDays == 0){
       throw 'Num of Weeks Cannot be zero';
     }
     var finalTimes = [];
     weekly.forEach((element) {
       var finalTime = element.add(Duration(days: (repeatDays-1)*7));
       finalTimes.add(finalTime);
     });

     var plans = FirebaseFirestore.instance.collection('plans').doc(user!.email);
     await plans.collection('plan').add({
       'title': title,
       'desc': details,
       'days': days,
       'deleteAfter': finalTimes,
       'time':dayTime,
       'repeat': repeat,
       'isDaily': isDate,
       'noRepeatDays':repeatDays
     }).then((value)  {

        weekly.forEach((time1) async {
          var myTime = time1;
          for(int i = 0; i < repeatDays; i++){
            await flutterLocalNotificationsPlugin.zonedSchedule(
                value.id.hashCode+time1.hashCode+i.hashCode, 'Reminder: ' + title, details,
                myTime,
                generalNotifDetails,
                uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
                    .absoluteTime, androidAllowWhileIdle: true);
            myTime = myTime.add(Duration(days: 7));
          }
        });
     });
   }
  // for(int i =0; i <7;i++){
  //     if(dateBool[i]){
  //       var dayOfWeek = i;
  //       if(dayOfWeek == 0){
  //         dayOfWeek = 7;
  //       }
  //       DateTime datee = DateTime.now();
  //       var day = datee.subtract(Duration(days: datee.weekday - dayOfWeek));
  //
  //       dayTime = DateTime(day.year,day.month,day.day, time.hour, time.minute);
  //
  //         if (dayTime.isBefore(DateTime.now())) {
  //
  //          dayTime = dayTime.add(Duration(days: 7));
  //
  //       }
  //       tz.initializeTimeZones();
  //       var loc = tz.getLocation('Asia/Karachi');
  //       var scheduledTime = tz.TZDateTime.from(dayTime, loc);
  //
  //       var plans = FirebaseFirestore.instance.collection('plans').doc(user!.email);
  //
  //
  //
  //       if(repeat && !isDate){
  //         if(repeatDays == 0){
  //           throw 'Num of Weeks Cannot be zero';
  //         }
  //        var finalTime = scheduledTime.add(Duration(days: (repeatDays-1)*7));
  //         await plans.collection('plan').add({
  //           'title': title,
  //           'desc': details,
  //           'time': finalTime,
  //           'repeat': repeat,
  //           'isDaily': isDate,
  //           'day':finalTime.weekday,
  //           'repeatFor':repeatDays
  //         }).then((value)  async {
  //                 for(i = 0; i < repeatDays; i++){
  //
  //                   await flutterLocalNotificationsPlugin.zonedSchedule(
  //                       (value.id.toString()+i.toString()).hashCode, 'Reminder: ' + title, details,
  //                       scheduledTime,
  //                       generalNotifDetails,
  //                       uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
  //                           .absoluteTime, androidAllowWhileIdle: true);
  //                 scheduledTime = scheduledTime.add(Duration(days: 7));
  //               }
  //         });
  //
  //
  //       }
  //
  //
  //
  //
  //     }
  //
  //
  //
  // }
if(dayTime == null){
  throw 'Please Select a Day';
}


  }
  else if(isDate){
    //repeatDays = userNamess
    List<String> userName = repeatDays;
    // List full = [];
    // full.add(user!.email);
    // full.addAll(userName);
    print(userName);
    var plans = FirebaseFirestore.instance.collection('plans').doc(user!.email);
    List tosend = [user!.email];
    tosend.addAll(userName);
    DateTime dayTime = DateTime(date.year,date.month,date.day, time.hour, time.minute);
    tz.initializeTimeZones();
    var loc = tz.getLocation('Asia/Karachi');
    var scheduledTime = tz.TZDateTime.from(dayTime, loc);
    print(scheduledTime);
    plans.collection('plan').add({
      'title':title,
      'desc': details,
      'time': scheduledTime,
      'repeat': repeat,
      'isDaily': isDate,
      'accept': true,
      'owner': true,
      'people': tosend

    }).then((value) async{
      await flutterLocalNotificationsPlugin.zonedSchedule(
          value.id.hashCode, 'Reminder: ' + title, details,
          scheduledTime,
          generalNotifDetails,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
              .absoluteTime, androidAllowWhileIdle: true);
      userName.forEach((element) async {
       if(element!=user!.email){
         var userPlan = FirebaseFirestore.instance.collection('plans').doc(element);
         userPlan.collection('plan').add({
           'title':title,
           'desc': details,
           'time': scheduledTime,
           'repeat': repeat,
           'isDaily': isDate,
           'accept': false,
           'people': tosend
         });
         var reqUserToken;
         final userToken = FirebaseFirestore.instance
             .collection('deviceTokens');
         await userToken.get()
             .then((value) {
           value.docs.forEach((element1) {
             var ut = element1
                 .data()
                 .keys
                 .toString()
                 .replaceAll('(', '')
                 .replaceAll(')', '');
             print(ut);
             if (ut == element) {
               // print(element1[ut]);
               reqUserToken = element1
                   .data()
                   .values
                   .toString()
                   .replaceAll('(', '')
                   .replaceAll(')', '');
               print(reqUserToken);
             }
           });
         });

        sendNotification(
             'You were tagged in a Plan', 'By ${user!.email}', [reqUserToken],'msg_tag');

       }
      });

    });
    // throw 'Not yet Available';
  }
  }