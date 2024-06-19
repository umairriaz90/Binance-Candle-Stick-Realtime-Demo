import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'email_password_auth_screen.dart';
import 'home_screen.dart';
import 'walletProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCQTo-OrPzu6sgIlNdwOwfxl7yWhxSniJM",
      authDomain: "dewbet-jkfn88.firebaseapp.com",
      projectId: "dewbet-jkfn88",
      storageBucket: "dewbet-jkfn88.appspot.com",
      messagingSenderId: "264435704665",
      appId: "1:264435704665:web:8c2b74c94871aac8c7a248",
    ),
  );

  // Use Firebase emulators if running in debug mode
  if (FirebaseAuth.instance.useEmulator('http://localhost:9099').toString().isNotEmpty) {
    FirebaseStorage.instance.useEmulator(host: 'localhost', port: 9199);
  }

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
        title: 'Email/Password Authentication',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: EmailPasswordAuthScreen(), // Show EmailPasswordAuthScreen on launch
      ),
    );
  }
}
