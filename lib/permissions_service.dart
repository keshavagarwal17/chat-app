import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  Future<void> requestContactPermission(Function presentDialog) async {
    var result = await [Permission.contacts].request();
    if (result[Permission.contacts] == PermissionStatus.granted) {
      return;
    }else if(result[Permission.contacts] == PermissionStatus.denied){
      await presentDialog(false);
    }else if(result[Permission.contacts] == PermissionStatus.permanentlyDenied){
      await presentDialog(true);
    }
  }

  Future<void> hasContactsPermission(Function presentDialog) async {
    var permissionStatus = await Permission.contacts.status;
    if(permissionStatus==PermissionStatus.undetermined){
       await requestContactPermission(presentDialog);
       return;
    }
    else if(permissionStatus == PermissionStatus.granted){
      print("hello");
      return ;
    }else if(permissionStatus == PermissionStatus.permanentlyDenied){
      await presentDialog(true);
      return;
    }else if(permissionStatus==PermissionStatus.denied){
      await requestContactPermission(presentDialog);
    }
  }
  }

  // bool ispermitted = await PermissionsService().hasContactsPermission();
          // if(ispermitted){
          //     print("Already given");
          //     Navigator.push(context,MaterialPageRoute(builder: (BuildContext context)=>ShowContact()));
          // }else{
          //   bool pm = await PermissionsService().requestContactPermission(
          //       onPermissionDenied: () {
          //         print('Permission has been denied');
          //       }
          //   );
          //   if(pm){
          //     Navigator.push(context,MaterialPageRoute(builder: (BuildContext context)=>ShowContact()));
          //   }
          // }
