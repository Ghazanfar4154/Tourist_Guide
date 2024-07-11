import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tourist_guide/view_model/PlacesHandler.dart';
import 'package:tourist_guide/views/Details_Page.dart';
import 'package:tourist_guide/views/Home_Page.dart';
import 'package:tourist_guide/views/List_Page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tourist_guide/views/Login_screens/login_screen.dart';
import 'package:tourist_guide/views/Login_screens/signup.dart';
import 'package:tourist_guide/views/SplashScreen.dart';
import 'firebase_options.dart';
import 'model/Places_Model.dart';


void main() async{
  await WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());

  // for (PlaceType type in PlaceType.values) {
  //   print('Fetching data for ${type.toString().split('.').last}...');
  //   List<PlacesModel> places = await PlaceHandler.fetchPlaces(type);
  //   //printData(places);
  //   print('\n');
  // }

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}


// void printData(List<PlacesModel> places) {
//   places.forEach((place) {
//     print('ID: ${place.id}');
//     print('Name: ${place.name}');
//     print('Description: ${place.description}');
//     print('Image URL: ${place.imageUrl}');
//     print('Reviews: ${place.reviewCount}');
//     print('LatLon: ${place.latLon}');
//     print('Rating: ${place.rating}');
//     print('');
//   });
// }
