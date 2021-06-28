
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:planerio/google/google_sign_in.dart';
import 'package:provider/provider.dart';

class GoogleSignupButton extends StatelessWidget {
  Widget build(BuildContext context) => Container(
      padding: EdgeInsets.all(4),
      child: OutlinedButton.icon(
        label: Text('Sign In with Google'),
        icon: FaIcon(
          FontAwesomeIcons.google,
          color: Colors.red,
        ),
        onPressed: () {
          final provider = Provider.of<GoogleSignInProvider>(context,listen: false);
          // final provider =
          // Provider.of<GoogleSignInProvider>(context, listen: false);
          provider.googleLogin();
        },
      ));
}
