import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../model/GetWeather.dart';
import '../model/Places_Model.dart';
import '../view_model/PlacesHandler.dart';
import 'Details_Page.dart';

class FavoritePlacesDisplay extends StatefulWidget {
  final String userId;

  FavoritePlacesDisplay({required this.userId});

  @override
  _FavoritePlacesDisplayState createState() => _FavoritePlacesDisplayState();
}

class _FavoritePlacesDisplayState extends State<FavoritePlacesDisplay> {
  Future<List<Map<String, dynamic>>>? favoritePlaces;

  List<String> tempList =[];

  @override
  void initState() {
    super.initState();
    favoritePlaces = PlaceHandler.fetchFavorites(widget.userId,"Users");
  }

  Future<double> fetchWeather(double lat, double lon) async {
    final apiKey = '863c218c255a385a183d937f63dd515f';
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final weatherResponse = WeatherResponse.fromJson(json.decode(response.body));
      return weatherResponse.temp - 273.15; // Convert Kelvin to Celsius
    }
    else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
            setState(() {
            });
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Favorite Places', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.search, color: Colors.white),
        //     onPressed: () {
        //       // Handle search functionality here
        //     },
        //   ),
        // ],
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
      body: FutureBuilder(
        future: favoritePlaces,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('No data Found'));
          } else {
            List<Map<String, dynamic>>? placesList = snapshot.data as List<Map<String, dynamic>>?;
            if (placesList != null && placesList.isNotEmpty) {
              return ListView.builder(
                itemCount: placesList.length,
                itemBuilder: (context, index) {
                  PlacesModel place = placesList[index]['place'];
                  PlaceType placeType = placesList[index]['placeType'];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return DetailsPage(place: place, placeType: placeType,temp: tempList[index],);
                      }));
                    },
                    child: _buildAnimatedPlaceCard(context, place, index, placesList.length),
                  );
                },
              );
            } else {
              return Center(child: Text('No favorite places found.'));
            }
          }
        },
      ),
    );
  }

  Widget _buildAnimatedPlaceCard(BuildContext context, PlacesModel place, int index, int totalPlaces) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Interval(
            0.5 * index / totalPlaces,
            1.0,
            curve: Curves.easeInOut,
          ),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, 0.5),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Interval(
              0.5 * index / totalPlaces,
              1.0,
              curve: Curves.easeInOut,
            ),
          ),
        ),
        child: _buildPlaceCard(context, place),
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, PlacesModel place) {
    double boxHeight = 150;
    double childHeight = 100;
    double childWidth = 100;
    double bigTextSize = 20;
    double smallTextSize = 14;
    final latLon = place.latLon.split(',');
    final double latitude = double.parse(latLon[0].trim());
    final double longitude = double.parse(latLon[1].trim());

    Future<double> temperatureCelsius = fetchWeather(latitude, longitude);

    return FutureBuilder(
      future: temperatureCelsius,
      builder: (_, AsyncSnapshot<double> snapshot) {
        if (!snapshot.hasData) {
          return Shimmer.fromColors(
              baseColor: Colors.grey.shade700,
              highlightColor: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ListTile(
                    leading: Container(
                      color: Colors.white,
                      width:
                      MediaQuery.of(context).size.height * 0.08,
                      height:
                      MediaQuery.of(context).size.height * 0.08,
                    ),
                    title: Container(
                      color: Colors.white,
                      width:
                      MediaQuery.of(context).size.height * 0.01,
                      height:
                      MediaQuery.of(context).size.height * 0.01,
                    ),
                    subtitle: Container(
                      color: Colors.white,
                      width:
                      MediaQuery.of(context).size.height * 0.01,
                      height:
                      MediaQuery.of(context).size.height * 0.01,
                    ),
                  ),
                ],
              ));
        }
        else {
          tempList.add(snapshot.data!.toStringAsFixed(2)+ ' °C');
          return Container(
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      place.imageUrl,
                      height: childHeight,
                      width: childWidth,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          place.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: bigTextSize,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              "${place.rating.toStringAsFixed(1)}/5",
                              style: TextStyle(fontSize: smallTextSize, color: Colors.black54),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Reviews: ${place.reviewCount}",
                          style: TextStyle(fontSize: smallTextSize, color: Colors.black54),
                        ),
                        Text(
                          'Temp: ${snapshot.data!.toStringAsFixed(2)} °C',
                          style: TextStyle(fontSize: smallTextSize, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
