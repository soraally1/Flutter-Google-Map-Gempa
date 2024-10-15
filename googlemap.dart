// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math' show cos, sqrt, asin;
import 'package:belajar_maps/widgets/detail_eq.dart';
import 'package:belajar_maps/widgets/infosr.dart';
import 'package:belajar_maps/widgets/tsunami_potential.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:belajar_maps/data_helper.dart';


const String BMKG_API_URL = 'https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json';

class Googlemapflutter extends StatefulWidget {
  const Googlemapflutter({super.key});

  @override
  State<Googlemapflutter> createState() => _GooglemapflutterState();
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}

class _GooglemapflutterState extends State<Googlemapflutter> {

  Position? _currentPosition;
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;
  Map<String, dynamic>? gempaData;
  double? gempaDistance;
  List<double>? gempaCoordinates;

  @override
  void initState() {
    customMarker();
    super.initState();
    readData();
    getGempaCoordinates();
    getGempaHumanReadableAddress();
    _getPositionAndCalculateDistance();
  }

  void customMarker() {
    BitmapDescriptor.asset(
      const ImageConfiguration(),
      "assets/icons/marker.png"
    ).then((icon) {
      setState(() {
        customIcon = icon;
      });
    });
  }

  Future<void> readData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();

    ref.orderByKey().limitToLast(1).onValue.listen((DatabaseEvent event) async {
      final data = event.snapshot.value;
      if (data != null) {
        Map<String, dynamic> dataMap = Map<String, dynamic>.from(data as Map);
        String latestKey = dataMap.keys.first;
        Map<String, dynamic> latestEarthquake = Map<String, dynamic>.from(dataMap[latestKey]['Infogempa']['gempa']);

        setState(() {
          gempaData = latestEarthquake;
        });
        getGempaCoordinates();

// Fungsi untuk mengekstrak nama kota dari string wilayah
String extractWilayah(String wilayah) {
  List<String> parts = wilayah.split(' ');
  return parts.isNotEmpty ? parts.last : wilayah;
}

// Fungsi untuk mengekstrak nama kabupaten dari string wilayah
String extractDistrictName(String wilayah) {
  List<String> parts = wilayah.split(','); // Memisahkan berdasarkan koma
  if (parts.length > 1) {
    return parts.length > 2 ? parts[1].trim() : parts[1].trim(); // Mengambil bagian kedua (kabupaten)
  }
  return ''; // Mengembalikan string kosong jika tidak ada kabupaten
}
// Simpan data ke SQLite
Map<String, dynamic> gempaToSave = {
  'tanggal': latestEarthquake['Tanggal'],
  'jam': latestEarthquake['Jam'],
  'lintang': latestEarthquake['Lintang'],
  'bujur': latestEarthquake['Bujur'],
  'magnitude': latestEarthquake['Magnitude'],
  'kedalaman': latestEarthquake['Kedalaman'],
  'coordinates': latestEarthquake['Coordinates'], // Koordinat
  'status': latestEarthquake['Status'], // Status gempa (jika ada)
  'wilayah': extractWilayah(latestEarthquake['Wilayah']), // Menyimpan nama kota
  'jenisGempa': latestEarthquake['Jenis'], // Jenis gempa (jika ada)
  'tsunamiPotensial': latestEarthquake['TsunamiPotensial'], // Potensi tsunami (jika ada)
  'infoTambahan': latestEarthquake['InfoTambahan'], // Info tambahan lainnya (jika ada)
  'kabupaten': extractDistrictName(latestEarthquake['Wilayah']), // Menyimpan nama kabupaten
};

setState(() {
  gempaData = latestEarthquake;
  gempaData!['Wilayah'] = extractWilayah(latestEarthquake['Wilayah']); // Simpan wilayah yang sudah diproses
});
        await DatabaseHelper().insertGempa(gempaToSave);
      }
    });
  }

  void getGempaCoordinates() async {
    if (gempaData == null) {
      return;
    }

    String coordinatesBMKG = gempaData!['Coordinates'];

    List<String> parts = coordinatesBMKG.split(',');
    var gempaCoordinatesx = List<double>.filled(2, 0);

    if (parts.length == 2) {
      gempaCoordinatesx[0] = double.parse(parts[0].trim());
      gempaCoordinatesx[1] = double.parse(parts[1].trim());
    }

    setState(() {
      gempaCoordinates = gempaCoordinatesx;
    });
  }

  Future<double> calculateGempaDistance(latitude, longitude) async {
    if (gempaData == null || _currentPosition == null) return 0.0;

    return calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    );
  }

  void getGempaHumanReadableAddress() async {
    if (gempaCoordinates == null) {
      return;
    }

    List<Placemark> placemarks = await placemarkFromCoordinates(-4.12,129.79);
    print(placemarks);
  }

  void _getPositionAndCalculateDistance() async {
    try {
      Position position = await _determinePosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(gempaCoordinates![0], gempaCoordinates![1]);
      print(placemarks);
      setState(() {
        _currentPosition = position;
      });

      double distance = await calculateGempaDistance(gempaCoordinates![0], gempaCoordinates![1]);
      setState(() {
        gempaDistance = distance;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: gempaCoordinates == null && gempaData == null && gempaDistance == null
        ? Center(child: CircularProgressIndicator()) 
        : Stack(
        children: [
          Container(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(gempaCoordinates![0], gempaCoordinates![1]),
                zoom : 2
              ),
              markers: {
                Marker(
                  markerId: MarkerId('1'),
                  position: LatLng(gempaCoordinates![0], gempaCoordinates![1]),
                  anchor: const Offset(0.5, 0.5),
                  draggable: true,
                  icon: customIcon,
                )
              }
            ),
          ),
          Container(
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  AppBar(
                    toolbarHeight: 78,
                    title : Text('Informasi Gempa'),
                    leading: Icon(Icons.arrow_back),
                    centerTitle: true,
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 140,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Colors.white
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      infosr(
                                        satuangempa: gempaData!['Magnitude'],
                                        icongempa: 'assets/icons/sr.png',
                                        namabawah: 'Magnitudo',
                                      ),
                                      Container(
                                        width: 1,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFCCCCCC)
                                        ),
                                      ),
                                      infosr(
                                        satuangempa: 'Kota',
                                        icongempa: 'assets/icons/location.png',
                                        namabawah: 'Kabupaten',
                                      ),
                                      Container(
                                        width: 1,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFCCCCCC)
                                        ),
                                      ),
                                      infosr(
                                        satuangempa: gempaData!['Kedalaman'],
                                        icongempa: 'assets/icons/map.png',
                                        namabawah: 'Kedalaman',
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  TsunamiPotential()
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 195,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(24))
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  DetailEq(
                                  headline: "Waktu", 
                                  detailicon: "assets/icons/clock.png", 
                                  detaildata: "${gempaData!['Tanggal']} | ${gempaData!['Jam']}"),
                                   DetailEq(
                                  headline: "Kordinat", 
                                  detailicon: "assets/icons/map.png", 
                                  detaildata: "${gempaData!['Coordinates']}"),
                                   DetailEq(
                                  headline: "Kedalaman", 
                                  detailicon: "assets/icons/distance.png", 
                                  detaildata: "${gempaData!['Kedalaman']}"),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}

extractDistrictName(param0) {
}
