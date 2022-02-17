import 'package:flutter/material.dart';
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
                children: const [
                  ShopPicCard(),
                  RegisterForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
