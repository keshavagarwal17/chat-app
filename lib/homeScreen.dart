import 'package:chat_app/permissions_service.dart';
import 'package:flutter/material.dart';


class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children:[
        Text("hello user",style: TextStyle(color:Colors.white),),
        RaisedButton(
          child: Text("contact permission"),
          onPressed: ()async{
            bool ispermitted = await PermissionsService().hasContactsPermission();
            if(ispermitted){
               print("Already given");
            }else{
              bool pm = await PermissionsService().requestContactPermission(
                 onPermissionDenied: () {
                    print('Permission has been denied');
                  }
              );
              print(pm);
            }
          },
        )
      ]
    );
  }
}