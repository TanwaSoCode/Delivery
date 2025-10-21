import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery/firebase_options.dart';
import 'package:delivery/pages/%E0%B9%8AUser_function/create_parcel.dart';
import 'package:delivery/pages/%E0%B9%8AUser_function/follow_send_order.dart';
import 'package:delivery/pages/%E0%B9%8AUser_function/follow_one_order.dart';
import 'package:delivery/pages/select_Screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(textTheme: GoogleFonts.notoSansThaiLoopedTextTheme()),
      title: 'Flutter Demo',
      home: const SelectScreen(phone: '',),
      // home: const FollowOneOrderPage(orderData: {},),  
    
    );
  }
}
