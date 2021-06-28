

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {

  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Future googleLogin() async{
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final x=  await FirebaseAuth.instance.signInWithCredential(credential);
      if(x.additionalUserInfo!.isNewUser){
        print('New User');

        FirebaseMessaging messaging = FirebaseMessaging.instance;
        var deviceTokens = FirebaseFirestore.instance.collection('deviceTokens');

        messaging.getToken().then((value) {
          deviceTokens.add({
            '${_user!.email}': value
          });
        });
      }
    }
  catch(e){
    print(e);
  }
  notifyListeners();
  }
Future logout() async{
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
}









}
