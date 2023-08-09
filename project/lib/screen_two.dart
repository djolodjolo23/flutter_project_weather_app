import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';
import 'location_service.dart';

class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  createState() => _Screen2State();
}

class WeatherInfo {
  final IconData iconData;
  final String weatherText;
  WeatherInfo(this.iconData, this.weatherText);
}

class CachedWeatherInfo {
  static List<WeatherInfo> weatherInfo = [];
}

class _Screen2State extends State<Screen2> {
  String apiKey = 'b0f8cc0c19ce85fd145946f87ccd3837';
  String weatherData = '';
  LocationData? locationData;
  static bool weatherDataLoaded = false; // for not making multiple API requests
  List<WeatherInfo> weatherInfo = [];

  @override
  void initState() {
    super.initState();
    if (CachedWeatherInfo.weatherInfo.isEmpty) {
      fetchWeatherDataUsingLocation();
    } else {
      setState(() {
        weatherInfo = CachedWeatherInfo.weatherInfo;
      });
    }
  }

  @override
  void dispose() {
    weatherDataLoaded = false;
    super.dispose();
  }

  Future<void> fetchWeatherDataUsingLocation() async {
    if (!weatherDataLoaded) {
      LocationData? locationData = await fetchCurrentLocation();
      if (locationData != null) {
        final double latitude = locationData.latitude!;
        final double longitude = locationData.longitude!;
        fetchWeatherData(latitude, longitude);
        setState(() {
          weatherDataLoaded = true;
        });
      } else {
        setState(() {
          weatherDataLoaded = false;
        });
      }
    }
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
          CachedWeatherInfo.weatherInfo = weatherInfo;
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
            ? const CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              )
            : SingleChildScrollView(
                child: Column(
                  children: weatherInfo.map((weatherInfo) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Icon(weatherInfo.iconData),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(weatherInfo.weatherText),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
      ),
    );
  }
}
