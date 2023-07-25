class WeatherData {
  final String dateTime;
  final int weatherCode;
  final String weatherDescription;
  final int humidity;
  final double tempC;
  final double tempF;

  WeatherData({
    required this.dateTime,
    required this.weatherCode,
    required this.weatherDescription,
    required this.humidity,
    required this.tempC,
    required this.tempF,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      dateTime: json['jamCuaca'],
      weatherCode: int.parse(json['kodeCuaca']),
      weatherDescription: json['cuaca'],
      humidity: int.parse(json['humidity']),
      tempC: double.parse(json['tempC']),
      tempF: double.parse(json['tempF']),
    );
  }
}
