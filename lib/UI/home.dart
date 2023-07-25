import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app_2/UI/constanta.dart';
import 'package:weather_app_2/model/models.dart';
import 'package:weather_app_2/model/modelsDetail.dart';

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  List<City> cities = [];
  String selectedCityId = '';
  List<WeatherData> weatherDataList = [];
  Constants myConstant = Constants();

  get http => null;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate =
        DateFormat('d MMMM - HH:mm', 'id_ID').format(dateTime);
    return formattedDate;
  }

  Future<void> fetchData() async {
    final url =
        Uri.parse('https://ibnux.github.io/BMKG-importer/cuaca/wilayah.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      cities = (data as List)
          .map((json) => City(json, json['id'], json['kota'] as String))
          .toList();
      setState(() {});
    } else {
      print('Gagal mengambil data dari internet.');
    }
  }

  Future<void> fetchWeatherData() async {
    final url = Uri.parse(
        'https://ibnux.github.io/BMKG-importer/cuaca/$selectedCityId.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      weatherDataList = data.map((json) => WeatherData.fromJson(json)).toList();
      setState(() {});
      print(weatherDataList[2].dateTime);
    } else {
      print('Gagal mengambil data cuaca dari API.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
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
                    hint: Text('Pilih Kota'),
                    items: cities.map<DropdownMenuItem<City>>((City city) {
                      return DropdownMenuItem<City>(
                        value: city,
                        child: Text(city.city),
                      );
                    }).toList(),
                    onChanged: (City? newValue) {
                      setState(() {
                        selectedCityId = newValue!.id;
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton<City>(
              hint: Text('Pilih Kota'),
              value: selectedCityId.isNotEmpty
                  ? cities.firstWhere((city) => city.id == selectedCityId)
                  : null,
              onChanged: (City? newValue) {
                setState(() {
                  selectedCityId = newValue!.id;
                });
              },
              items: cities.map<DropdownMenuItem<City>>((City city) {
                return DropdownMenuItem<City>(
                  value: city,
                  child: Text(city.city),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text('ID Kota: $selectedCityId'),
            ElevatedButton(
              onPressed: selectedCityId.isNotEmpty ? fetchWeatherData : null,
              child: Text('Dapatkan Data Cuaca'),
            ),
          ],
        ),
      ),
    );
  }
}
