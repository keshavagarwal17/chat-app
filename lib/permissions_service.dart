import 'package:permission_handler/permission_handler.dart';

class PermissionsService {

  Future<bool> requestContactPermission({Function onPermissionDenied}) async {
    var result = await [Permission.contacts].request();
    if (result[Permission.contacts] == PermissionStatus.granted) {
      return true;
    }else{
      onPermissionDenied();
      return false;
    }
  }

  Future<bool> hasContactsPermission() async {
    var permissionStatus = await Permission.contacts.status;
    return permissionStatus == PermissionStatus.granted;
  }
}