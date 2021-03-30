import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:terrific_lights_final1/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:terrific_lights_final1/single_patient_info_doc.dart';

class patient_list extends StatefulWidget {
  static const String id = 'patient_list';
  @override
  _patient_listState createState() => _patient_listState();
}

class _patient_listState extends State<patient_list> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String hospitalid;
  User loggedInUser;
  int no_of_patients = 0;
  Future _future;
  List<List> PatientsDetails = [];
  @override
  void initState() {
    super.initState();
    _future = getCurrentUserAndHospitalID();
    _future = DeleteTempId();
  }

  Future getCurrentUserAndHospitalID() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
      final message =
          await _firestore.collection("Authentication").getDocuments();
      for (var messages in message.documents) {
        print(messages.id);
        if (messages.data()["email"] == loggedInUser.email) {
          hospitalid = messages.data()["hospital_id"];
          break;
        }
      }
      print("hospital_id = ${hospitalid}");
    } catch (e) {
      print(e);
      print(";_;");
    }
  }

  Future DeleteTempId() async {
    try {
      final message =
          await _firestore.collection("Temporary_info").getDocuments();
      for (var messages in message.documents) {
        if (messages.data()["email"] == loggedInUser.email) {
          _firestore
              .collection("Temporary_info")
              .document(messages.id)
              .delete();
        }
      }
    } catch (e) {
      print(e);
      print(";_;");
    }
  }

  void ConfirmLogOut1(BuildContext context) async{
    var alertDialog = AlertDialog(
      title: Text("Log Out?"),
      content: Text("Do you want to log out?"),
      actions: [
        FlatButton(
            child: Text("No"),
            onPressed: (){
              Navigator.pushNamed(context, patient_list.id) ;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Patient List'),
          backgroundColor: Colors.greenAccent,
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.exit_to_app),
                tooltip: 'log out',
                onPressed: () {
                   ConfirmLogOut1(context);
                },
              ),
          ],
          automaticallyImplyLeading: false,
        ),
        body: FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return loadingWidget;
              }
              return StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection("Patient_info").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final messages1 = snapshot.data.documents;
                    PatientsDetails = [];
                    no_of_patients = 0;
                    for (var message in messages1) {
                      print("hi there , ${hospitalid}");
                      if (message.data()["information"][2] == hospitalid) {
                        print("hi there");
                        final PatientName = message.data()["information"][0];
                        final PatientAge = message.data()["information"][4];
                        PatientsDetails.add([PatientName, PatientAge]);
                        no_of_patients++;
                      }
                    }
                  } else
                    return (Text("The patient list in empty"));
                  if(no_of_patients == 0) return Center(
                      child: (Text(
                          "The patient list is empty !",
                          style: TextStyle(
                            fontSize: 15.0,
                          ),
                      )
                      )
                  );
                  return Container(
                    child: ListView.builder(
                      itemCount: PatientsDetails.length,
                      itemBuilder: (context, index) => Container(
                        child: Card(
                          margin: EdgeInsets.all(10),
                          child: InkWell(
                            splashColor: Colors.blue.withAlpha(30),
                            onTap: () async{
                              await _firestore.collection("Temporary_info").add({
                                "age": PatientsDetails[index][1],
                                "name": PatientsDetails[index][0],
                                "email": loggedInUser.email,
                              });
                              Navigator.pushNamed(
                                  context, single_patient_info_doc.id);
                            },
                            child: Container(
                              padding: EdgeInsets.fromLTRB(20, 35, 20, 35),
                              child : Row(
                                children:[
                                Text(
                                    "${PatientsDetails[index][0]} , ",
                                    style : TextStyle(
                                    fontSize: 25.0,
                                    ),
                                ),
                                  Text(
                                      "${PatientsDetails[index][1]}",
                                      style : TextStyle(
                                        fontSize: 20.0,
                                      ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
        ),
    );
  }

  Widget loadingWidget = Center(
    child: CircularProgressIndicator(),
  );
}
