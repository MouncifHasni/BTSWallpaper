// @dart=2.9
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:bts_wallpapers/models/imagesModel.dart';
import 'package:bts_wallpapers/utility/favouriteImages.dart';
import 'package:bts_wallpapers/utility/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:share/share.dart';

import '../adHelper.dart';

// ignore: must_be_immutable
class SingleWallpaperPage extends StatefulWidget {
  final image;
  final id;
  final bool isfav;
  final Function parentFunction;

  SingleWallpaperPage({this.id, this.image, this.isfav,this.parentFunction,Key key}):super(key:key);

  @override
  State<StatefulWidget> createState() {
    return SingleWallpaperPageState();
  }
}

class SingleWallpaperPageState extends State<SingleWallpaperPage>
    with SingleTickerProviderStateMixin {
  bool _isvisible = true;
  bool _isfavourite = false;

  //Admob
  InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadInterstitialAd();
    _isfavourite = widget.isfav;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _interstitialAd?.dispose();
    super.dispose();
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
    return Stack(
        children: [
          Hero(
            tag: widget.id,
            child: CachedNetworkImage(
              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
              imageUrl: widget.image,
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    icon: Icon(_isfavourite?Icons.favorite:Icons.favorite_border,size: 26,color: Colors.redAccent,),
                    onPressed: (){
                      bool _isLiked = _isfavourite;
                      setState(() {
                        _isvisible = false;
                        _isfavourite=!_isLiked;
                      });
                      _onLikeButtonTapped(
                          _isLiked, widget.id, widget.image);
                    },
                  ),
                )
              ],
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
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[800],
                            child: IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) =>
                                      Container(
                                            color: Colors.grey[800],
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.add_to_home_screen,
                                                    color: Colors.white,
                                                  ),
                                                  title: const Text(
                                                    "Home Screen",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontStyle: FontStyle.italic,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                    _setWallpaperImage(
                                                        AsyncWallpaper.HOME_SCREEN,
                                                        widget.image);
                                                  },
                                                ),
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.screen_lock_portrait,
                                                    color: Colors.white,
                                                  ),
                                                  title: const Text("Lock Screen",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontStyle: FontStyle.italic,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                    _setWallpaperImage(
                                                        AsyncWallpaper.LOCK_SCREEN,
                                                        widget.image);
                                                  },
                                                ),
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.phone_android,
                                                    color: Colors.white,
                                                  ),
                                                  title: const Text(
                                                      "Home & Lock Screens",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontStyle: FontStyle.italic,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                    setState(() {
                                                      _isvisible = false;
                                                    });
                                                    _setWallpaperImage(
                                                        AsyncWallpaper.BOTH_SCREENS,
                                                        widget.image);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                    );
                              },
                              icon: const Icon(
                                Icons.format_paint,
                                color: Colors.white,
                                size: 25,
                              ),

                            ),
                          ),
                          CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey[800],
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isvisible = false;
                                    });
                                    _downloadImage(widget.image);
                                  },
                                  icon: const Icon(Icons.file_download,
                                      color: Colors.white, size: 25))),
                          CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey[800],
                              child: IconButton(
                                  onPressed: () {
                                    _shareImage(widget.image);
                                  },
                                  icon: const Icon(Icons.share,
                                      color: Colors.white, size: 25)))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      )
    ;
  }

  void _onLikeButtonTapped(bool isLiked, id, image) async {
    /// send your request here
    bool fav_added = false;

    if (isLiked) {
      FavouriteImages().removeFav(id);
    } else {
      FavouriteImages().setFav(id, image);
      fav_added = true;
    }

    showModalBottomSheet(
      isDismissible: false,
      context: context,
      builder: (context) => Container(
        color: Colors.grey[800],
        child:  ListTile(
          title: Text(
            fav_added?'Saved to favourites successfully':"Removed from favourites successfully",
            style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.normal),
          ),
        ),
      ),
    );
    ImageModel model = new ImageModel(id: widget.id,url: widget.image,isfav: widget.isfav);
    if(widget.parentFunction!=null) widget.parentFunction(model,!isLiked);

    await Future.delayed(Duration(seconds: 1))
        .then((value) => Navigator.of(context).pop());

    //if(await globaleinterstitialAd.isLoaded)globaleinterstitialAd.show();

    setState(() {
      _isvisible = true;
    });
  }



  //set Wallpaper
  void _setWallpaperImage(int state, String image) async {
    var cachedImage = await DefaultCacheManager().getSingleFile(image);
    if (cachedImage != null){
      var croppedImage = await ImageCropper().cropImage(
          sourcePath: cachedImage.path,
          aspectRatio: CropAspectRatio(
              ratioX: MediaQuery.of(context).size.width,
              ratioY: MediaQuery.of(context).size.height),
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: "Crop Image",
          ));
      var result;
      if (croppedImage != null) {
        result =
            AsyncWallpaper.setWallpaperFromFile(croppedImage.path, state);
      }

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
            'Wallpaper set!',
          ),
          duration: Duration(seconds: 2),
        ));
        if(_isInterstitialAdReady)_showInterstitialAd();
      }
    }

    setState(() {
      _isvisible = true;
    });

  }

  //Download image and store it on your phone
  void _downloadImage(String image) async {
    var permission = await Permission.storage.request();
    if (permission.isGranted) {
      ProgressDialog progress = ProgressDialog(context,
          type: ProgressDialogType.Normal, showLogs: false);
      progress.style(message: "Downloading image...");
      progress.show();

      String imgID = generateRandomString(8);
      var imageId = await ImageDownloader.downloadImage(image,
          destination: AndroidDestinationType.directoryDownloads
            ..inExternalFilesDir()
            ..subDirectory(imgID + ".jpg"));
      await progress.hide();
      if (imageId != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Download completed'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () async {
              var path = await ImageDownloader.findPath(imageId);
              await ImageDownloader.open(path);
            },
          ),
        ));
      }
      //if(await globaleinterstitialAd.isLoaded)globaleinterstitialAd.show();
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text('Need access to storage'),
                actions: [
                  TextButton(
                      onPressed: () {
                        openAppSettings();
                      },
                      child: const Text('Open Settings')),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'))
                ],
              ));
    }
    setState(() {
      _isvisible = true;
    });
  }

  //Share image
  void _shareImage(image) async {
    ProgressDialog progress = ProgressDialog(context,
        type: ProgressDialogType.Normal, showLogs: false);
    progress.style(message: "Sharing image...");
    progress.show();
    String imgID = generateRandomString(8);
    var imageId = await ImageDownloader.downloadImage(image,
        destination: AndroidDestinationType.directoryDownloads
          ..inExternalFilesDir()
          ..subDirectory(imgID + ".jpg"));
    await progress.hide();
    if (imageId != null) {
      var path = await ImageDownloader.findPath(imageId);
      Share.shareFiles([path], text: "");
    }
  }
}
