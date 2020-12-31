import 'dart:convert';

import 'package:chat_app/permissions_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/showAllContact.dart';
import 'package:chat_app/loginScreen.dart';
import 'package:chat_app/main.dart';
import 'dart:io' show Platform;
import 'package:chat_app/splashScreen.dart';
import 'package:chat_app/chatScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';  

final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

Iterable<Contact> contacts;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool showSplash = true;
  Map chatContact=new Map();
  String currentUser;

  void configLocalNotification() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }  

  void showNotification(message) async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
    Platform.isAndroid ? 'com.dfa.flutterchatdemo' : 'com.duytq.flutterchatdemo',
    'Flutter chat demo',
    'your channel description',
    playSound: true,
    enableVibration: true,
    importance: Importance.max,
    priority: Priority.high,
  );
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics =
  new NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, message['title'].toString(), message['body'].toString(), platformChannelSpecifics,
      payload: json.encode(message));
}

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      Platform.isAndroid
          ? showNotification(message['notification'])
          : showNotification(message['aps']['alert']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
    userCollection.doc(currentUser)
          .update({'pushToken': token});
    }).catchError((err) {
      print(err.message.toString());
    });
  }
  @override
  void initState(){
    super.initState();
    currentUser = user.phoneNumber.replaceAll("+91", "");
    getChats();
    registerNotification();
    configLocalNotification();
  }

  void getChats()async{
    contacts = await ContactsService.getContacts();
    contacts.forEach((contact){
      if(contact.phones.isNotEmpty){
          String phone = contact.phones.elementAt(0).value;
          phone = phone.replaceAll(" ", "");
          phone = phone.replaceAll("+91", "");
          chatContact[phone]=contact.displayName ?? '';
      }
    });
    
    setState(() {
      showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xff181a21),
      appBar: AppBar(title:Text("Chat App",style: TextStyle(color:Color(0xff4ACFAC)),),backgroundColor: Color(0xff262833),),
      body: showSplash?Splash():ListView(
        children:[
          StreamBuilder(
            stream:userCollection.doc(currentUser).collection("friends").snapshots(),
            builder: (context,snapshot){
              if(snapshot.hasData){
                List<Column> showChatContact = [];
                snapshot.data.docs.forEach((doc){
                  showChatContact.add(
                    Column(
                      children: [
                        GestureDetector(
                          child: ListTile(
                            leading: CircleAvatar(backgroundImage:AssetImage('./assets/user.png'),),
                            title: Text(
                              (chatContact[doc.id]==null)?doc.id.toString():chatContact[doc.id],
                              style:TextStyle(color:Colors.white,fontSize: 16)
                            ),
                          ),
                          onTap: (){
                            Navigator.push(context,MaterialPageRoute(builder: (BuildContext context)=>ChatScreen(
                                        phone: doc.id,
                                        name: (chatContact[doc.id]==null)?doc.id.toString():chatContact[doc.id],
                                    )));
                          },
                        ),
                        Divider(
                          color: Colors.white24
                        )
                      ],
                    )
                  );
                });
                return Column(
                  children: showChatContact,
                );
              }else{
                return Splash();
              }
            },
          ),
        ]
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Color(0xff4ACFAC),
        child: new Icon(
          Icons.chat
        ),
        onPressed: ()async{
          bool ispermitted = await PermissionsService().hasContactsPermission();
          if(ispermitted){
              print("Already given");
              Navigator.push(context,MaterialPageRoute(builder: (BuildContext context)=>ShowContact()));
          }else{
            bool pm = await PermissionsService().requestContactPermission(
                onPermissionDenied: () {
                  print('Permission has been denied');
                }
            );
            if(pm){
              Navigator.push(context,MaterialPageRoute(builder: (BuildContext context)=>ShowContact()));
            }
            print(pm);
          }
        },
      ),
    );
  }
}