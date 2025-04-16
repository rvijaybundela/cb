import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';

class AuthButtons extends StatelessWidget {
  const AuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAuthButton(context, 'Login', Colors.blue, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
        }),
        const SizedBox(width: 20),
        _buildAuthButton(context, 'Sign Up', Colors.orange, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
        }),
      ],
    );
  }

  Widget _buildAuthButton(BuildContext context, String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18)),
    );
  }
}
