import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'wallet_screen.dart';
import 'package:binance_demo/bet_screen.dart' as bet_screen;
import 'package:binance_demo/bets_screen.dart' as bets_screen;
import 'email_password_auth_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EmailPasswordAuthScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WalletScreen()),
                );
              },
              child: Text('Go to Wallet'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => bet_screen.BetScreen()),
                );
              },
              child: Text('Place a Bet'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => bets_screen.BetsScreen()),
                );
              },
              child: Text('View Placed Bets'),
            ),
          ],
        ),
      ),
    );
  }
}
