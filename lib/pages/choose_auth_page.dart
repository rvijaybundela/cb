import 'package:flutter/material.dart';
import '../widgets/auth_button.dart';
import 'package:untitled/pages/login_page.dart';
import 'package:untitled/pages/signup_page.dart';

class ChooseAuthPage extends StatelessWidget {
  const ChooseAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Welcome to Carbon Shodhak!',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 50),
            AuthButtons(),
          ],
        ),
      ),
    );
  }
}
