import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:intl/intl.dart';

class Screen1 extends StatefulWidget {
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
  static bool weatherDataLoaded = false;
  static String cachedWeatherData = '';

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
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print(e);
    }
  }

  // create a getter for the cityName variable
  String get getCityName => cityName;
  // create a setter for the cityName variable
  set setCityName(String cityName) => this.cityName = cityName;

  set setLatitude(double latitude) => this.latitude = latitude;
  set setLongitude(double longitude) => this.longitude = longitude;
  double get getLatitude => latitude;
  double get getLongitude => longitude;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: cachedWeatherData.isEmpty
            ? const Text(
                'Fetching location...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
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
    );
  }
}
