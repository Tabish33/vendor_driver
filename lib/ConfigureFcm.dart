import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfigureFcm extends StatelessWidget {
  Firestore storeDb = Firestore.instance;
  FirebaseMessaging fcm = FirebaseMessaging();

  @override
  Widget build(BuildContext context) {
    return Text("dataa");
  }

   void saveDeviceToken() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid =  prefs.getString("uid");
      String token = await fcm.getToken();
      String ref = "vendor_drivers/${uid}/tokens";

      if (token != null)
        storeDb.collection(ref).document(token).setData({"token": token});
    }

  configureFcm() {
    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }
}
