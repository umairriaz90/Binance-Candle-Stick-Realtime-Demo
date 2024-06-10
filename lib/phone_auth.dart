import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// PhoneAuth Class (refer to previous response for implementation)
class PhoneAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> verifyPhoneNumber(String phoneNumber, BuildContext context) async {
    try {
      final verificationId = await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          // Auto-verification completed (rare)
          await _auth.signInWithCredential(phoneAuthCredential);
          Navigator.pushReplacementNamed(context, '/home'); // Navigate to home screen
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
          // Handle verification failure
        },
        codeSent: (String verificationId, int? resendToken) async {
          final codeController = TextEditingController(); // Create a controller for code input
          final code = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Enter Verification Code'),
              content: TextField(
                controller: codeController, // Use the created controller
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // Close dialog on cancel
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final enteredCode = codeController.text; // Get code from controller
                    verifyCode(verificationId, enteredCode);
                  },
                  child: Text('Verify'),
                ),
              ],
            ),
          );
          if (code != null) {
            verifyCode(verificationId, code);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle auto-retrieval timeout
        },
      );
      return verificationId; // Explicitly return verificationId (might be null)
    } on PlatformException catch (e) {
      print(e.message);
      return null; // Handle platform errors
    }
  }

  Future<void> verifyCode(String verificationId, String code) async {
    try {
      final phoneAuthCredential = PhoneAuthCredential(verificationId: verificationId, smsCode: code);
      await _auth.signInWithCredential(phoneAuthCredential);
      Navigator.pushReplacementNamed(context, '/home'); // Navigate to home screen
    } on FirebaseAuthException catch (e) {
      print(e.message);
      // Handle verification code errors
      return null;
    }
  }
}