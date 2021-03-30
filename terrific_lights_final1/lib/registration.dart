import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:terrific_lights_final1/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:terrific_lights_final1/patient_info_fill.dart';
import 'package:terrific_lights_final1/patient_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:terrific_lights_final1/traffic_police.dart';

class registration extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _registrationState createState() => _registrationState();
}

int selectedRadio;

@override
void initState() {
  initState();
  selectedRadio = 0;
}

class _registrationState extends State<registration> {
  @override
  String email, password, hospitalid;
  bool password_match = false;
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // Changes the selected value on 'onChanged' click on each radio button
    setSelectedRadio(int val) {
      setState(() {
        selectedRadio = val;
      });
    }

    return SafeArea(
      child: Scaffold(
        body: Container(
          height: height,
          width: width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height : 30.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height : 10.0,
                      ),
                      Text(
                        ' Sign Up',
                        style: TextStyle(
                            fontSize: 25.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                RadioListTile(
                  value: 1,
                  groupValue: selectedRadio,
                  title: Text("Doctor" , style: TextStyle(fontSize: 19.0)),
                  activeColor: Colors.green,
                  onChanged: (val) {
                    setSelectedRadio(val);
                    //print(selectedRadio);
                  },
                ),
                RadioListTile(
                  value: 2,
                  groupValue: selectedRadio,
                  title: Text("EMT", style: TextStyle(fontSize: 19.0)),
                  activeColor: Colors.red,
                  onChanged: (val) {
                    setSelectedRadio(val);
                  },
                ),
                RadioListTile(
                  value: 3,
                  groupValue: selectedRadio,
                  title: Text("Traffic Police", style: TextStyle(fontSize: 19.0)),
                  activeColor: Colors.red,
                  onChanged: (val) {
                    setSelectedRadio(val);
                  },
                ),
                SizedBox(
                  height: 100.0,
                ),
                TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      suffixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onChanged: (value) {
                      email = value;
                    }),
                SizedBox(
                  height: 20.0,
                ),
                TextField(
                    textAlign: TextAlign.center,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      suffixIcon: Icon(Icons.visibility_off),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onChanged: (value) {
                      password = value;
                    }),
                SizedBox(
                  height: 20.0,
                ),
                TextField(
                    textAlign: TextAlign.center,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      suffixIcon: Icon(Icons.visibility_off),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != password)
                        password_match = false;
                      else
                        password_match = true;
                      print(password_match);
                    }),
                SizedBox(
                  height: 20.0,
                ),
                TextField(
                    textAlign: TextAlign.center,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Hospital ID ( if user is doctor )',
                      suffixIcon: Icon(Icons.add_business_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    onChanged: (value) {
                      hospitalid = value;
                    }),
                SizedBox(
                  height: 30.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width : 1.0,
                      ),
                      RaisedButton(
                        child: Text('Sign Up'),
                        color: Color(0xffEE7B23),
                        onPressed: () async {
                          try {
                            if (password_match == true) {
                              print(email);print(password);
                              await Firebase.initializeApp();
                              final _firestore = await Firestore.instance;
                              final _auth = await FirebaseAuth.instance;
                              if (selectedRadio == 1) {
                                final new_user =
                                    await _auth.createUserWithEmailAndPassword(
                                        email: email, password: password);
                                if (new_user != null) {
                                  _firestore.collection("Authentication").add({
                                    "email" : email,
                                    "profession" : "doctor",
                                    "hospital_id" : hospitalid,
                                  });
                                  Navigator.pushNamed(context, patient_list.id);
                                }
                                else print("new user is null");
                              } else if (selectedRadio == 2) {
                                final new_user =
                                    await _auth.createUserWithEmailAndPassword(
                                        email: email, password: password);
                                if (new_user != null) {
                                  _firestore.collection("Authentication").add({
                                    "email" : email,
                                    "profession" : "emt",
                                    "hospital_id" : null,
                                  });
                                  Navigator.pushNamed(context, patient_info_fill.id);
                                }
                                else print("new user is null");
                              }
                              else if (selectedRadio == 3) {
                                final new_user =
                                    await _auth.createUserWithEmailAndPassword(
                                        email: email, password: password);
                                if (new_user != null) {
                                  _firestore.collection("Authentication").add({
                                    "email" : email,
                                    "profession" : "traffic_police",
                                    "hospital_id" : null,
                                  });
                                  Navigator.pushNamed(context, traffic_police.id);
                                }
                                else print("new user is null");
                              }
                            } else
                              print("passwords do not match");
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
                    Navigator.pushNamed(context, login_screen.id);
                  },
                  child: Text.rich(
                    TextSpan(text: 'Already have an account ?', children: [
                      TextSpan(
                        text: ' Sign In',
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
    );
  }
}
