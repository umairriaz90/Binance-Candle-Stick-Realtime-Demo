import 'package:flutter/material.dart';
import 'package:binance_demo/phone_auth.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneNumberController = TextEditingController();

  Future<void> _login() async {
    final phoneNumber = _phoneNumberController.text;
    if (phoneNumber.isEmpty) {
      return; // Handle empty phone number
    }

    final phoneAuth = PhoneAuth();
    final verificationId = await phoneAuth.verifyPhoneNumber(phoneNumber, context);
    // Handle verificationId (might be null)

    // Assuming successful verification
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            ElevatedButton(
              onPressed: _login,
              child: Text('Send Verification Code'),
            ),
          ],
        ),
      ),
    );
  }
}