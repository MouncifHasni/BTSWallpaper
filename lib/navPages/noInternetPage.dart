
import 'package:flutter/material.dart';

class InternetProblemPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/no_internet.png'),
            Text("No Internet Connection!",style: TextStyle(color: Colors.white,fontSize: 20,decoration: TextDecoration.none))

          ],

      ),
    );
  }
  
  
}