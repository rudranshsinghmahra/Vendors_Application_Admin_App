import 'package:flutter/material.dart';
import 'package:vendor_app_for_grocery/screens/login_screen.dart';
import 'package:vendor_app_for_grocery/widgets/image_picker_screen.dart';
import 'package:vendor_app_for_grocery/widgets/register_form.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({Key? key}) : super(key: key);
  static const String id = 'registration-screen';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  const ShopPicCard(),
                  const RegisterForm(),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, LoginScreen.id);
                    },
                    child: RichText(
                      text: const TextSpan(text: '', children: [
                        TextSpan(
                            text: "Already have an account?",
                            style: TextStyle(color: Colors.black)),
                        TextSpan(
                          text: " Login",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
