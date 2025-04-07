import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyPage extends StatefulWidget{
  
  @override
  State<StatefulWidget> createState() {
    return _PrivacyPolicyPage();
  }

}

class _PrivacyPolicyPage extends State<PrivacyPolicyPage>{
  bool _isloading = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy"),),
      body: Stack(
        children: [
          Container(
        child: WebView(initialUrl: 'https://redzoneapps.blogspot.com/2021/06/bts-wallpapers-2021.html',onProgress: (val){
        },onPageFinished: (val){
          setState(() {
            _isloading = false;
          });
        },),),
        _isloading? Center(child: CircularProgressIndicator(),):Text('')
        ],
      ),
        
    );
  }

}