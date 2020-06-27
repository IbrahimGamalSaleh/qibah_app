import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:qibladirection/qiblah_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
          future: _deviceSupport,
          builder: (_, AsyncSnapshot<bool> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(
                child: CircularProgressIndicator(),
              );
            if (snapshot.hasError)
              return Center(
                child:
                    Text("Error: inside has error${snapshot.error.toString()}"),
              );
            else {
              return QiblahCompass();
//                  : Center(
//                      child: Text(": inside data${snapshot.data}"),
//                    );
            }

//            if (snapshot.data)
//              return QiblahCompass();
//            else
////              return QiblahMaps();
//              return Center(
//                child:
//                    Text("Error:inside else data ${snapshot.error.toString()}"),
//              );
          },
        ),
      ),
    );
  }
}

class QiblahCompass extends StatefulWidget {
  @override
  _QiblahCompassState createState() => _QiblahCompassState();
}

class _QiblahCompassState extends State<QiblahCompass> {
  final _locationStreamController =
      StreamController<LocationStatus>.broadcast();

  get stream => _locationStreamController.stream;

  @override
  void initState() {
    _checkLocationStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder(
        stream: stream,
        builder: (context, AsyncSnapshot<LocationStatus> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          if (snapshot.data.enabled == true) {
            switch (snapshot.data.status) {
              case GeolocationStatus.granted:
                return QiblahCompassWidget();

              case GeolocationStatus.denied:
                return Center(
                  child: Text("Location service permission denied"),
                );
              case GeolocationStatus.disabled:
                return Center(
                  child: Text("Location service disabled"),
                );
              case GeolocationStatus.unknown:
                return Center(
                  child: Text("Unknown Location service error"),
                );
              default:
                return Container();
            }
          } else {
            return Center(
              child: Text("Please enable Location service"),
            );
          }
        },
      ),
    );
  }

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled &&
        locationStatus.status == GeolocationStatus.denied) {
      await FlutterQiblah.requestPermission();
      final s = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(s);
    } else
      _locationStreamController.sink.add(locationStatus);
  }

  @override
  void dispose() {
    _locationStreamController.close();
//    FlutterQiblah().dispose();
    super.dispose();
  }
}
