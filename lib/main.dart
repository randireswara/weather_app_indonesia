import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:weather_app_2/UI/home.dart';
import 'dart:convert';

import 'UI/constanta.dart';
import 'UI/weather_item.dart';
import 'model/models.dart';
import 'model/modelsDetail.dart';

void main() {
  initializeDateFormatting('id_ID', null).then((_) {
    // Pastikan 'id_ID' sesuai dengan kode bahasa dan wilayah yang sesuai dengan kebutuhan Anda.
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kota dan ID',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<City> cities = [];
  String selectedCityId = '';
  List<WeatherData> weatherDataList = [];
  String provinsi = "DKI Djakarta";
  // String city = "Jakarta Pusat";
  var currentDate = 'Loading...';
  Constants myConstants = Constants();
  String imageUrl = '';
  double temperature = 0;
  String kondisiCuaca = 'Loading..';
  int windSpeed = 0;
  int humidity = 0;
  double tempF = 0;
  var SelectedBox = 0;

  List consolidatedWeatherList = [];

  // berawan,hujan ringan

  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xffABCFF2), Color(0xff9AC6F3)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchWeatherData("501191");
    // fetchWeatherData();
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('EEEE, d MMMM').format(dateTime);
    return formattedDate;
  }

  String formatTanggal(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('d MMMM', 'id_ID').format(dateTime);
    return formattedDate;
  }

  String formatJam(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('HH:mm').format(dateTime);
    return formattedDate;
  }

  String makeImage(String kondisiCuaca) {
    String image = "";
    if (kondisiCuaca == "Berawan") {
      image = "lightcloud";
    } else if (kondisiCuaca == "Hujan Ringan") {
      image = "lightrain";
    } else if (kondisiCuaca == "Cerah Berawan") {
      image = "clear";
    } else if (kondisiCuaca == "Berkabut") {
      image = "heavycloud";
    } else if (kondisiCuaca == "Hujan Petir") {
      image = "heavyrain";
    } else {
      image = "lightcloud";
    }

    return image;
  }

  Future<void> fetchData() async {
    final url =
        Uri.parse('https://ibnux.github.io/BMKG-importer/cuaca/wilayah.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      cities = (data as List)
          .map((json) =>
              City(json['propinsi'], json['id'], json['kota'] as String))
          .toList();
      setState(() {});
      print("tes");
    } else {
      print('Gagal mengambil data dari internet.');
    }
  }

  //bikin kondisi default

  Future<void> fetchWeatherData(String id) async {
    final url =
        Uri.parse('https://ibnux.github.io/BMKG-importer/cuaca/$id.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      weatherDataList = data.map((json) => WeatherData.fromJson(json)).toList();
      setState(() {
        currentDate = formatDate(weatherDataList[0].dateTime);
        temperature = weatherDataList[0].tempC;
        kondisiCuaca = weatherDataList[0].weatherDescription;
        humidity = weatherDataList[0].humidity;
        imageUrl = makeImage(weatherDataList[0].weatherDescription);
        tempF = weatherDataList[0].tempF;
      });
      print(weatherDataList[2].dateTime);
    } else {
      print('Gagal mengambil data cuaca dari API.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profil Image
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Image.asset(
                  'assets/profile.png',
                  width: 40,
                  height: 40,
                ),
              ),

              // Location dropdown
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/pin.png',
                    width: 20,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  DropdownButtonHideUnderline(
                      child: DropdownButton<City>(
                    hint: Text("Pilih Kota"),
                    items: cities.map<DropdownMenuItem<City>>((City city) {
                      return DropdownMenuItem<City>(
                        value: city,
                        child: Text(city.city),
                      );
                    }).toList(),
                    onChanged: (City? newValue) {
                      setState(() {
                        selectedCityId = newValue!.id;
                        fetchWeatherData(newValue.id);
                        provinsi = newValue.provinsi;
                        SelectedBox = 0;

                        // Perubahan data provinsi
                      });
                    },
                    value: selectedCityId.isNotEmpty
                        ? cities.firstWhere((city) => city.id == selectedCityId)
                        : null,
                  ))
                ],
              )
            ],
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provinsi,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30.0,
              ),
            ),
            Text(
              currentDate,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              width: size.width,
              height: 200,
              decoration: BoxDecoration(
                  color: myConstants.primaryColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: myConstants.primaryColor.withOpacity(.5),
                      offset: const Offset(0, 25),
                      blurRadius: 10,
                      spreadRadius: -12,
                    )
                  ]),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -40,
                    left: 20,
                    child: imageUrl == ''
                        ? const Text('')
                        : Image.asset(
                            'assets/$imageUrl.png',
                            width: 150,
                          ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    child: Text(
                      kondisiCuaca,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            temperature.toString(),
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()..shader = linearGradient,
                            ),
                          ),
                        ),
                        Text(
                          'o',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()..shader = linearGradient,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  weatherItem(
                    text: 'Temp C',
                    value: temperature.toInt(),
                    unit: 'C',
                    imageUrl: 'assets/windspeed.png',
                  ),
                  weatherItem(
                      text: 'Humidity',
                      value: humidity,
                      unit: '',
                      imageUrl: 'assets/humidity.png'),
                  weatherItem(
                    text: 'Temp F',
                    value: tempF.toInt(),
                    unit: 'F',
                    imageUrl: 'assets/max-temp.png',
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Today',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Text(
                  'Next Days',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: myConstants.primaryColor),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: weatherDataList.length,
                  itemBuilder: (BuildContext context, int index) {
                    // tanggal,jam,cuaca,suhu

                    // selected

                    bool isSelected = SelectedBox == index;

                    int angka = 1;

                    var selected = weatherDataList[2].dateTime;

                    // selected
                    var selected2 = weatherDataList[index].dateTime;
                    String today = DateTime.now().toString().substring(0, 10);
                    var date = formatTanggal(weatherDataList[index].dateTime);
                    var time = formatJam(weatherDataList[index].dateTime);

                    var imageDetail =
                        makeImage(weatherDataList[index].weatherDescription);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          SelectedBox = index;
                          currentDate = formatDate(weatherDataList[0].dateTime);
                          temperature = weatherDataList[index].tempC;
                          kondisiCuaca =
                              weatherDataList[index].weatherDescription;
                          humidity = weatherDataList[index].humidity;
                          imageUrl = makeImage(
                              weatherDataList[index].weatherDescription);
                          tempF = weatherDataList[index].tempF;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        margin: const EdgeInsets.only(
                            right: 20, bottom: 10, top: 10),
                        width: 80,
                        decoration: BoxDecoration(
                            color: isSelected == true
                                ? myConstants.primaryColor
                                : Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 1),
                                blurRadius: 5,
                                color: selected == today
                                    ? myConstants.primaryColor
                                    : Colors.black54.withOpacity(.2),
                              ),
                            ]),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              date,
                              style: TextStyle(
                                fontSize: 17,
                                color: isSelected == true
                                    ? Colors.white
                                    : myConstants.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Image.asset(
                              'assets/$imageDetail.png',
                              width: 30,
                            ),
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 17,
                                color: isSelected == true
                                    ? Colors.white
                                    : myConstants.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
