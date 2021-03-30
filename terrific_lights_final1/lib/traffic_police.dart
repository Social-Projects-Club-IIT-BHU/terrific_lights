import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:terrific_lights_final1/login_screen.dart';
import 'dart:math';

class traffic_police extends StatefulWidget {
  @override
  static const String id = 'traffic_police';
  _traffic_policeState createState() => _traffic_policeState();
}

class _traffic_policeState extends State<traffic_police> {
  @override

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User loggedInUser;
  Future _future;

  var no_of_coordinates = 0;
  var plat = 0.0, plong = 0.0;
  CameraPosition _initialPosition;
  final Set<Marker> _markers = Set();
  Completer<GoogleMapController> _controller = Completer();


  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Future getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
      print(";_;");
    }
  }

  void initState() {
    super.initState();
    _future = getCurrentUser();
    _future = getPoliceLocation();

  }

  Future getPoliceLocation() async {
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    plat = position.latitude;
    plong = position.longitude;
  }

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

  double getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2-lat1);  // deg2rad below
    var dLon = deg2rad(lon2-lon1);
    var a =
        sin(dLat/2) * sin(dLat/2) +
            cos(deg2rad(lat1)) * cos(deg2rad(lat2)) *
                sin(dLon/2) * sin(dLon/2)
    ;
    var c = 2 * atan2(sqrt(a), sqrt(1-a));
    var d = R * c; // Distance in km
    return d;
  }

  double deg2rad(deg) {
    return deg * (pi/180);
  }

  Widget loadingWidget = Center(
    child: CircularProgressIndicator(),
  );

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Ambulances near you"),
        backgroundColor: Colors.red,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'log out',
            onPressed: () {
              ConfirmLogOut(context);
            },
          ),
        ],
      ),
        body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingWidget;
          }
          return StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection("ambulance_location").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final messages1 = snapshot.data.documents;
                _markers.clear();
                no_of_coordinates = 0;
                _initialPosition = CameraPosition(target: LatLng(plat, plong), zoom : 15.5);
                for (var message in messages1) {

                  double distanceInKMeters = getDistanceFromLatLonInKm(plat, plong, double.parse(message.data()['latitude']), double.parse(message.data()['longitude']));
                  if(distanceInKMeters <= 0.5) {
                    _markers.add(
                      Marker(
                          //markerId: MarkerId('dubai'), double.parse(message.data()['longitude'])
                          position: LatLng(double.parse(message.data()['latitude']), double.parse(message.data()['longitude'])),
                          infoWindow: InfoWindow(title: 'Ambulance',  snippet: message.data()['address']),
                          markerId: MarkerId("Ambulance"),
                      ),
                    );
                    print(message.data()['latitude'] + " " + message.data()['longitude']);
                  }
                  print(distanceInKMeters.toString()+ " " + message.data()['latitude']+ " " + message.data()['longitude']);
                }
              }
                else return (Text("No ambulances around you!"));
                return Container(
                child: GoogleMap(
                  markers: _markers,
                  mapType: MapType.hybrid,
                  myLocationEnabled: true,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: _initialPosition,
                ),
              );
            },
          );
        }
        ),
    );
  }
}



// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Maps',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(title: 'Flutter Map Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);
//   final String title;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   StreamSubscription _locationSubscription;
//   Location _locationTracker = Location();
//   Marker marker;
//   Circle circle;
//   GoogleMapController _controller;
//
//   static final CameraPosition initialLocation = CameraPosition(
//     target: LatLng(22.809182571928325, 86.16514326844722),
//     zoom: 14.4746,
//   );
//
//   Future<Uint8List> getMarker() async {
//     ByteData byteData = await DefaultAssetBundle.of(context).load("Assets/login_img.jpg");
//     return byteData.buffer.asUint8List();
//   }
//
//   void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
//     LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
//     this.setState(() {
//       marker = Marker(
//           markerId: MarkerId("home"),
//           position: latlng,
//           rotation: newLocalData.heading,
//           draggable: false,
//           zIndex: 2,
//           flat: true,
//           anchor: Offset(0.5, 0.5),
//           icon: BitmapDescriptor.fromBytes(imageData));
//       circle = Circle(
//           circleId: CircleId("car"),
//           radius: newLocalData.accuracy,
//           zIndex: 1,
//           strokeColor: Colors.blue,
//           center: latlng,
//           fillColor: Colors.blue.withAlpha(70));
//     });
//   }
//
//   void getCurrentLocation() async {
//     try {
//
//       Uint8List imageData = await getMarker();
//       var location = await _locationTracker.getLocation();
//
//       updateMarkerAndCircle(location, imageData);
//
//       if (_locationSubscription != null) {
//         _locationSubscription.cancel();
//       }
//
//
//       _locationSubscription = _locationTracker.onLocationChanged.listen((newLocalData) {
//         if (_controller != null) {
//           _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
//               bearing: 192.8334901395799,
//               target: LatLng(newLocalData.latitude, newLocalData.longitude),
//               tilt: 0,
//               zoom: 18.00)));
//           updateMarkerAndCircle(newLocalData, imageData);
//         }
//       });
//
//     } on PlatformException catch (e) {
//       if (e.code == 'PERMISSION_DENIED') {
//         debugPrint("Permission Denied");
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     if (_locationSubscription != null) {
//       _locationSubscription.cancel();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: GoogleMap(
//         mapType: MapType.hybrid,
//         initialCameraPosition: initialLocation,
//         markers: Set.of((marker != null) ? [marker] : []),
//         circles: Set.of((circle != null) ? [circle] : []),
//         onMapCreated: (GoogleMapController controller) {
//           _controller = controller;
//         },
//
//       ),
//       floatingActionButton: FloatingActionButton(
//           child: Icon(Icons.location_searching),
//           onPressed: () {
//             getCurrentLocation();
//           }),
//     );
//   }
// }
//
//
