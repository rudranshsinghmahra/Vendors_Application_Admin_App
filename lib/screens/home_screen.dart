import 'package:flutter/material.dart';
import 'package:vendor_app_for_grocery/widgets/drawers_menu_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String id = 'home-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: const Center(
          child: Text("HomeScreen"),
        ),
        appBar: AppBar(title: const Text('Drawer Menu')),
        drawer: const DrawerWidget());
  }
}
