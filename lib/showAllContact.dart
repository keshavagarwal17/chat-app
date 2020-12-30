import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';  
import 'package:chat_app/chatScreen.dart';
import 'package:chat_app/loginScreen.dart';
import 'package:chat_app/loading.dart';

class ShowContact extends StatefulWidget {
  @override
  _ShowContactState createState() => _ShowContactState();
}

class _ShowContactState extends State<ShowContact> {
  List<Contact> _contacts=[];

  @override
  void initState() {
    getContacts();
    super.initState();
  }

  Future<void> getContacts() async {
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    contacts.forEach((contact) async{
      if(contact.phones.isNotEmpty){
          String phone = contact.phones.elementAt(0).value;
          phone = phone.replaceAll(" ", "");
          phone = phone.replaceAll("+91", "");

          final doc = await userCollection.doc(phone).get();
          if(doc.exists){
            setState(()=>_contacts.add(contact));
          }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:Color(0xff181a21),
        appBar: AppBar(title:Text("Contacts",style: TextStyle(color:Color(0xff4ACFAC)),),backgroundColor: Color(0xff262833),),
        body:_contacts.isEmpty?Loading():ListView.builder(
          itemCount: _contacts?.length??0,
          itemBuilder: (BuildContext context,int index){
            Contact contact = _contacts?.elementAt(index);
            return ListTile(
                  subtitle: Text(contact.phones?.elementAt(0)?.value??"0",style:TextStyle(color:Colors.white54)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
                  leading: (contact.avatar != null && contact.avatar.isNotEmpty)
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(contact.avatar),
                        )
                      : CircleAvatar(
                          child: Text(contact.initials(),style:TextStyle(color:Colors.black)),
                          backgroundColor: Color(0xff4ACFAC),
                        ),
                  title: Text(contact.displayName ?? '',style:TextStyle(color:Colors.white,fontSize: 16)),
                  onTap:(){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context )=>ChatScreen(phone:contact.phones.elementAt(0).value,name:contact.displayName ?? '')));
                  },
                );
          },
        )
    );
  }
}