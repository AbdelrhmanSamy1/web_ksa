import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:web_ksa/responsiveness.dart';
import 'package:web_ksa/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyBqk8lxm8h9WyGeToWOwiv20o9SYFftr0o",
        authDomain: "web-ksa.firebaseapp.com",
        projectId: "web-ksa",
        storageBucket: "web-ksa.appspot.com",
        messagingSenderId: "486707698602",
        appId: "1:486707698602:web:eaa2142302d090b2d829d3",
        measurementId: "G-7EHR9RLSVX"
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
