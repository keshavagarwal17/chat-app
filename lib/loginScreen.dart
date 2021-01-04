import 'package:chat_app/homeScreen.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final CollectionReference userCollection =FirebaseFirestore.instance.collection('Users');

Future registerUser(String number,BuildContext context)async{
    FirebaseAuth _auth = FirebaseAuth.instance;
    String code = "+91";
    _auth.verifyPhoneNumber(
      phoneNumber: code+number, 
      timeout: Duration(seconds: 60),
      verificationCompleted: (AuthCredential authCredential)async{
        try{
          UserCredential result = await _auth.signInWithCredential(authCredential);
          print(result);
          if(result.additionalUserInfo.isNewUser){
            userCollection.doc(number).set({
              "number":number,
              "uid":result.additionalUserInfo.providerId
            });
          }
          user = _auth.currentUser;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=>Home()));
        }catch(e){
          print("Error in verificationCompleted");
          print(e);
        }
      }, 
      verificationFailed: (FirebaseAuthException authException){
        print("Error in verificationFailed");
        print(authException.message);
      }, 
      codeSent: (String verificationId,[int forceResendingToken])async{
        TextEditingController _smsController = new TextEditingController();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context)=>AlertDialog(
            title: Text("Enter OTP Code"),
            content: TextField(
                controller: _smsController,
            ),
            actions: [
              FlatButton(
                child: Text("Done"),
                onPressed: ()async{
                  String smsCode = _smsController.text.trim();
                  AuthCredential _credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
                  try{
                    UserCredential result = await _auth.signInWithCredential(_credential);
                    print(result);
                    if(result.additionalUserInfo.isNewUser){
                      userCollection.doc(number).set({
                        "number":number,
                        "uid":result.additionalUserInfo.providerId
                      });
                    }
                    user = _auth.currentUser;
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context)=>Home()));
                  }catch(e){
                    print("Error in codesent");
                    print(e);
                  }
                },
              )
            ],
          )
        );
      }, 
      codeAutoRetrievalTimeout: (String verificationId){
        print(verificationId);
        print("Timout");
      }
    );
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController numberController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:Color(0xff181a21),
        appBar: AppBar(title:Text("Chat App",style: TextStyle(color:Color(0xff4ACFAC)),),backgroundColor: Color(0xff262833),),
        body: Padding(
        padding: const EdgeInsets.only(top:45.0,left:15,right:15),
        child: ListView(
          children: [
            TextFormField(
              controller: numberController,
              keyboardType: TextInputType.phone,
              autofocus: true,
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xff262833),
                focusColor: Color(0xff262833),
                hintStyle: TextStyle(color:Colors.white54),
                hintText: "Enter Your Phone Number",
                labelStyle:TextStyle(color:Color(0xff4ACFAC)) ,
                labelText: "Phone Number",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:Color(0xff4ACFAC),
                  ),
                )
              ),
            ),
            SizedBox(height:50),
            SizedBox(
              width:double.infinity,
              child: FlatButton(
                padding: EdgeInsets.all(10),
                color: Color(0xff4ACFAC),
                child: Text("Verify",style:TextStyle(color:Color(0xff262833),fontSize:17)),
                onPressed: (){
                  registerUser(numberController.text.trim(), context);
                },
                // minWidth: ,
              ),
            )
          ],
        ),
      ),
    );
  }
}