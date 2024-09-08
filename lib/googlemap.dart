// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:belajar_maps/widgets/detail_eq.dart';
import 'package:belajar_maps/widgets/infosr.dart';
import 'package:belajar_maps/widgets/tsunami_potential.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Googlemapflutter extends StatefulWidget {
  const Googlemapflutter({super.key});

  @override
  State<Googlemapflutter> createState() => _GooglemapflutterState();
}

class _GooglemapflutterState extends State<Googlemapflutter> {

    LatLng posisisekarang = const LatLng(-7.009033662685147, 110.42770385742188);
    BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker; 
    @override
    void initState() {
      customMarker();
      super.initState();
    }

    void customMarker() {
      BitmapDescriptor.asset(
        const ImageConfiguration(),
        "assets/icons/marker.png"
        ).then((icon) {
          setState(() {
            customIcon = icon;
          });
        }
      );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            child: GoogleMap(initialCameraPosition: CameraPosition(
              target: posisisekarang,
              zoom : 10
            ),
            markers: {
              Marker(markerId: MarkerId('1'),
              position: posisisekarang,
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
                                        satuangempa: '2,5',
                                        icongempa: 'assets/icons/sr.png',
                                        namabawah: 'Magnitudo',
                                      ),
                                      Container(
                                        width: 1,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFCCCCCC)
                                          // color: Colors.black
                                          ),
                                        ),
                                      infosr(
                                        satuangempa: 'Mijen',
                                        icongempa: 'assets/icons/location.png',
                                        namabawah: 'Kota Semarang',
                                      ),
                                      Container(
                                        width: 1,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFCCCCCC)
                                          // color: Colors.black
                                          ),
                                        ),
                                      infosr(
                                        satuangempa: '10 KM',
                                        icongempa: 'assets/icons/map.png',
                                        namabawah: 'Kedalaman',
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  TsunamiPotential()
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
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
                                    detaildata: "17 Agustus 2024, 08:10:10 WIB"
                                    ),

                                  DetailEq(
                                    headline: "Koordinat",
                                    detailicon: "assets/icons/coordinate.png",
                                    detaildata: "91 BT 93 BT 101 LS"
                                    ),

                                  DetailEq(
                                    headline: "Jarak",
                                    detailicon: "assets/icons/distance.png",
                                    detaildata: "101 KM"
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFFF6643C),
                            borderRadius: BorderRadius.all(Radius.circular(12))
                          ),
                          child: 
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Lebih lanjut',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              Container(
                                width: 24,
                                height: 24,
                                child: Image.asset("assets/icons/arrow-right.png",
                                fit: BoxFit.fill,
                                )
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}