// @dart=2.9
import 'package:bts_wallpapers/models/imagesModel.dart';
import 'package:bts_wallpapers/navPages/singleWallpaperPage.dart';
import 'package:bts_wallpapers/utility/firebase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../adHelper.dart';

class ListWallpapersPage extends StatefulWidget {
  final catName;

  ListWallpapersPage({this.catName});

  @override
  State<StatefulWidget> createState() {
    return _ListWallpapersPage();
  }
}

class _ListWallpapersPage extends State<ListWallpapersPage> {
  //Admob
  BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.catName,),
        ),
      body: Stack(children: [
        FutureBuilder(
      future: getCatImageList(widget.catName),
      builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.done){         
          List<ImageModel> images = snapshot.data;
          return GridView.builder(
            itemCount: images.length,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2), 
            itemBuilder: (BuildContext context,int index){
              return Single_img(
                    id : images[index].id,
                    image:images[index].url,
                    isfav: images[index].isfav,
                );
            }
            );
        }else{
          return Center(child: CircularProgressIndicator());
        }
      }),
        Positioned(
          child: _isBannerAdReady?Container(
            width: _bannerAd.size.width.toDouble(),
            height: _bannerAd.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd),
          ):Container(),
          bottom: 0,
        )
      ],)
    );
  }
}

// ignore: must_be_immutable
class Single_img extends StatefulWidget {
  final image;
  final id;
  bool isfav;

  Single_img({this.id,this.image,this.isfav});


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
                Navigator.of(context).push(new MaterialPageRoute(
                  builder: (context) => new SingleWallpaperPage(
                    id:widget.id,image: widget.image,isfav: widget.isfav,parentFunction: updateImagesList,key: _key,)
              ),
            );
            },
            child: Hero(
              tag: widget.id,
              child: CachedNetworkImage(
                placeholder: (context,val)=>Center(child: CupertinoActivityIndicator()),
                imageUrl:widget.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void updateImagesList(ImageModel model,bool isfav){
    setState(() {
      widget.isfav = isfav;
    });

  }

}




