import 'dart:io';

import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:bts_wallpapers/navPages/privacyPolicyPage.dart';
import 'package:bts_wallpapers/utility/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../adHelper.dart';

class SettingPageContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingPageContainer();
  }
}

class _SettingPageContainer extends State<SettingPageContainer>{

  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;
  String _result = "";

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.palette,),
          title: const Text("Dark Mode",),
          trailing: Switch(value: themeProvider.isDarkMode,
            onChanged:(bool value){
              final provider = Provider.of<ThemeProvider>(context,listen: false);
              setState((){
                setDrawarBackGroundColor(value);
                provider.toggleTheme(value);             
              });
              }
            ,),
        ),
        Divider(color: Colors.grey[600],indent: 10,endIndent: 10,height: 10,),
        ListTile(
          leading: const Icon(Icons.priority_high),
          title: const Text("Privacy Policy",),
          onTap: (){
            Navigator.of(context).push(new MaterialPageRoute(
                  builder: (context) => new PrivacyPolicyPage()
              ),);
        },),
        Divider(color: Colors.grey[600],indent: 10,endIndent: 10,height: 10),
        ListTile(
          leading: const Icon(Icons.assistant_photo),
          title: const Text("Disclaimer",),
          onTap: ()=>showDialog(context: context,builder: (BuildContext context)=> Disclaimer()),
        ),
      ],
    );
  }

  void setDrawarBackGroundColor(bool isOn){
    if(isOn){
      globaleSelectedItembackgroundColor = Colors.grey.shade900;
    }else{
      globaleSelectedItembackgroundColor = Colors.grey.shade300;
    }
     
  }
}

//Disclaimer
class Disclaimer extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Disclaimer();
  }

}

class _Disclaimer extends State<Disclaimer>{

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        color: Colors.grey[900],
        height: MediaQuery.of(context).size.height*0.46,
        child: Column(children: [
          Container(
            padding: EdgeInsets.only(bottom:20,top: 20),
            child: const Text("Disclaimer",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.normal ,fontSize: 22,fontStyle: FontStyle.normal,color:Colors.white),),
            ),
            Expanded(
              child:  Container(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                color: Colors.white,
                child: SingleChildScrollView(
                  child: const Text("This application is made by fans, and it is unoffical. The content in this app is not affiliated with, endorsed,"
                      "sponsored, or specifically approved by any company. This app is mainly for entertainment and for all fans to enjoy these "
                      "wallpapers. if we have violated any copyright by use of any images included in this app, please contact us at redzoneapps7@gmail.com. Thank you!",
                    textDirection: TextDirection.ltr,textAlign: TextAlign.center,                   
                    style: TextStyle(fontSize: 18,color: Colors.black),),
                ),
              ),
            ),
          
        ],),
      )
    );
  }

}

