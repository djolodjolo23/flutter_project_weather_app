import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

class Screen2 extends StatefulWidget {
  @override
  _Screen2State createState() => _Screen2State();
}

class WeatherInfo {
  final IconData iconData;
  final String weatherText;

  WeatherInfo(this.iconData, this.weatherText);
}

class _Screen2State extends State<Screen2> {
  String apiKey = 'b0f8cc0c19ce85fd145946f87ccd3837';
  String weatherData = '';
  static bool weatherDataLoaded = false; // for not making multiple API requests
  List<WeatherInfo> weatherInfo = [];

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
            final iconCode = forecast['weather'][0]['icon'];
            final iconData = getIcon(iconCode);
            final weatherText =
                ' $dayOfWeek, $formattedDate-$time-$temperature°C-$weatherDescription\n\n';
            weatherInfo.add(WeatherInfo(iconData, weatherText));
          }
        });
      } else {
        throw Exception('Failed to load weather data');
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  IconData getIcon(String currentWeather) {
    switch (currentWeather) {
      case '01d':
        return WeatherIcons.day_sunny;
      case '01n':
        return WeatherIcons.night_clear;
      case '02d':
        return WeatherIcons.day_cloudy;
      case '02n':
        return WeatherIcons.night_cloudy;
      case '03d':
        return WeatherIcons.day_cloudy;
      case '03n':
        return WeatherIcons.night_cloudy;
      case '04d':
        return WeatherIcons.day_cloudy;
      case '04n':
        return WeatherIcons.night_cloudy;
      case '09d':
        return WeatherIcons.day_rain;
      case '09n':
        return WeatherIcons.night_rain;
      case '10d':
        return WeatherIcons.day_rain;
      case '10n':
        return WeatherIcons.night_rain;
      case '11d':
        return WeatherIcons.day_thunderstorm;
      case '11n':
        return WeatherIcons.night_thunderstorm;
      case '13d':
        return WeatherIcons.day_snow;
      case '13n':
        return WeatherIcons.night_snow;
      case '50d':
        return WeatherIcons.day_fog;
      case '50n':
        return WeatherIcons.night_fog;
      default:
        return WeatherIcons.na;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: weatherInfo.isEmpty
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
                child: Column(
                  children: weatherInfo.map((weatherInfo) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(weatherInfo.iconData),
                        const SizedBox(width: 8),
                        Text(weatherInfo.weatherText),
                      ],
                    );
                  }).toList(),
                ),
              ),
      ),
    );
  }
}
