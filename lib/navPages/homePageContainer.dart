// @dart=2.9

import 'package:bts_wallpapers/adHelper.dart';
import 'package:bts_wallpapers/models/imagesModel.dart';
import 'package:bts_wallpapers/navPages/singleWallpaperPage.dart';
import 'package:bts_wallpapers/utility/firebase.dart';
import 'package:bts_wallpapers/utility/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomePageContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageContainer();
  }
}

class _HomePageContainer extends State<HomePageContainer> {
  ScrollController _scrollController = ScrollController();
  int _currentMaxItems = 16;
  bool _isLoaded = false;

  //Admob
  BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(images.isEmpty){
      getImagesFromFirebase().then((value) {
        setState(() {
          images = value;
          _isLoaded = true;
        });
      });
    }else{
      _isLoaded=true;
    }

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
    _bannerAd.dispose();
    super.dispose();
  }

  void _getMoreData()async{
    _currentMaxItems= _currentMaxItems+8;
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _isLoaded?GridView.builder(
          controller: _scrollController,
          itemCount: _currentMaxItems,
          gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemBuilder: (BuildContext context, int index) {
              if(index==_currentMaxItems-1){
                return CupertinoActivityIndicator();
              }
              return Single_img(
                id: images[index].id,
                image: images[index].url,
                isfav: images[index].isfav,
              );
          }):Center(child: CircularProgressIndicator()),

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

// ignore: camel_case_types, must_be_immutable
class Single_img extends StatefulWidget {
  final image;
  final id;
  bool isfav;

  Single_img({this.id, this.image, this.isfav});

  @override
  State<StatefulWidget> createState() {
    return _Single_img();
  }
}

// ignore: camel_case_types
class _Single_img extends State<Single_img> {
  final GlobalKey<SingleWallpaperPageState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        child: Material(
          child: InkWell(
            onTap: () {
                Navigator.of(context).push(
                  new MaterialPageRoute(
                      builder: (context) => new SingleWallpaperPage(
                            id: widget.id,
                            image: widget.image,
                            isfav: widget.isfav,
                            key:_key,
                            parentFunction: updateImagesList,
                          )),
                );
            },
            child: Hero(
                tag: widget.id,
                child: CachedNetworkImage(
                  placeholder: (context,val)=>Center(child: CupertinoActivityIndicator()),
                  imageUrl: widget.image,
                  fit: BoxFit.cover,

              ),
            ),
          ),
        ),
      ),
    );
  }

  void updateImagesList(ImageModel model,bool isfav){
    int index = images.indexWhere((element) => element.id==model.id);
    setState(() {
      images[index].isfav = isfav;
      widget.isfav = isfav;
    });

  }

}
