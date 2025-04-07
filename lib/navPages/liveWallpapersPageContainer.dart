import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:bts_wallpapers/navPages/singleLiveWallpaperPage.dart';
import 'package:bts_wallpapers/utility/firebase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
import 'package:bts_wallpapers/utility/utility.dart';

import '../adHelper.dart';


class LiveWallpapersPageContainer extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LiveWallpapersPageContainer();
  }
}

class _LiveWallpapersPageContainer extends State<LiveWallpapersPageContainer>{
  bool _isLoaded = false;
  List<String> wallpapers = List.empty();
  ScrollController _scrollController = ScrollController();
  int _currentMaxItems = 6;

  //Admob
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLiveWallpapersList().then((value) {
      setState(() {
        wallpapers = value;
        _isLoaded = true;
      });
    });

    _scrollController.addListener(() {
      if(_scrollController.position.pixels>=_scrollController.position.maxScrollExtent){
        _getMoreData();
      }
    });
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd.load();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _bannerAd.dispose();
  }

  void _getMoreData()async{
    _currentMaxItems= _currentMaxItems+6;
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: [
        _isLoaded?
        GridView.builder(
            itemCount: wallpapers.length,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,childAspectRatio: 0.7),
            padding: EdgeInsets.all(0),
            itemBuilder: (ctx, index) => VideoItem(wallpapers[index]))
              /*if(index==_currentMaxItems-1){
                return CupertinoActivityIndicator();
              }*/
            :Center(child: CircularProgressIndicator()),
        Positioned(
          child: _isBannerAdReady?Container(
            width: _bannerAd.size.width.toDouble(),
            height: _bannerAd.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd),
          ):Container(),
          bottom: 0,
        )
      ],
    );
  }

}

class VideoItem extends StatefulWidget {
  final String url;

  VideoItem(this.url);
  @override
  _VideoItemState createState() => _VideoItemState();

}

class _VideoItemState extends State<VideoItem> {
  final GlobalKey<SingleLiveWallpaperPageState> _key = GlobalKey();
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.isInitialized ?SizedBox(
        width: double.infinity,
        child: Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          child: Material(
            child: InkWell(
              child: Hero(
                tag: widget.url,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),),
              ),
              onTap: (){
                Navigator.of(context).push(
                  new MaterialPageRoute(
                      builder: (context) => new SingleLiveWallpaperPage(
                        url: widget.url,
                        key:_key,
                      )),
                );
              },
            ),
          ),
        )
      ) : Center(child: CupertinoActivityIndicator()),
    );

  }

}