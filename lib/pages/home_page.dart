import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/utils/const.dart';
import 'package:weather/weather.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _seachCity = TextEditingController();
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  Weather? _weather;

  @override
  void initState() {
    super.initState();
    _fetchWeatherForCurrentLocation();
  }

  void _searchWeatherByCity() {
    final city = _seachCity.text.trim();
    if (city.isEmpty) return;

    _wf
        .currentWeatherByCityName(city)
        .then((w) {
          setState(() {
            _weather = w;
          });
        })
        .catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('City not found or error occurred')),
          );
        });
  }

  Future<void> _fetchWeatherForCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    String cityName = placemarks.first.locality ?? "Unknown";

    _wf.currentWeatherByCityName(cityName).then((w) {
      setState(() {
        _weather = w;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      body: SafeArea(child: _buildUI()),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchWeatherForCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildUI() {
    if (_weather == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _searchBar(),
            const SizedBox(height: 20),
            _locationHeader(),
            const SizedBox(height: 20),
            _dateTimeInfo(),
            const SizedBox(height: 20),
            _weatherIcon(),
            const SizedBox(height: 20),
            _showTemperature(),
            const SizedBox(height: 30),
            _extraInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _locationHeader() {
    return Text(
      _weather?.areaName ?? "",
      style: const TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat("hh:mm a").format(now),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          "${DateFormat("EEEE, d MMMM y").format(now)}",
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _weatherIcon() {
    final iconCode = _weather?.weatherIcon;
    final iconUrl =
        iconCode != null
            ? "http://openweathermap.org/img/wn/$iconCode@4x.png"
            : "";

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(
              255,
              232,
              28,
              28,
            ).withOpacity(0.07), // translucent dark background
          ),
          child: Image.network(
            iconUrl,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => const Icon(Icons.error),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _weather?.weatherDescription?.toUpperCase() ?? "",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _showTemperature() {
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsFixed(0)}°C",
      style: const TextStyle(
        fontSize: 80,
        fontWeight: FontWeight.w600,
        color: Colors.deepPurple,
      ),
    );
  }

  Widget _extraInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurpleAccent, Colors.purpleAccent.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          const BoxShadow(
            color: Colors.deepPurple,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow(
            "Max Temp",
            "${_weather?.tempMax?.celsius?.toStringAsFixed(0)}°C",
            "Min Temp",
            "${_weather?.tempMin?.celsius?.toStringAsFixed(0)}°C",
          ),
          const SizedBox(height: 12),
          _infoRow(
            "Wind",
            "${_weather?.windSpeed?.toStringAsFixed(0)} m/s",
            "Humidity",
            "${_weather?.humidity?.toStringAsFixed(0)}%",
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label1, String value1, String label2, String value2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_infoItem(label1, value1), _infoItem(label2, value2)],
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return TextField(
      controller: _seachCity,
      decoration: InputDecoration(
        hintText: "Enter your city..!",
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.send),
          onPressed: _searchWeatherByCity,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onSubmitted: (value) => _searchWeatherByCity(),
    );
  }
}
