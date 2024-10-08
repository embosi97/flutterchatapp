import 'package:chatapp_firebase/screens/chat_screen.dart';
// import 'package:chatapp_firebase/screens/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Initialize Firebase for both web and mobile platforms
  if (kIsWeb) {
    await Firebase.initializeApp(options: const FirebaseOptions(
      apiKey: "AIzaSyBJtO7aClCdE9G_rmVUBPc7qrMSz_Rwnf8",
      authDomain: "fir-config-9f15a.firebaseapp.com",
      projectId: "fir-config-9f15a",
      storageBucket: "fir-config-9f15a.appspot.com",
      messagingSenderId: "648164446698",
      appId: "1:648164446698:web:a45c2f8b32a53425ee6293",
    ));
  } else { //IOS or Android
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Chat App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: LoginScreen(), //Show the login screen first
//     );
//   }
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(), // Navigate directly to ChatScreen
    );
  }
}