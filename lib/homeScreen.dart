import 'package:chat_app/permissions_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/showAllContact.dart';
import 'package:chat_app/loginScreen.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/splashScreen.dart';
import 'package:chat_app/chatScreen.dart';
import 'package:contacts_service/contacts_service.dart';  

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool showSplash = true;
  Map chatContact=new Map();
  String currentUser;
  @override
  void initState(){
    super.initState();
    getChats();
  }

  void getChats()async{
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    contacts.forEach((contact){
      if(contact.phones.isNotEmpty){
          String phone = contact.phones.elementAt(0).value;
          phone = phone.replaceAll(" ", "");
          phone = phone.replaceAll("+91", "");
          chatContact[phone]=contact.displayName ?? '';
      }
    });
    currentUser = user.phoneNumber.replaceAll("+91", "");
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