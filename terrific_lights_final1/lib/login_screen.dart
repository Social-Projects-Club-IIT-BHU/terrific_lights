import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:terrific_lights_final1/patient_info_fill.dart';
import 'package:terrific_lights_final1/patient_list.dart';
import 'package:terrific_lights_final1/registration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:terrific_lights_final1/traffic_police.dart';

class login_screen extends StatefulWidget {
  static const String id = 'logic_screen' ;
  @override
  _login_screenState createState() => _login_screenState();
}

class _login_screenState extends State<login_screen> {
  String email_for_login, password_for_login ;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'Assets/login_img4.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Scaffold(
              body: Container(
                height: height,
                width: width,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height : 30.0),
                      Container(
                        width: width * 0.80 ,
                        height: height * 0.35,
                        child: Image.asset('Assets/login_img4.jpg',
                          fit: BoxFit.fill ),
                      ),
                      SizedBox(height : 40.0),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '  Login',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      TextField(
                          textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '  Email',
                          suffixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                          onChanged: (value) {
                            email_for_login = value;
                          }
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextField(
                          textAlign: TextAlign.center,
                          obscureText: true,
                          decoration: InputDecoration(
                              hintText: '  Password',
                              suffixIcon: Icon(Icons.visibility_off),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              )
                          ),
                          onChanged: (value) {
                            password_for_login = value;
                          }
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width : 1.0),
                            RaisedButton(
                              child: Text('Login'),
                              color: Color(0xffEE7B23),
                              onPressed: () async {
                                try {
                                    await Firebase.initializeApp();
                                    final _firestore = await Firestore.instance;
                                    final _auth1 = await FirebaseAuth.instance;
                                    final user = await _auth1.signInWithEmailAndPassword(email: email_for_login, password: password_for_login);
                                    if(user != null)  {
                                      await for( var snapshot in _firestore.collection("Authentication").snapshots()) {
                                        for (var message in snapshot.documents) {
                                          if (message.data()["email"] ==
                                              email_for_login) {
                                            if (message.data()["profession"] ==
                                                "doctor") {
                                              Navigator.pushNamed(context, patient_list.id);
                                            }
                                            else if (message.data()["profession"] ==
                                                "emt") {
                                              Navigator.pushNamed(
                                                  context,
                                                  patient_info_fill.id);
                                            }
                                            else if (message.data()["profession"] ==
                                                "traffic_police") {
                                              Navigator.pushNamed(
                                                  context,
                                                  traffic_police.id);
                                            }
                                            break;
                                          }
                                        }
                                      }
                                    }
                                } catch (e) {
                                  print(e);
                                  print(";_;");
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, registration.id);
                        },
                        child: Text.rich(
                          TextSpan(text: 'Don\'t have an account ?', children: [
                            TextSpan(
                              text: ' Sign Up',
                              style: TextStyle(color: Color(0xffEE7B23)),
                            ),
                          ]),
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]
      ),
    );
  }
}
