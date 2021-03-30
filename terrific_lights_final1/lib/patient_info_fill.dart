//Patient info to fill by emt.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:terrific_lights_final1/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';





class patient_info_fill extends StatefulWidget {
  static const String id = 'patient_info_fill_screen';
  @override
  _patient_info_fillState createState() => _patient_info_fillState();
}

class _patient_info_fillState extends State<patient_info_fill> {
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  User loggedInUser;

  void ConfirmLogOut(BuildContext context) async{
    var alertDialog = AlertDialog(
      title: Text("Log Out?"),
      content: Text("Do you want to log out?"),
      actions: [
        FlatButton(
            child: Text("No"),
            onPressed: (){
              Navigator.pop(context);
            }
        ),
        FlatButton(
            child: Text("Yes"),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushNamed(context, login_screen.id) ;
            }
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        }
    );
  }

  void ConfirmSubmit(BuildContext context) async{
    var alertDialog = AlertDialog(
      title: Text("Submit?"),
      content: Text("Do you want to submit?"),
      actions: [
        FlatButton(
            child: Text("No"),
            onPressed: (){
              Navigator.pushNamed(context, patient_info_fill.id) ;
            }
        ),
        FlatButton(
            child: Text("Yes"),
            onPressed: () async {
              await _firestore.collection("Patient_info").add({
                "information": Patient_Information,
              });
              ConfirmSubmit1(context);
            }
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        }
    );
  }

  void ConfirmSubmit1(BuildContext context) async{
    var alertDialog = AlertDialog(
      title: Text("Submited"),
      content: Text("The information is submitted"),
      actions: [
        FlatButton(
            child: Text("OK"),
            onPressed: (){
              Navigator.pop(context);
            }
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        }
    );
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  String email_of_user = "a";
  bool isSwitched = false, got_match = false;

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        email_of_user = loggedInUser.email;
        print(loggedInUser.email);
      }
      final message =
      await _firestore.collection("ambulance_location").getDocuments();
      for (var messages in message.documents) {
        if (messages.data()["email"] == loggedInUser.email) {
          got_match = true;
          break;
        }
      }
      setState(() {
        if(got_match) isSwitched = true;
      });
    } catch (e) {
      print(e);
      print(";_;");
    }
  }
  String email_to_name(String email) {
    String name = "";
    String permitted = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for(var i=0; i<name.length; i++) {
        if(permitted.contains(email[i])) {
          name += email[i];
        }
        else break;
    }
    return name;
  }
  bool checkbox1 = true;
  bool checkbox2 = false;
  String gender = 'male';
  String dropdownValue = 'A';
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  var Patient_Information = new List(15);


  var textValue = 'Switch is OFF';

  void toggleSwitch(bool value) async{

    if(isSwitched == false)
    {
      //getting location when switch in on
      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
      String location_of_user = placemark[0].name + ", " + placemark[0].subLocality + ", "+ placemark[0].subAdministrativeArea + ", " + placemark[0].locality;
      //print(location_of_user);
      //Placemark place = placemark[0];
      await _firestore.collection("ambulance_location").add({
        "latitude": position.latitude.toString(),
        "longitude" : position.longitude.toString(),
        "address" : location_of_user,
        "email" : loggedInUser.email,
        "switch_status" : true,
      });   // all string
      //var onePointOne = double.parse('1.1');   to convert string to double
      setState(() {
        isSwitched = true;
        textValue = 'Switch Button is ON';
      });

      print('Switch Button is ON');
    }
    else
    {
      // deleting the location record when button is switching to off
      final message =
      await _firestore.collection("ambulance_location").getDocuments();
      for (var messages in message.documents) {
        if (messages.data()["email"] == loggedInUser.email) {
          _firestore
              .collection("ambulance_location")
              .document(messages.id)
              .delete();
        }
      }
      setState(() {
        isSwitched = false;
        textValue = 'Switch Button is OFF';
      });
      print('Switch Button is OFF');
    }
  }

