import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'package:intl/intl.dart';

class Screen2 extends StatefulWidget {
  @override
  _Screen2State createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  String apiKey = 'b0f8cc0c19ce85fd145946f87ccd3837';
  String weatherData = '';

  @override
  void initState() {
    super.initState();
    fetchCurrentLocation();
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
          'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$apiKey');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final weatherJson = json.decode(response.body);
        final List forecastList = weatherJson['list'];

        setState(() {
          weatherData = '';
          for (int i = 0; i < forecastList.length; i++) {
            final forecast = forecastList[i];
            final date =
                DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
            final dayOfWeek = DateFormat('EEEE').format(date).substring(0, 3);
            final formattedDate = DateFormat('MMMM dd, yyyy').format(date);
            final time = DateFormat('HH:mm').format(date);
            final weatherDescription = forecast['weather'][0]['description'];
            final temperature =
                (forecast['main']['temp'] - 273.15).toStringAsFixed(1);

            weatherData +=
                '$dayOfWeek, $formattedDate-$time-$temperature°C-$weatherDescription\n\n';
          }
        });
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
      child: Center(
        child: weatherData.isEmpty
            ? const Text(
                'Fetching location...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              )
            : SingleChildScrollView(
                child: Text(
                  weatherData,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }
}
