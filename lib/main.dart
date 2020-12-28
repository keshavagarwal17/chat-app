import 'package:chat_app/homeScreen.dart';
import 'package:chat_app/loginScreen.dart';
import 'package:chat_app/splashScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

User user;
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool loggedIn,loading=true;

  @override
  void initState() {
    super.initState();
    isSignedIn();
  }

  void isSignedIn(){
    FirebaseAuth _auth = FirebaseAuth.instance;
    user = _auth.currentUser;
    if(user!=null){
      setState(()=>{loggedIn = true,loading = false});
    }else{
      setState(()=>{loggedIn = false,loading = false});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home:  Scaffold(
        backgroundColor:Colors.black,
        appBar: AppBar(title:Text("Chat App",style: TextStyle(color:Color(0xff4ACFAC)),),backgroundColor: Color(0xff262833),),
        body:loading?Splash():(loggedIn?Home():Login())
      ),
    );
  }
}
