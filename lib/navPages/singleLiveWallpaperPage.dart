// @dart=2.9
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:video_player/video_player.dart';

import '../adHelper.dart';

class SingleLiveWallpaperPage extends StatefulWidget{
  final url;

  SingleLiveWallpaperPage({this.url,Key key}):super(key:key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SingleLiveWallpaperPageState();
  }

}

class SingleLiveWallpaperPageState extends State<SingleLiveWallpaperPage>{
  bool _isvisible = true;
  VideoPlayerController _videoController;
  //Admob
  InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _videoController = VideoPlayerController.network(widget.url)
    ..initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      _videoController.setLooping(true);
      _videoController.play();
      setState(() {});
    });
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _videoController.dispose();
    _interstitialAd?.dispose();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          this._interstitialAd = ad;
          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _loadInterstitialAd();
      },
    );
    _interstitialAd.show();
    _interstitialAd = null;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: [
        Hero(
          tag: widget.url,
          child: Center(
            child : _videoController.value.isInitialized ? SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: VideoPlayer(_videoController),
            )
            :Center(child: CircularProgressIndicator()),
          ),
        ),
        /*CachedNetworkImage(
            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
            imageUrl: widget.image,
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
        ),*/
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
          ),
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Visibility(
              visible: _isvisible,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    border: Border.all(
                    ),
                    borderRadius: BorderRadius.only(topLeft: (Radius.circular(20)),topRight: (Radius.circular(20)))
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 5,top: 5),
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          height: 50.0,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
                            onPressed: () {
                              _setLiveWallpaper(widget.url);
                            },
                            child: const Text("Set Live Wallpaper",style: TextStyle(fontStyle: FontStyle.italic),),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<void> _setLiveWallpaper(String url) async {
    ProgressDialog progress = ProgressDialog(context,
        type: ProgressDialogType.Normal, showLogs: false);
    progress.style(message: "Setting Wallpaper...");
    progress.show();

    var file = await DefaultCacheManager().getSingleFile(url);
    String result = "";
    try {
      result = await AsyncWallpaper.setLiveWallpaper(
          file.path);

    } on PlatformException {
      print('Failed to get wallpaper.');
    }
    await progress.hide();
    Future.delayed(Duration(seconds: 15), () {
      if(_isInterstitialAdReady)_showInterstitialAd();
    });
  }

}