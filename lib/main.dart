import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'phone_auth_screen.dart';
import 'walletProvider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCQTo-OrPzu6sgIlNdwOwfxl7yWhxSniJM",
      authDomain: "dewbet-jkfn88.firebaseapp.com",
      projectId: "dewbet-jkfn88",
      storageBucket: "dewbet-jkfn88.appspot.com",
      messagingSenderId: "264435704665",
      appId: "1:264435704665:web:8c2b74c94871aac8c7a248"
    ),
  );
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: MaterialApp(
        title: 'Phone OTP Authentication',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: PhoneAuthScreen(),
      ),
    );
  }
}
