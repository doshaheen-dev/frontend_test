import 'package:flutter/material.dart';
import 'package:acc/constants/theme_colors.dart';

class WavyHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BottomWaveClipper(),
      child: Container(
        height: 240.0,
        decoration: new BoxDecoration(
            //   shape: BoxShape.circle,
            gradient: new LinearGradient(
                colors: [
                  ThemeColor.greenColor,
                  ThemeColor.greenColor,
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.9, 0.0),
                stops: [0.0, 0.9],
                tileMode: TileMode.clamp)),
        //margin: const EdgeInsets.symmetric(horizontal: 8.0),
      ),
    );
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - 20);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    // path.quadraticBezierTo(firstEndPoint.dx, firstEndPoint.dy,firstControlPoint.dx, firstControlPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class AppBarTitle extends StatelessWidget {
  final String title;

  AppBarTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            height: 100.0,
            decoration: new BoxDecoration(
                //   shape: BoxShape.circle,
                gradient: new LinearGradient(
                    colors: [
                      ThemeColor.greenColor,
                      ThemeColor.greenColor,
                    ],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(0.9, 0.0),
                    stops: [0.0, 0.9],
                    tileMode: TileMode.clamp)),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 40.0,
              left: 10.0,
            ),
            child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  title,
                  style: TextStyle(
                      color: Color(0xFFFCFCFC),
                      fontSize: 30,
                      fontFamily: 'Poppin'),
                )),
          )
        ],
      ),
    );
  }
}
