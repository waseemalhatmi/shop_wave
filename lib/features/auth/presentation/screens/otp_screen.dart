import 'package:flutter/material.dart';

/// Placeholder for OTP Screen.
/// Implemented fully in Phase 2 — Auth.
class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('OTP Verification')),
        body: Center(
          child: Text(
            'OTP sent to: $email\n(Coming in Phase 2)',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
}
