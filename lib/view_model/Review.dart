import 'package:cloud_firestore/cloud_firestore.dart';

import 'PlacesHandler.dart';

class Review {
  final String userName;
  final String userId;
  final Map<String, double> aspectRatings;
  final String comment;
  final DateTime timestamp;

  Review({
    required this.userName,
    required this.userId,
    required this.aspectRatings,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'userId': userId,
      'aspectRatings': aspectRatings,
      'comment': comment,
      'timestamp': timestamp,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userName: map['userName'],
      userId: map['userId'],
      aspectRatings: Map<String, double>.from(map['aspectRatings']),
      comment: map['comment'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
Map<PlaceType, List<String>> placeTypeAspects = {
  PlaceType.Hospitals: ['Cleanliness', 'Service', 'Facilities'],
  PlaceType.Parks: ['Cleanliness', 'Facilities', 'Accessibility'],
  PlaceType.Restaurants: ['Food Quality', 'Ambiance', 'Service'],
  PlaceType.Monuments: ['Maintenance', 'Accessibility', 'History'],
  PlaceType.MountainHills: ['Scenery', 'Trails', 'Facilities'],
  PlaceType.Hotels: ['Cleanliness', 'Comfort', 'Service'],
  PlaceType.TopDestination: ['Attractions', 'Accessibility', 'Facilities'],
};