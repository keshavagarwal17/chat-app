import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';  
import 'package:chat_app/chatScreen.dart';

class ShowContact extends StatefulWidget {
  @override
  _ShowContactState createState() => _ShowContactState();
}

class _ShowContactState extends State<ShowContact> {
  Iterable<Contact> _contacts;

  @override
  void initState() {
    getContacts();
    super.initState();
  }

  Future<void> getContacts() async {
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts.where((contact)=>contact.phones.isNotEmpty);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:Color(0xff181a21),
        appBar: AppBar(title:Text("Contacts",style: TextStyle(color:Color(0xff4ACFAC)),),backgroundColor: Color(0xff262833),),
        body:_contacts==null?Container():ListView.builder(
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
                          child: Text(contact.initials()),
                          backgroundColor: Theme.of(context).accentColor,
                        ),
                  title: Text(contact.displayName ?? '',style:TextStyle(color:Colors.white,fontSize: 16)),
                  onTap:(){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context )=>ChatScreen()));
                  },
                  //This can be further expanded to showing contacts detail
                  // onPressed().
                );
          },
        )
    );
  }
}