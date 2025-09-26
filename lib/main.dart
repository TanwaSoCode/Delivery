// import 'package:delivery/pages/page_Register.dart';
// import 'package:delivery/pages/page_login.dart';
import 'package:delivery/pages/select_Screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(textTheme: GoogleFonts.notoSansThaiLoopedTextTheme()),
      title: 'Flutter Demo',
      home: const SelectScreen(),
    );
  }
}
