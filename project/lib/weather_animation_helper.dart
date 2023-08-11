import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:weather_animation/weather_animation.dart';

class WeatherAnimationHelper {
  static WeatherScene getWeatherAnimation(String weatherDescription) {
    if (weatherDescription.contains('clear')) {
      return WeatherScene.scorchingSun;
    } else if (weatherDescription.contains('cloud') ||
        weatherDescription.contains('overcast')) {
      return WeatherScene.rainyOvercast;
    } else if (weatherDescription.contains('rain') ||
        weatherDescription.contains('drizzle')) {
      return WeatherScene.rainyOvercast;
    } else if (weatherDescription.contains('snow')) {
      return WeatherScene.snowfall;
    } else if (weatherDescription.contains('thunder')) {
      return WeatherScene.stormy;
    } else {
      return WeatherScene.weatherEvery;
    }
  }

  static IconData getIcon(String currentWeather) {
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
}
