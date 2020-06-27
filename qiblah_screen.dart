import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'dart:math' show pi;
import 'package:flutter_svg/svg.dart';

class QiblahCompassWidget extends StatelessWidget {
  final _compassSvg = SvgPicture.asset('assets/compass.svg');
  final _needleSvg = SvgPicture.asset(
    'assets/needle.svg',
    fit: BoxFit.contain,
    height: 300,
    alignment: Alignment.center,
  );

  double _degToRad(double deg) {
    print('deg : $deg');
    return deg * (pi / 180.0) * -1;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(
            child: CircularProgressIndicator(),
          );

        if (snapshot.hasError) {
          return Center(
            child: Text('has error ${snapshot.error.toString()}'),
          );
        }

        final qiblahDirection = snapshot.data;
        print('direction : ${_degToRad(qiblahDirection.direction ?? 0)}');
        print('qiblla : ${_degToRad(qiblahDirection.qiblah ?? 0)}');

        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Transform.rotate(
              angle: _degToRad(qiblahDirection.direction ?? 0),
              child: _compassSvg,
            ),
            Transform.rotate(
              angle: _degToRad(qiblahDirection.qiblah ?? 0),
              alignment: Alignment.center,
              child: _needleSvg,
            ),
            Positioned(
              bottom: 8,
              child: Text("${qiblahDirection.offset.toStringAsFixed(3)}°"),
            )
          ],
        );
      },
    );
  }
}
