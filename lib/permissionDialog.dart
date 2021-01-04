import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:chat_app/permissions_service.dart';

class PermissionDialog{
  Future<void> showAlertDialog(parentContext,bool permanent,Function pre){
      return showDialog(
        barrierDismissible: false,
        context: parentContext,
        builder: (context)=>AlertDialog(
          title: Text("Permission Required"),
          content: Text("In order to use this app you must have to provide access of your contact."),
          actions: [
            FlatButton(
              child: Text(permanent?"Open Setting":"Ok"),
              onPressed: ()async{
                if(permanent){
                  await openAppSettings();
                }
                Navigator.pop(context);
                await PermissionsService().hasContactsPermission(pre);
                print("hello world");
                return ;
              },
            )
          ],
        )
    );
  }
}