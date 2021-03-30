import 'package:flutter/material.dart';
import 'package:terrific_lights_final1/login_screen.dart';
import 'package:terrific_lights_final1/patient_info_fill.dart';
import 'package:terrific_lights_final1/registration.dart';
import 'package:terrific_lights_final1/single_patient_info_doc.dart';
import 'package:terrific_lights_final1/patient_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:terrific_lights_final1/traffic_police.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Terrific_Lights());
}

class Terrific_Lights extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: login_screen.id,
      routes : {
        login_screen.id : (context) => login_screen(),
        registration.id : (context) => registration(),
        patient_info_fill.id : (context) => patient_info_fill(),
        single_patient_info_doc.id : (context) => single_patient_info_doc(),
        patient_list.id : (context) => patient_list(),
        traffic_police.id : (context) => traffic_police(),
      }
    );
  }
}

