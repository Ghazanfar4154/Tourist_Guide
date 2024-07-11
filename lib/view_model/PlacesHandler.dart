import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourist_guide/view_model/Auth_User.dart';
import '../model/Places_Model.dart';

enum PlaceType {
  Hospitals,
  Parks,
  Restaurants,
  Monuments,
  MountainHills,
  Hotels,
  TopDestination
}

class PlaceHandler {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<PlacesModel>> fetchPlaces(PlaceType placeType) async {
    String collectionName = getCollectionName(placeType);
    List<PlacesModel> places = [];
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collectionName)
          .orderBy('rating', descending: true) // Order by rating descending
          .get();

      querySnapshot.docs.forEach((doc) {
        places.add(PlacesModel(
          id: doc.id,
          name: doc['name'] ?? '',
          description: doc['description'] ?? '',
          imageUrl: doc['imageUrl'] ?? '',
          latLon: doc['latlon'] ?? '',
          rating: (doc['rating'] ?? 0).toDouble(),
          reviewCount: (doc['reviewCount'] ?? 0).toInt(),
        ));
      });
    } catch (e) {
      print('Error fetching places from $collectionName: $e');
    }

    return places;
  }

  static String getCollectionName(PlaceType placeType) {
    switch (placeType) {
      case PlaceType.Hospitals:
        return 'Hospitals';
      case PlaceType.Parks:
        return 'Parks';
      case PlaceType.Restaurants:
        return 'Restaurants';
      case PlaceType.Monuments:
        return 'Monuments';
      case PlaceType.MountainHills:
        return 'Mountain Hills';
      case PlaceType.Hotels:
        return 'Hotels';
      case PlaceType.TopDestination:
        return 'Top Destinations';
    }
  }

  static Future<double?> addReview(
      String placeId,
      String collectionName,
      String userId,
      Map<String, double> aspectRatings,
      String comment) async {

    DocumentReference placeDocRef = _firestore.collection(collectionName).doc(placeId);
    CollectionReference reviewsCollectionRef = placeDocRef.collection('reviews');

    final userName = AuthUser.userName;

    try {
      // Check if the user has already reviewed this place
      QuerySnapshot existingReviewsSnapshot = await reviewsCollectionRef.where('userId', isEqualTo: userId).get();

      if (existingReviewsSnapshot.docs.isNotEmpty) {
        // User has already reviewed this place, update the existing review
        DocumentSnapshot existingReviewDoc = existingReviewsSnapshot.docs.first;
        String existingReviewId = existingReviewDoc.id;

        await reviewsCollectionRef.doc(existingReviewId).update({
          ...aspectRatings,
          'comment': comment,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        // Add a new review
        await reviewsCollectionRef.add({
          'userName': userName,
          'userId': userId,
          ...aspectRatings,
          'comment': comment,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Update the place document with the new review count and average rating
      return await updatePlaceRatings(placeDocRef, aspectRatings.keys.toList());
    } catch (e) {
      print('Error adding review: $e');
    }
  }


  static Future<double?> updateReview(
      String placeId,
      String collectionName,
      String reviewId,
      String userId,
      Map<String, double> aspectRatings,
      String comment) async {

    DocumentReference placeDocRef = _firestore.collection(collectionName).doc(placeId);
    DocumentReference reviewDocRef = placeDocRef.collection('reviews').doc(reviewId);

    try {
      // Update the review
      await reviewDocRef.update({
        ...aspectRatings,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update the place document with the new review count and average rating
      return await updatePlaceRatings(placeDocRef, aspectRatings.keys.toList());
    } catch (e) {
      print('Error updating review: $e');
    }
  }



  static Future<double?> updatePlaceRatings(DocumentReference placeDocRef, List<String> aspects) async {
    CollectionReference reviewsCollectionRef = placeDocRef.collection('reviews');

    try {
      QuerySnapshot snapshot = await reviewsCollectionRef.get();
      int reviewCount = snapshot.size;
      Map<String, double> totalRatings = { for (var aspect in aspects) aspect: 0.0 };

      snapshot.docs.forEach((doc) {
        for (var aspect in aspects) {
          totalRatings[aspect] = totalRatings[aspect]! + doc[aspect];
        }
      });

      Map<String, double> averageRatings = {
        for (var aspect in aspects)
          aspect: reviewCount > 0 ? totalRatings[aspect]! / reviewCount : 0
      };

      double totalRating = 0.0;
      if (reviewCount > 0) {
        totalRating = averageRatings.values.reduce((a, b) => a + b) / aspects.length;
      }

      await placeDocRef.update({
        'reviewCount': reviewCount,
        ...averageRatings,
        'rating': totalRating,
      });
      return totalRating;
    } catch (e) {
      print('Error updating place ratings: $e');
    }
  }


  static Future<List<Map<String, dynamic>>> fetchReviews(
      String placeId, String collectionName) async {
    DocumentReference placeDocRef = _firestore.collection(collectionName).doc(placeId);
    CollectionReference reviewsCollectionRef = placeDocRef.collection('reviews');

    QuerySnapshot snapshot = await reviewsCollectionRef.orderBy('timestamp', descending: true).get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  static Future<String?> fetchUserReview(
      String placeId, String collectionName, String userId) async {
    DocumentReference placeDocRef = _firestore.collection(collectionName).doc(placeId);
    CollectionReference reviewsCollectionRef = placeDocRef.collection('reviews');

    QuerySnapshot snapshot = await reviewsCollectionRef.where('userId', isEqualTo: userId).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
      //return snapshot.docs.first.data() as Map<String, dynamic>;
    }
    return null;
  }

  static addNewUser({required String userName,required String gmail,required String uuid}) async{

    try{
      await _firestore.collection("Users").doc(uuid).set({
        'userName': userName,
        'g-mail': gmail,
        'uuid': uuid
      });
    }catch(e){
      print("Data Not Added");
    }
  }


  // static Future<void> addFavorite(String userId, String placeId, String collectionName) async {
  //   DocumentReference userDocRef = _firestore.collection('Users').doc(userId);
  //   print(userDocRef.id);
  //   try {
  //     await userDocRef.update({
  //       'favorites': FieldValue.arrayUnion([{'placeId': placeId, 'collectionName': collectionName}])
  //     });
  //   } catch (e) {
  //     print('Error adding favorite: $e');
  //   }
  // }

  static Future<void> handleAddingFavorite(String userId, String placeId, String collectionName) async {
    DocumentReference userDocRef = _firestore.collection('Users').doc(userId);
    try {
      bool isFavorite = await isFavoritePlace(userId, placeId, collectionName);
      if (isFavorite) {
        // Remove from favorites
        await userDocRef.update({
          'favorites': FieldValue.arrayRemove([{'placeId': placeId, 'collectionName': collectionName}])
        });
      } else {
        // Add to favorites
        await userDocRef.update({
          'favorites': FieldValue.arrayUnion([{'placeId': placeId, 'collectionName': collectionName}])
        });
      }
    } catch (e) {
      print('Error handling favorite: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchFavorites(String userId, String collectionId) async {
    DocumentSnapshot userDoc = await _firestore.collection(collectionId).doc(userId).get();
    List<Map<String, dynamic>> favoritePlaces = [];

    if (userDoc.exists && userDoc.data() != null) {
      List<dynamic> favorites = userDoc['favorites'] ?? [];

      for (var favorite in favorites) {
        String placeId = favorite['placeId'];
        String collectionName = favorite['collectionName'];
        DocumentSnapshot placeDoc = await _firestore.collection(collectionName).doc(placeId).get();

        if (placeDoc.exists && placeDoc.data() != null) {
          favoritePlaces.add({
            'place': PlacesModel(
              id: placeDoc.id,
              name: placeDoc['name'] ?? '',
              description: placeDoc['description'] ?? '',
              imageUrl: placeDoc['imageUrl'] ?? '',
              latLon: placeDoc['latlon'] ?? '',
              rating: (placeDoc['rating'] ?? 0).toDouble(),
              reviewCount: (placeDoc['reviewCount'] ?? 0).toInt(),
            ),
            'placeType': _getPlaceTypeFromCollectionName(collectionName),
          });
        }
      }
    }

    return favoritePlaces;
  }

  static PlaceType _getPlaceTypeFromCollectionName(String collectionName) {
    switch (collectionName) {
      case 'Hospitals':
        return PlaceType.Hospitals;
      case 'Parks':
        return PlaceType.Parks ;
      case 'Restaurants':
        return PlaceType.Restaurants;
      case 'Monuments':
        return PlaceType.Monuments;
      case 'Mountain Hills':
        return PlaceType.MountainHills;
      case 'Hotels':
        return PlaceType.Hotels;
      case 'Top Destinations':
        return PlaceType.TopDestination;
      default:
        return PlaceType.TopDestination;// Or handle it as needed
    }
  }

  static Future<bool> isFavoritePlace(String userId, String placeId, String collectionName) async {
    final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
    final userDoc = await userDocRef.get();
    if (userDoc.exists) {
      final favorites = userDoc.data()?['favorites'] as List<dynamic>?;
      if (favorites != null) {
        print(placeId);
        return favorites.any((fav) => fav['placeId'] == placeId && fav['collectionName'] == collectionName);
      }
    }
    return false;
  }

// static Future<List<PlacesModel>> fetchFavorites(String userId) async {
//   DocumentSnapshot userDoc = await _firestore.collection('Users').doc(userId).get();
//   List<PlacesModel> favoritePlaces = [];
//
//   if (userDoc.exists && userDoc.data() != null) {
//     List<dynamic> favorites = userDoc['favorites'] ?? [];
//
//     for (var favorite in favorites) {
//       String placeId = favorite['placeId'];
//       String collectionName = favorite['collectionName'];
//       DocumentSnapshot placeDoc = await _firestore.collection(collectionName).doc(placeId).get();
//
//       if (placeDoc.exists && placeDoc.data() != null) {
//         favoritePlaces.add(PlacesModel(
//           id: placeDoc.id,
//           name: placeDoc['name'] ?? '',
//           description: placeDoc['description'] ?? '',
//           imageUrl: placeDoc['imageUrl'] ?? '',
//           latLon: placeDoc['latlon'] ?? '',
//           rating: (placeDoc['rating'] ?? 0).toDouble(),
//           reviewCount: (placeDoc['reviewCount'] ?? 0).toInt(),
//         ));
//       }
//     }
//   }
//
//   return favoritePlaces;
// }

}
