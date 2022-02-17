import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vendor_app_for_grocery/providers/auth_provider.dart';
import 'package:vendor_app_for_grocery/screens/home_screen.dart';
import 'package:vendor_app_for_grocery/screens/login_screen.dart';
import 'package:vendor_app_for_grocery/screens/registration_screen.dart';
import 'package:vendor_app_for_grocery/screens/reset_password_screen.dart';
import 'package:vendor_app_for_grocery/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ListenableProvider(
          create: (_) => AuthProvider(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => const SplashScreen(),
        RegistrationScreen.id: (context) => const RegistrationScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        ResetPasswordScreen.id: (context) => const ResetPasswordScreen(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple, fontFamily: 'Lato'),
    );
  }
}
