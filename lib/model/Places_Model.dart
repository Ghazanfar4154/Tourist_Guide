class PlacesModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String latLon;
  final double rating;
  final int reviewCount;

  PlacesModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.latLon,
    required this.rating,
    required this.reviewCount,
  });
}
