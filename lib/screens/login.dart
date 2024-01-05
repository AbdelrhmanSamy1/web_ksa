import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:web_ksa/screens/register.dart';

import 'home.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Navigate to home screen after successful sign-in and clear the stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
            (route) => false,
      );
    } catch (e) {
      print('Error signing in: $e');
      // Handle sign-in errors, show a message to the user, etc.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(width: 500,
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email',border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),),
                ),
              ),
              SizedBox(height: 20,),
              Container(width: 500,
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password',border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),),
                  obscureText: true,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                child: Text('تسجيل دخول',style: TextStyle(color: Colors.white),),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Navigate to register screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
                child: Text("ليس لديك حساب ؟ سجل الان",style: TextStyle(color: Colors.teal),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
