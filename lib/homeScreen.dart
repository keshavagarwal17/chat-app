import 'package:chat_app/permissions_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/showAllContact.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children:[
        Text("hello user",style: TextStyle(color:Colors.white),),
        RaisedButton(
          child: Text("see contact"),
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
        )
      ]
    );
  }
}