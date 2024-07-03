import 'package:flutter/material.dart';
import 'package:muhammadrifkan/models/weather.dart';
import 'package:muhammadrifkan/pages/result_page.dart';
import 'package:muhammadrifkan/services/weather_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController placeController = TextEditingController();
  final WeatherService weatherService = WeatherService.instance;
  late Future<List<Weather>> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  void _fetchWeatherData() {
    setState(() {
      _weatherFuture = weatherService.getWeathers();
    });
  }

  void openDialog() {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const Text('Cari data cuaca', style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500
                  )),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'ex. Jakarta, Indonesia.',
                    ),
                    controller: placeController,
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: () async {
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                      
                     final result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return ResultPage(place: placeController.text);
                      }));
                      
                      if (result == 'success') {
                        placeController.clear();
                        _fetchWeatherData();
                      } 
                    }, 
                    style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith((states) => Colors.lightBlue),
                      foregroundColor: WidgetStateColor.resolveWith((states) => Colors.white),
                    ),
                    child: const Text('Cari')
                  )
                ],
              ),
            ),
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App', style: TextStyle(
          fontSize: 18,
        )),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Weather>>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(left: 20, top: 20),
              child: Text('Belum ada data cuaca yang disimpan, \nSilahkan cari dan simpan data baru dari API!'),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(top: 15),
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Weather weather = snapshot.data![index];
                  return _cardWeather(weather);
                }
              ),
            );
          }
        }
      ),
      floatingActionButton: Visibility(
        visible: true,
        child: FloatingActionButton(
          onPressed: openDialog,
          backgroundColor: Colors.lightBlueAccent,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _cardWeather(Weather weather) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Card(
        elevation: 2,
        child: ListTile(
          title: Text(weather.title),
          subtitle: Text('${weather.temp.toString()}°C, ${weather.windspeed.toString()}m/s, ${weather.weather}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // IconButton(onPressed: () {}, icon: const Icon(Icons.edit, color: Colors.lightBlue)),
              IconButton(onPressed: () {
                weatherService.deleteData(weather.id);
                _fetchWeatherData();
              }, icon: const Icon(Icons.delete, color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}