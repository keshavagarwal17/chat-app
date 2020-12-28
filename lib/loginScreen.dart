import 'package:chat_app/homeScreen.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future registerUser(String number,String code,BuildContext context)async{
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.verifyPhoneNumber(
      phoneNumber: code+number, 
      timeout: Duration(seconds: 60),
      verificationCompleted: (AuthCredential authCredential)async{
        try{
          final result = await _auth.signInWithCredential(authCredential);
          print(result);
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
                    final result = await _auth.signInWithCredential(_credential);
                    print(result);
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

Widget _buildDropdownItem(Country country) => Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            SizedBox(width:8),
            Text("+${country.phoneCode}(${country.isoCode})",style: TextStyle(color:Colors.white),),
          ],
        ),
      );

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String co = "+91";
  TextEditingController numberController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:45.0,left:15,right:15),
      child: ListView(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CountryPickerDropdown(
              isDense: true,
              iconEnabledColor:Colors.white,
              dropdownColor:Color(0xff262833) ,
              initialValue: 'IN',
              itemBuilder: _buildDropdownItem,
              // itemFilter:  ['AR', 'DE', 'GB', 'CN'].contains(c.isoCode),
              // priorityList:[
              //         CountryPickerUtils.getCountryByIsoCode('GB'),
              //         CountryPickerUtils.getCountryByIsoCode('CN'),
              // ],
              // sortComparator: (Country a, Country b) => a.isoCode.compareTo(b.isoCode),
              onValuePicked: (Country country) {
                co = "+" + country.phoneCode;
                print("${country.name}");
              },
              ),
              
              Expanded(
                // flex: 3,
                child: TextFormField(
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
              ),
            ],
          ),
          SizedBox(height:50),
          SizedBox(
            width:double.infinity,
            child: FlatButton(
              padding: EdgeInsets.all(10),
              color: Color(0xff4ACFAC),
              child: Text("Verify",style:TextStyle(color:Color(0xff262833),fontSize:17)),
              onPressed: (){
                registerUser(numberController.text.trim(),co, context);
              },
              // minWidth: ,
            ),
          )
        ],
      ),
    );
  }
}