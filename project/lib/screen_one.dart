import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:weather_animation/weather_animation.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  // declaring these as globals
  String apiKey = 'b0f8cc0c19ce85fd145946f87ccd3837';
  String cityName = '';
  String weatherData = '';
  String weatherDescription = '';
  String temperature = '';
  String formattedDate = '';
  String dayOfWeek = '';
  double latitude = 0.0;
  double longitude = 0.0;
  static bool weatherDataLoaded = false; // for not making multiple API requests
  static String cachedWeatherData = '';
  static String cachedWeatherDescription = '';

  Widget getWeatherAnimationForCurrentWeather(String weatherDescription) {
    WeatherScene weatherScene;

    if (cachedWeatherDescription.contains('clear')) {
      weatherScene = WeatherScene.scorchingSun;
    } else if (cachedWeatherDescription.contains('cloud') ||
        cachedWeatherDescription.contains('overcast')) {
      weatherScene = WeatherScene.rainyOvercast;
    } else if (cachedWeatherDescription.contains('rain') ||
        cachedWeatherDescription.contains('drizzle')) {
      weatherScene = WeatherScene.rainyOvercast;
    } else if (cachedWeatherDescription.contains('snow')) {
      weatherScene = WeatherScene.snowfall;
    } else if (cachedWeatherDescription.contains('thunder')) {
      weatherScene = WeatherScene.stormy;
    } else {
      weatherScene = WeatherScene.weatherEvery; // Default scene
    }
    return weatherScene.getWeather();
  }

  @override
  void initState() {
    super.initState();
    if (!weatherDataLoaded) {
      fetchCurrentLocation();
      weatherDataLoaded = true;
    }
  }

  Future<void> fetchCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    final double latitude = locationData.latitude!;
    final double longitude = locationData.longitude!;
    await fetchWeatherData(latitude, longitude);
  }

  Future<void> fetchWeatherData(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final weatherJson = json.decode(response.body);
        cityName = weatherJson['name'].toString();
        weatherDescription =
            weatherJson['weather'][0]['description'].toString();
        temperature = (weatherJson['main']['temp'] - 273.15).toStringAsFixed(1);
        formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
        dayOfWeek = DateFormat('EEEE').format(DateTime.now());
        setState(() {
          weatherData =
              '$cityName\n\n$dayOfWeek, $formattedDate\n\n$weatherDescription\n\n$temperature°C';
        });
        cachedWeatherData = weatherData;
        cachedWeatherDescription = weatherDescription;
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Visibility(
            visible: cachedWeatherData.isNotEmpty,
            child: getWeatherAnimationForCurrentWeather(
                cachedWeatherDescription), // Call the method to choose the appropriate widget
          ),
          Center(
            child: cachedWeatherData.isEmpty
                ? const CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  )
                : RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: '$cachedWeatherData\n\n',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
