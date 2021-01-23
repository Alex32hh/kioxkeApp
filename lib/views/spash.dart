import 'package:flutter/material.dart';


class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: Colors.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset("images/logo.png",height: 150.0,width: 150.0,),
          ],
        ),
      ),
    );
  }
}