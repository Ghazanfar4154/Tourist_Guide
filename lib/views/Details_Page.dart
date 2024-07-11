import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tourist_guide/google_map/CurrentLocation.dart';
import 'package:tourist_guide/google_map/NavigationScreen.dart';
import 'package:tourist_guide/google_map/StaticMap.dart';
import 'package:tourist_guide/panorama/Panorama_Viewer.dart';
import 'package:tourist_guide/view_model/Auth_User.dart';
import 'package:tourist_guide/views/List_Page.dart';
import '../model/Places_Model.dart';
import '../view_model/PlacesHandler.dart';
import '../view_model/Review.dart'; // Import PlaceHandler

class DetailsPage extends StatefulWidget {
  final PlacesModel place;
  final PlaceType placeType;
  String temp ;

  DetailsPage({Key? key, required this.place, required this.placeType,required this.temp}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {

  late Future<List<Map<String, dynamic>>> _reviewsFuture;

  double? placeRating ;


  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  bool _isFavourite =false;

  void toggleFavourite(){
    if(_isFavourite == true){
      _isFavourite = false;
    }else{
      _isFavourite = true;
    }
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    placeRating = widget.place.rating;
    PlaceHandler.isFavoritePlace(
        AuthUser.userUid!,
        widget.place.id,
        PlaceHandler.getCollectionName(widget.placeType)).then((value){
      _isFavourite = value;
      print(_isFavourite);
      setState(() {

      });
    });
    _reviewsFuture = PlaceHandler.fetchReviews(widget.place.id, PlaceHandler.getCollectionName(widget.placeType));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_){
              return PlaceDisplay(placeType: widget.placeType);
            }));
            setState(() {
            });
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(
          widget.place.name.toString().split(" ").first+" "+ widget.place.name.toString().split(" ").elementAt(1)
          ,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () async{
              await PlaceHandler.handleAddingFavorite(
                  AuthUser.currentUser!.uid,
                  widget.place.id,
                  PlaceHandler.getCollectionName(widget.placeType)
              );// Handle favorite action
              toggleFavourite();
            },
            icon: _isFavourite!= false ? Icon(Icons.favorite,color: Colors.red,): Icon(Icons.favorite_border),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: Stack(
          children: [
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_){
                  return PanoramaScreen(imageUrl: widget.place.imageUrl);
                }));
              },
              child: Expanded(
                child: Hero(
                  tag: widget.place.id,
                  child: Image.network(
                      widget.place.imageUrl,
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover),
                ),

              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.place.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(3.0, 3.0),
                            ),
                          ],
                        ),
                      ),
                      Text(
                          widget.temp,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(3.0, 3.0),
                              ),
                            ],
                          )
                      )
                      // IconButton(
                      //   onPressed: () {
                      //     // Handle star action
                      //   },
                      //   icon: Icon(Icons.star, color: Colors.white),
                      // ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 15),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text("Rating", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(height: 5),
                                Icon(Icons.star, color: Colors.amber),
                                SizedBox(height: 5),
                                if(placeRating!=null)
                                  double.parse(placeRating!.toStringAsFixed(1))>0
                                      ?Text("${placeRating!.toStringAsFixed(1)}/5")
                                      : Text("5/5")
                              ],
                            ),
                            Column(
                              children: [
                                Text("Reviews", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(height: 5),
                                Icon(Icons.reviews),
                                SizedBox(height: 5),
                                Text("${widget.place.reviewCount}"),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      TabBar(
                        indicatorColor: Colors.blueAccent,
                        labelColor: Colors.black,
                        tabs: [
                          Tab(text: 'Introduction'),
                          Tab(text: 'Reviews'),
                          Tab(text: 'Location'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Text(
                                  widget.place.description,
                                  style: TextStyle(fontSize: 16, height: 1.5),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: FutureBuilder<List<Map<String, dynamic>>>(
                                    future: _reviewsFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Center(child: Text('Error loading reviews'));
                                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                        return Center(child: Text('No reviews yet', style: TextStyle(fontSize: 16.0, color: Colors.grey)));
                                      } else {
                                        return ListView.builder(
                                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                          itemCount: snapshot.data!.length,
                                          itemBuilder: (context, index) {
                                            var review = snapshot.data![index];
                                            List<String> aspects = placeTypeAspects[widget.placeType] ?? [];
                                            double totalRating = aspects.map((aspect) => review[aspect] as double).reduce((a, b) => a + b) / aspects.length;
                                            bool showDetails = false; // State variable to track if details are shown

                                            return StatefulBuilder(
                                              builder: (BuildContext context, StateSetter setState) {
                                                return Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12.0),
                                                  ),
                                                  elevation: 4.0,
                                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(16.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        if (!showDetails)
                                                          Row(
                                                            children: [
                                                              Text('Rating: ${totalRating.toStringAsFixed(1)}/5', style: TextStyle(fontWeight: FontWeight.bold)),
                                                              SizedBox(width: 8.0),
                                                              ...List.generate(
                                                                totalRating.floor(),
                                                                    (index) => Icon(Icons.star, color: Colors.amber, size: 16.0),
                                                              ),
                                                              if (totalRating % 1 != 0)
                                                                Icon(Icons.star_half, color: Colors.amber, size: 16.0),
                                                            ],
                                                          ),
                                                        if (showDetails)
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              for (var aspect in aspects)
                                                                Row(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Expanded(child: Text('$aspect:', style: TextStyle(fontWeight: FontWeight.w500))),
                                                                    ...List.generate(
                                                                      5,
                                                                          (index) {
                                                                        if (index < review[aspect]) {
                                                                          if (review[aspect] % 1 != 0 && index == review[aspect].floor()) {
                                                                            return Icon(Icons.star_half, color: Colors.amber, size: 16.0);
                                                                          } else {
                                                                            return Icon(Icons.star, color: Colors.amber, size: 16.0);
                                                                          }
                                                                        } else {
                                                                          return Icon(Icons.star_border, color: Colors.grey, size: 16.0);
                                                                        }
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                            ],
                                                          ),
                                                        SizedBox(height: 8.0),
                                                        Text('Comment: ${review['comment']}', style: TextStyle(fontSize: 14.0)),
                                                        Text('By: ${review['userName']}', style: TextStyle(fontSize: 12.0, color: Colors.grey)),
                                                        Align(
                                                          alignment: Alignment.centerRight,
                                                          child: TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                showDetails = !showDetails;
                                                              });
                                                            },
                                                            child: Text(showDetails ? 'Show Less' : 'Show Details'),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _showAddReviewDialog(context, widget.placeType);
                                  },
                                  child: Text('Add Review'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                    textStyle: TextStyle(fontSize: 16.0),
                                  ),
                                ),
                              ],
                            ),

                            Stack(
                              children: [
                                Container(
                                  child: StaticMapWithMarker(
                                      latlng: LatLng(
                                          double.parse(widget.place.latLon.split(",").first)
                                          , double.parse(widget.place.latLon.split(",").last)
                                      )),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final latLon = widget.place.latLon.split(',');
                                      final double latitude = double.parse(latLon[0].trim());
                                      final double longitude = double.parse(latLon[1].trim());

                                      final latlng = LatLng(latitude, longitude);
                                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                                        return NavigationScreen(latitude, longitude);
                                      }));
                                      // Handle view on map action
                                    },
                                    child: Text("View on Map"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                                      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Align(
            //   alignment: Alignment.topRight,
            //   child: IconButton(
            //     onPressed: () {
            //       // Handle share action
            //     },
            //     icon: Icon(Icons.share, color: Colors.black),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context, PlaceType placeType) {
    List<String> aspects = placeTypeAspects[placeType] ?? [];
    Map<String, double> aspectRatings = { for (var aspect in aspects) aspect: 0.0 };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          title: Text("Add Review"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var aspect in aspects)
                Column(
                  children: [
                    Text(aspect),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        aspectRatings[aspect] = rating;
                      },
                    ),
                  ],
                ),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(labelText: 'Comment'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String comment = _commentController.text;

                if (aspectRatings.values.any((rating) => rating < 1 || rating > 5)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ratings must be between 1 and 5')),
                  );
                }
                else {
                  // Check if review already exists
                  var existingReview = await PlaceHandler.fetchUserReview(
                    widget.place.id,
                    PlaceHandler.getCollectionName(placeType),
                    AuthUser.userUid!,
                  );

                  if (existingReview != null) {
                    // Update existing review
                    placeRating = await PlaceHandler.updateReview(
                      widget.place.id,
                      PlaceHandler.getCollectionName(placeType),
                      existingReview,
                      AuthUser.userUid!,
                      aspectRatings,
                      comment,
                    );
                  } else {
                    // Add new review
                    placeRating = await PlaceHandler.addReview(
                      widget.place.id,
                      PlaceHandler.getCollectionName(placeType),
                      AuthUser.userUid!,
                      aspectRatings,
                      comment,
                    );
                  }

                  setState(() {
                    _reviewsFuture = PlaceHandler.fetchReviews(
                      widget.place.id,
                      PlaceHandler.getCollectionName(placeType),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Add Review'),
            ),
          ],
        );
      },
    );
  }


}

