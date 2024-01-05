import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:web_ksa/screens/login.dart';
import 'home.dart'; // Import your home screen

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();

  Future<void> _signUp() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Update the user document in the "users" collection
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'email': _emailController.text,
        'password': _passwordController.text,
        'userId': userCredential.user?.uid,
      });

      // Navigate to home screen after successful sign-up
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      print('Error signing up: $e');
      // Handle sign-up errors, show a message to the user, etc.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(

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
              SizedBox(height: 20,),

              Container(width: 500,
                child: TextField(
                  controller: _displayNameController,
                  decoration: InputDecoration(labelText: 'Display Name',border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
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
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                },
                child: Text("لديك حساب بالفعل؟ سجل الان",style: TextStyle(color: Colors.teal),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}