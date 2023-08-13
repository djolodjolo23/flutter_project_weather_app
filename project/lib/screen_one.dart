import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'weather_animation_helper.dart';
import 'package:weather_animation/weather_animation.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  // declaring these as globals
  String apiKey = 'b0f8cc0c19ce85fd145946f87ccd3837';
  String weatherData = '';
  static bool weatherDataLoaded = false; // for not making multiple API requests
  static String cachedWeatherData = '';
  static String cachedWeatherDescription = '';
  static String iconCode = '';

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
        String cityName = weatherJson['name'].toString();
        String weatherDescription =
            weatherJson['weather'][0]['description'].toString();
        iconCode = weatherJson['weather'][0]['icon'];
        double temperatureValue = weatherJson['main']['temp'] - 273.15;
        int roundedTemperature = temperatureValue.round().toInt();
        String temperature = roundedTemperature.toString();
        String formattedDate =
            DateFormat('MMMM dd, yyyy').format(DateTime.now());
        String dayOfWeek = DateFormat('EEEE').format(DateTime.now());
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
    WeatherScene scene;
    scene =
        WeatherAnimationHelper.getWeatherAnimation(cachedWeatherDescription);

    Widget customWeatherWidget = const WrapperScene(
      colors: [
        Color.fromARGB(255, 69, 120, 177),
        Color.fromARGB(255, 231, 182, 167),
      ],
      children: [
        SunWidget(),
        CloudWidget(),
      ],
    );

    List<String> rows = cachedWeatherData.split('\n');

    List<InlineSpan> modifiedSpans = [];
    for (int index = 0; index < rows.length; index++) {
      String row = rows[index];
      if (index < 5) {
        modifiedSpans.add(
          TextSpan(
            text: '   $row\n',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      } else {
        modifiedSpans.add(
          TextSpan(
            text: '$row\n',
            style: const TextStyle(
              fontSize: 40,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
      if (index == 3) {
        IconData icondata = WeatherAnimationHelper.getIcon(iconCode);
        modifiedSpans.add(
          WidgetSpan(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Icon(icondata),
            ),
          ),
        );
      }
    }

    bool isLoading = cachedWeatherData.isEmpty;
    bool shouldUseCustomWidget = cachedWeatherDescription.contains('cloud') ||
        cachedWeatherDescription.contains('overcast');

    return Container(
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!isLoading && !shouldUseCustomWidget)
            scene.getWeather()
          else
            const Offstage(),
          if (!isLoading && shouldUseCustomWidget)
            customWeatherWidget
          else
            const Offstage(),
          Positioned.fill(
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    )
                  : Container(
                      padding: const EdgeInsets.only(top: 300.0),
                      child: Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            children: modifiedSpans,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
