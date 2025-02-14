import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationHandler {
  final firebaseToken =FirebaseMessaging.instance;
  generateToken() async {
      await firebaseToken.requestPermission();
      // For testing purposes print the Firebase Messaging token
      String? token = await firebaseToken.getToken();
      if(token != null || token != ''){
        return token;
      }
      else{
        return null;
      }
  }

  deleteToken() async {
    await firebaseToken.requestPermission();
    await firebaseToken.deleteToken();
    return ;
  }
}
class NotificationHandlerWeb {
  final firebaseToken =null;

}
