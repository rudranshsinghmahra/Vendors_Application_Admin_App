import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vendor_app_for_grocery/screens/login_screen.dart';
import 'package:vendor_app_for_grocery/screens/registration_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String id = 'home-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: () {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacementNamed(context, LoginScreen.id);
        },
          child: const Text("Logout"),
        )
      ),
    );
  }
}
