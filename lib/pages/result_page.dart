import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:muhammadrifkan/services/weather_service.dart';

class ResultPage extends StatefulWidget {
  final String place;

  const ResultPage({super.key, required this.place});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String _formatTimezone(int timezoneInSeconds) {
    final hours = timezoneInSeconds ~/ 3600;
    final sign = hours >= 0 ? '+' : '-';
    final formattedHours = hours.abs().toString().padLeft(2, '0');
    return 'GMT$sign$formattedHours';
  }

  Future<Map<String, dynamic>> getDataFromAPI() async {
    final response = await http.get(Uri.parse("https://api.openweathermap.org/data/2.5/weather/?q=${widget.place}&units=metric&appid=1e44ec61894486d64e093a17f1dde57a"));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Something went wrong with request!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final WeatherService weatherService = WeatherService.instance;

    String? title, weather;
    double? temp, windspeed;

    void redirectBack() {
      Navigator.pop(context, 'success');
    }

    double convertToDouble(dynamic value) {
      if (value is int) {
        return value.toDouble();
      } else if (value is double) {
        return value;
      } else {
        throw Exception('Invalid type');
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light
        )
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Detail cuaca", style: TextStyle(color: Colors.white, fontSize: 18)),
          backgroundColor: Colors.lightBlue,
          centerTitle: true,
          leading: GestureDetector(
            onTap: () {
              redirectBack();
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          )
        ),

        body: Container(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: FutureBuilder(
            future: getDataFromAPI(), 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasData) {
                final data = snapshot.data!;

                title     = data['name'];
                temp      = convertToDouble(data['main']['feels_like']);
                windspeed = convertToDouble(data['wind']['speed']);
                weather   = data['weather'][0]['main'];

                return Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${data['name']} - ${data['weather'][0]['description']}", style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      )),
                      const SizedBox(height: 10),
                      Table(
                        border: TableBorder.all(color: Colors.black),
                        columnWidths: const {
                          0: FixedColumnWidth(150),
                          1: FlexColumnWidth(),
                        },
                        children: [
                          TableRow(children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Weather:"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(children: [
                                Text("${data['weather'][0]['main']} "),
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 18,
                                        offset: const Offset(0, 3), // mengatur posisi shadow
                                      ),
                                    ],
                                  ),
                                  child: Image(
                                    image: NetworkImage("https://openweathermap.org/img/wn/${data['weather'][0]['icon']}@2x.png"),
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                              ]),
                            ),
                          ]),
                          TableRow(children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Temperature:"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("${data['main']['feels_like']} °"),
                            ),
                          ]),
                          TableRow(children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Wind Speed:"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("${data['wind']['speed']} m/s"),
                            ),
                          ]),
                          TableRow(children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Coordinates:"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Lat: ${data['coord']['lat']}, Lon: ${data['coord']['lon']}"),
                            ),
                          ]),
                          TableRow(children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Country/State:"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(children: [
                                Image(
                                  alignment: Alignment.centerLeft,
                                  image: NetworkImage("https://flagsapi.com/${data['sys']['country']}/shiny/64.png"),
                                  width: 20,
                                  height: 20,
                                ),
                                Text(" ${data['name']}")
                              ]),
                            ),
                          ]),
                          TableRow(children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Timezone:"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(_formatTimezone(data['timezone'])),
                            ),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              redirectBack();
                            }, 
                            style: ButtonStyle(
                              backgroundColor: WidgetStateColor.resolveWith((states) => Colors.grey),
                              foregroundColor: WidgetStateColor.resolveWith((states) => Colors.white),
                            ),
                            child: const Text('Kembali'),
                          ),

                          const SizedBox(width: 8),

                          ElevatedButton(
                            onPressed: () {
                              weatherService.addData(title, temp, windspeed, weather);
                              redirectBack();
                            }, 
                            style: ButtonStyle(
                              backgroundColor: WidgetStateColor.resolveWith((states) => Colors.lightBlue),
                              foregroundColor: WidgetStateColor.resolveWith((states) => Colors.white),
                            ),
                            child: const Text('Simpan'),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                  child: Text('Data cuaca pada lokasi yang dicari tidak tersedia!'),
                );
              }
            },
          )
        )
      )
    );
  }
}