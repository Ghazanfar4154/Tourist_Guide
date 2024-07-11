import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:tourist_guide/view_model/Auth_User.dart';
import 'package:tourist_guide/views/Favorites_Places.dart';
import 'package:tourist_guide/views/Login_screens/Change_Password.dart';
import '../model/Places_Model.dart';
import '../text_converter/ocr/Screen/recognization_page.dart';
import '../text_converter/ocr/Utils/image_cropper_page.dart';
import '../text_converter/ocr/Utils/image_picker_class.dart';
import '../text_converter/ocr/Widgets/modal_dialog.dart';
import '../view_model/PlacesHandler.dart';
import 'Details_Page.dart';
import 'List_Page.dart';
import 'Login_screens/login_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final String userName = AuthUser.userName!;
  final String userGmail = AuthUser.userGmail!;

  final String profileImageUrl = "https://via.placeholder.com/150"; // Replace with actual image URL

  late AnimationController _controller;
  List<Map<String, dynamic>> topDestinations =[];

  final List<Color> categoryColors = [
    Colors.blue.shade400,
    Colors.green.shade400,
    Colors.orange.shade400,
    Colors.purple.shade400,
    Colors.red.shade400,
    Colors.teal.shade400,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _fetchTopDestinations();
  }

  void _logout(BuildContext context) async {
    try {// Sign out the current user
      AuthUser.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
      );
      print("signed out successfully");
    } catch (e) {
      // Display an error if sign-out fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign out: $e'),
        ),
      );
      print("Not signed out");
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchTopDestinations() async {
    topDestinations = await PlaceHandler.fetchFavorites("UN6ByAhuPUkgYyFfR1ef","Top Destinations");
    //topDestinations = await PlaceHandler.fetchPlaces(PlaceType.TopDestination);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 2,
        centerTitle: true,
        title: Text(
          'Welcome, $userName',
          style: GoogleFonts.lobster(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(userName),
              accountEmail: Text(userGmail),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(profileImageUrl),
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.blue.shade700),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.blue.shade700),
              title: Text('Change Password'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_){
                  return ChangePassword();
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: Colors.blue.shade700),
              title: Text('Favourites'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_){
                  return FavoritePlacesDisplay(userId: AuthUser.currentUser!.uid);
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.blue.shade700),
              title: Text('Log out'),
              onTap: () {
                _logout(context);
              },
            ),

          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Let's Travel Now",
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Transform.scale(
                  scale: 1.2, // Adjust this value to zoom the animation
                  child: Lottie.asset(
                    'assets/animations/lottie/home_page_animation.json', // Replace with your actual animation file
                    width: MediaQuery.of(context).size.width,
                    height: 200, // Increase height to make the animation more visible
                  ),
                ),
              ),
              SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: PlaceType.values.length - 1,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio: 3 / 2,
                ),
                itemBuilder: (context, index) {
                  final placeType = PlaceType.values[index];
                  final colorIndex = index % categoryColors.length;
                  final categoryColor = categoryColors[colorIndex];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceDisplay(placeType: placeType),
                        ),
                      );
                    },
                    child: Hero(
                      tag: PlaceHandler.getCollectionName(placeType),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + _controller.value * 0.03,
                            child: Opacity(
                              opacity: 0.6 + _controller.value * 0.4,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: categoryColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _getGifForPlaceType(placeType),
                                      SizedBox(height: 10),
                                      Text(
                                        PlaceHandler.getCollectionName(placeType),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                "Top Destinations",
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 220,
                child: topDestinations.isNotEmpty
                    ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: topDestinations.length,
                  itemBuilder: (context, index) {
                    PlacesModel place = topDestinations[index]['place'];
                    PlaceType placeType = topDestinations[index]['placeType'];
                    final destination = topDestinations[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsPage(place: place,placeType: placeType,temp: '',),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 160, // Adjust width to fit 2-3 items on screen
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  place.imageUrl,
                                  width: 160,
                                  height: 220,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                left: 10,
                                right: 10,
                                child: Container(
                                  color: Colors.black54,
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: Text(
                                  place.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
                    : Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     imagePickerModal(context, onCameraTap: () {
      //       log("Camera");
      //       pickImage(source: ImageSource.camera).then((value) {
      //         if (value != '') {
      //           imageCropperView(value, context).then((value) {
      //             if (value != '') {
      //               Navigator.push(
      //                 context,
      //                 CupertinoPageRoute(
      //                   builder: (_) => RecognizePage(
      //                     path: value,
      //                   ),
      //                 ),
      //               );
      //             }
      //           });
      //         }
      //       });
      //     }, onGalleryTap: () {
      //       log("Gallery");
      //       pickImage(source: ImageSource.gallery).then((value) {
      //         if (value != '') {
      //           imageCropperView(value, context).then((value) {
      //             if (value != '') {
      //               Navigator.push(
      //                 context,
      //                 CupertinoPageRoute(
      //                   builder: (_) => RecognizePage(
      //                     path: value,
      //                   ),
      //                 ),
      //               );
      //             }
      //           });
      //         }
      //       });
      //     });
      //   },
      //   tooltip: 'Increment',
      //   label: const Text("Scan photo"),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _getGifForPlaceType(PlaceType placeType) {
    String gifPath;
    switch (placeType) {
      case PlaceType.Hospitals:
        gifPath = 'assets/animations/gif_animations/hospitol.gif';
        break;
      case PlaceType.Parks:
        gifPath = 'assets/animations/gif_animations/park.gif';
        break;
      case PlaceType.Restaurants:
        gifPath = 'assets/animations/gif_animations/restaurant.gif';
        break;
      case PlaceType.MountainHills:
        gifPath = 'assets/animations/gif_animations/mountain_hill.gif';
        break;
      case PlaceType.Hotels:
        gifPath = 'assets/animations/gif_animations/hotel.gif';
        break;
      case PlaceType.Monuments:
        gifPath = 'assets/animations/gif_animations/monument.gif';
        break;

      default:
        gifPath = ''; // Provide default GIF or handle case accordingly
    }
    return Image.asset(
      gifPath,
      width: 100, // Adjust size as needed
      height: 55,
      fit: BoxFit.contain,
    );
  }
}

