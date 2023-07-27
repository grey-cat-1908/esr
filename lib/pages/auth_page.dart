import 'package:flutter/material.dart';
import 'package:esr_app/forms/login_form.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const LoginForm()
    );
  }
}
