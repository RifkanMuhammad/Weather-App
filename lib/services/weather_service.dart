import 'package:muhammadrifkan/models/weather.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class WeatherService {
  static Database? _db;
  static final WeatherService instance = WeatherService._constructor();

  WeatherService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  final String _weatherTableName = 'weathers';
  final String _weatherTitleColumn = 'title';
  final String _weatherTempColumn = 'temp';
  final String _weatherWindSpeedColumn = 'windspeed';
  final String _weatherWeatherColumn = 'weather';

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'master_db.db');
    final database = await openDatabase(
      databasePath,
      version: 3,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $_weatherTableName (
            id INTEGER PRIMARY KEY,
            $_weatherTitleColumn TEXT,
            $_weatherTempColumn DOUBLE,
            $_weatherWindSpeedColumn DOUBLE,
            $_weatherWeatherColumn TEXT
          )
        ''');
      },
    );

    return database;
  }

  void addData(String? title, double? temp, double? windspeed, String? weather) async {
    final db = await database;
    await db.insert(_weatherTableName, {
      _weatherTitleColumn: title,
      _weatherTempColumn: temp,
      _weatherWindSpeedColumn: windspeed, 
      _weatherWeatherColumn: weather
    });
  }

  void deleteData(int id) async {
    final db = await database;
    await db.delete(_weatherTableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Weather>> getWeathers() async {
    final db = await database;
    final data = await db.query(_weatherTableName, orderBy: 'id DESC');

    List<Weather> weathers = data
      .map((e) => Weather(
          id: e['id'] as int,
          title: e['title'] as String,
          temp: e['temp'] as double,
          windspeed: e['windspeed'] as double,
          weather: e['weather'] as String
        ))
      .toList();

    return weathers;
  }
}
