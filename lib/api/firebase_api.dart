import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi{
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification () async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = _firebaseMessaging.getToken();
    print("token$fCMToken");
    initPushNotification();
  }

  //function to handle received message
  void handleMessage (RemoteMessage? message){
    if(message == null) return;
  }

  //function to initialise the background setting
  Future initPushNotification () async {
    //handle message if app was terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    //attach event listener for when a notification opens app
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}