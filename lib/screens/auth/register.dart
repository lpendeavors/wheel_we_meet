import 'package:flutter/material.dart';

import 'forms/register_form.dart';

class RegisterScreen extends StatelessWidget {
  static const routeName = '/register';

  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 160),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Register',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 16),
            RegisterForm(),
          ],
        ),
      ),
    );
  }
}
