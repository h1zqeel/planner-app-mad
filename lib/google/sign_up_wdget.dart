
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:planerio/google/google_signup_widget.dart';

class SignUpWidget extends StatelessWidget {
  Widget build(BuildContext context) => buildSignUp();

  Widget buildSignUp() => Column(
    children: [
      Spacer(),
      Text('Plan Your Days with Planerio',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),),
      Spacer(),
      GoogleSignupButton(),
      Center(child: Text('Login to Continue')),
      Spacer()
    ],
  );
}
