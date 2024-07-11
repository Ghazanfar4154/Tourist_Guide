class WeatherResponse {
  final double temp;

  WeatherResponse({required this.temp});

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      temp: json['main']['temp'],
    );
  }
}
