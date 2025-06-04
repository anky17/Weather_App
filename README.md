# Weather App

A simple Flutter weather app that shows current weather based on city search or current location.

---

## Features

- Search weather by city name
- Detect weather for current GPS location
- Displays temperature, humidity, wind speed, and weather icon
- Uses OpenWeatherMap API

## API Key Setup

This project **does NOT include** the OpenWeatherMap API key for security reasons.

To run the app:

1. Open `lib/utils/const.dart`
2. Add your own API key as a string constant, for example:

```dart
const String OPENWEATHER_API_KEY = "your_openweathermap_api_key_here";
```