  // void confirmAlertPolice(BuildContext context) async {
  //   var alertDialog = AlertDialog(
  //     title: Text("Alert traffic police?"),
  //     content: Text("Are you sure to alert nearby traffic police? Don't forget to turn it back to green when free from traffic."),
  //     actions: [
  //       FlatButton(
  //           child: Text("Yes"),
  //           onPressed: (){
  //             confirm_switch = true;
  //             //sendLocation();
  //             print("location will be sent");
  //             Navigator.pop(context);
  //           }
  //       ),
  //       FlatButton(
  //           child: Text("No"),
  //           onPressed: (){
  //             confirm_switch = true;
  //             //sendLocation();
  //             print("location will be sent");
  //             Navigator.pop(context);
  //           }
  //       ),
  //     ],
  //   );
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return alertDialog;
  //       }
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            //automaticallyImplyLeading: false,
            title: Text('Patient Form'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                tooltip: 'Log Out',
                onPressed: () {
                  ConfirmLogOut(context);
                },
              ),
            ],
          ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(email_to_name(email_of_user)),
              accountEmail: Text(email_of_user, style: TextStyle(fontSize: 20.0)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  email_of_user[0],
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            SizedBox(height : 10.0),
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 2.0),
              child: Text("Notify Traffic police that you are stuck in traffic - ",
                  style : TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      )
                  ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text("Note : Don't forget to turn it back to green when free from traffic.",
                  style : TextStyle(
                    fontSize: 15.0,
                    //fontWeight: FontWeight.bold,
                  )
              ),
            ),
            Center(
              child: Transform.scale(
                scale : 1.5,
                child: Switch(
                  onChanged: toggleSwitch,
                  value: isSwitched,
                  activeColor: Colors.red,
                  activeTrackColor: Colors.grey,
                  inactiveThumbColor: Colors.green,
                  inactiveTrackColor: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(children: [
                Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(5.0))),
                  onChanged: (value) {
                    Patient_Information[0] = value;
                  },
                ),
                SizedBox(height: 30.0),
                Text(
                  'EMT contact no.',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
                ),
                SizedBox(height: 5.0),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(5.0))),
                  onChanged: (value) {
                    Patient_Information[1] = value;
                  },
                ),
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  'Hospital ID',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
                ),
                SizedBox(height: 5.0),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(20.0))),
                  onChanged: (value) {
                    Patient_Information[2] = value;
                  },
                ),
                SizedBox(height: 30.0),
                Text(
                  'Gender',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
                ),
                SizedBox(height: 5.0),
                Row(children: [
                  SizedBox(
                    width: 30.0,
                  ),
                  SizedBox(
                    width: 10,
                    child: Radio(
                      value: 'Male',
                      groupValue: gender,
                      activeColor: Colors.orange,
                      onChanged: (value) {
                        setState(() {
                          gender = value;
                          Patient_Information[3] = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Text('Male'),
                  SizedBox(width: 50.0),
                  SizedBox(
                    width: 10,
                    child: Radio(
                      value: 'Female',
                      groupValue: gender,
                      activeColor: Colors.orange,
                      onChanged: (value) {
                        setState(() {
                          gender = value;
                          Patient_Information[3] = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Text('Female'),
                  SizedBox(width: 50.0),
                  SizedBox(
                    width: 10,
                    child: Radio(
                      value: 'Others',
                      groupValue: gender,
                      activeColor: Colors.orange,
                      onChanged: (value) {
                        setState(() {
                          gender = value;
                          Patient_Information[3] = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Text('Others'),
                ]),
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  'Age',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
                ),
                SizedBox(height: 5.0),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(

                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0))),
                  onChanged: (value) {
                    Patient_Information[4] = value;
                  },
                ),
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  'G.C',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
                ),
                SizedBox(height: 5.0),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(

                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0))),
                  onChanged: (value) {
                    Patient_Information[5] = value;
                  },
                ),
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  'Blood Pressure',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
                ),
                SizedBox(height: 5.0),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(

                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0))),
                  onChanged: (value) {
                    Patient_Information[6] = value;
                  },
                ),
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  'Pulse Rate',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
                ),
                SizedBox(height: 5.0),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(

                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0))),
                  onChanged: (value) {
                    Patient_Information[7] = value;
                  },
                ),
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  'Temperature',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
                ),
                SizedBox(height: 5.0),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(

                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0))),
                  onChanged: (value) {
                    Patient_Information[8] = value;
                  },
                ),
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  'Oxygen saturation',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
                ),
                SizedBox(height: 5.0),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(

                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0))),
                  onChanged: (value) {
                    Patient_Information[9] = value;
                  },
                ),
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  'Investigation',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
                ),
                SizedBox(height: 5.0),
                Text(
                  'a. RBS',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.0),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(

                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0))),
                  onChanged: (value) {
                    Patient_Information[10] = value;
                  },
                ),
                SizedBox(height: 10.0),
                Text(
                  'b. LFT',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.0),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(

                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0))),
                  onChanged: (value) {
                    Patient_Information[11] = value;
                  },
                ),
                SizedBox(height: 10.0),
                Text(
                  'c. RFT',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.0),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(

                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0))),
                  onChanged: (value) {
                    Patient_Information[12] = value;
                  },
                ),
                SizedBox(height: 10.0),
                Text(
                  'd. CBP',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.0),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(

                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0))),
                  onChanged: (value) {
                    Patient_Information[13] = value;
                  },
                ),
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  'Any H/O : ',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0),
                ),
                SizedBox(height: 5.0),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(

                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0))),
                  onChanged: (value) {
                    Patient_Information[14] = value;
                  },
                ),

                SizedBox(height: 10.0),

                RaisedButton(
                  color: Colors.orange,
                  child: Text('Submit', style: TextStyle(color: Colors.white)),
                  onPressed: () async{
                    ConfirmSubmit(context);
                  },
                ),
              ]),
            ),
          ),
    );
  }
}
