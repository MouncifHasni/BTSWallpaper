// @dart=2.9
import 'dart:io';

import 'package:bts_wallpapers/adHelper.dart';
import 'package:bts_wallpapers/navPages/liveWallpapersPageContainer.dart';
import 'package:bts_wallpapers/utility/utility.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';
import 'navPages/categoriesPageContainer.dart';
import 'navPages/favouritesPageContainer.dart';
import 'navPages/homePageContainer.dart';
import 'navPages/noInternetPage.dart';
import 'navPages/settingPageContainer.dart';
import 'utility/theme.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        final themeProvider = Provider.of<ThemeProvider>(context).themeMode;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashScreenPage(),
          title: "BTS Wallpapers HD",
          darkTheme: ThemeData.dark(),
          theme: ThemeData.light(),
          themeMode: themeProvider,
        );
      },
    );
  }
}

class SplashScreenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplashScreenPage();
  }
}

class _SplashScreenPage extends State<SplashScreenPage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _isConnected = true;

  // ignore: missing_return
  Future<String> _setUserID() async {
    final SharedPreferences prefs = await _prefs;
    final String myID = generateRandomString(8);

    setState(() {
      prefs.setString("ID", myID).then((bool success) {
        globaleUserID = myID;
        //FavouriteImages().getFavs();
        return myID;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      if (prefs.getString('ID') == null) {
        _setUserID();
      } else {
        globaleUserID = prefs.getString('ID');
      }
    });

    checkConnection().then((value) {
      setState(() {
        _isConnected = value;
      });
    } );
    //globaleinterstitialAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 5,
      backgroundColor: Colors.grey[900],
      image: Image.asset('assets/logo.png'),
      loaderColor: Colors.white,
      photoSize: 200,
      navigateAfterSeconds: _isConnected?HomePage():InternetProblemPage(),
    );
  }

}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady = false;
  final List<Widget> navlist = [
    HomePageContainer(),
    CategoriesPageContainer(),
    FavouritesPageContainer(),
    SettingPageContainer(),
    LiveWallpapersPageContainer()
  ];


  @override
  void initState() {
    // TODO: implement initState
    _loadInterstitialAd();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BTS Wallpapers HD',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
        ),
      ),
      body: navlist[index],
      drawer: SafeArea(
        child: MyDrawer(
            onTap: (ctx, i) {
              Navigator.pop(ctx);
              Future.delayed(const Duration(milliseconds: 300), () {
                setState(() {
                  index = i;
                  if(_isInterstitialAdReady && (index == 2 || index == 1 || index == 4) ) _showInterstitialAd();
                });
              });
            },
            index: index),
      ),
    );
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

}

class MyDrawer extends StatefulWidget {
  final Function onTap;
  final int index;
  MyDrawer({this.onTap, this.index});

  @override
  State<StatefulWidget> createState() {
    return _MyDrawer();
  }
}

class _MyDrawer extends State<MyDrawer> {

  final RateMyApp rateMyapp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 0,
    minLaunches: 2,
    remindDays: 2,
    remindLaunches: 5,
    googlePlayIdentifier: 'com.redzone.btswallpapers',
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Drawer(
        child: new Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                          'assets/logo.png',
                        ),
                        scale: 8)),
                child: null,
              ),
              Container(
                color: widget.index == 0
                    ? globaleSelectedItembackgroundColor
                    : Colors.transparent,
                child: InkWell(
                  onTap: () => widget.onTap(context, 0),
                  child: const ListTile(
                    title: Text(
                      'Home',
                    ),
                    leading: Icon(
                      Icons.home,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
              Container(
                color: widget.index == 1
                    ? globaleSelectedItembackgroundColor
                    : Colors.transparent,
                child: InkWell(
                  onTap: () {
                    widget.onTap(context, 1);
                  } ,
                  child: const ListTile(
                    title: Text(
                      'Categories',
                    ),
                    leading: Icon(
                      Icons.widgets,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
              Container(
                color: widget.index == 2
                    ? globaleSelectedItembackgroundColor
                    : Colors.transparent,
                child: InkWell(
                  onTap: () {
                    widget.onTap(context, 2);

                  } ,
                  child: const ListTile(
                    title: Text(
                      'Favourites',
                    ),
                    leading: Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              Container(
                color: widget.index == 4
                    ? globaleSelectedItembackgroundColor
                    : Colors.transparent,
                child: InkWell(
                  onTap: () async{
                    widget.onTap(context, 4);

                  } ,
                  child: const ListTile(
                    title: Text(
                      'Live Wallpapers',
                    ),
                    leading: Icon(
                      Icons.movie_filter_outlined,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),
              Container(
                color: widget.index == 3
                    ? globaleSelectedItembackgroundColor
                    : Colors.transparent,
                child: InkWell(
                  onTap: () => widget.onTap(context, 3),
                  child: const ListTile(
                    title: Text(
                      'Settings',
                    ),
                    leading: Icon(
                      Icons.settings,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ),
              const Divider(
                color: Colors.grey,
              ),
              const ListTile(
                title: Text(
                  'Feedback',
                ),
              ),
              InkWell(
                onTap: () {
                  rateMyapp.init().then((value) {
                    rateMyapp.showStarRateDialog(
                      context,
                      title: 'Rate this app', // The dialog title.
                      message: 'Take a little bit of your time to leave a rating', // The dialog message.
                      // contentBuilder: (context, defaultContent) => content, // This one allows you to change the default dialog content.
                      actionsBuilder: (context, stars) { // Triggered when the user updates the star rating.
                        return [ // Return a list of actions (that will be shown at the bottom of the dialog).
                          TextButton(
                            child: Text('OK',style: TextStyle(color: Colors.blue),),
                            onPressed: () async {
                              final launchPlayStore = stars>=1;
                              if(launchPlayStore) rateMyapp.launchStore();

                              Navigator.pop<RateMyAppDialogButton>(context, RateMyAppDialogButton.rate);
                            },
                          ),
                          RateMyAppNoButton(
                            rateMyapp,
                            text: "CANCEL",
                          ),
                        ];
                      },
                      ignoreNativeDialog: Platform.isAndroid, // Set to false if you want to show the Apple's native app rating dialog on iOS or Google's native app rating dialog (depends on the current Platform).
                      dialogStyle: const DialogStyle( // Custom dialog styles.
                        titleAlign: TextAlign.center,
                        messageAlign: TextAlign.center,
                        messagePadding: const EdgeInsets.only(bottom: 20),
                      ),
                      starRatingOptions: const StarRatingOptions(initialRating: 4), // Custom star bar rating options.
                      onDismissed: () => rateMyapp.callEvent(RateMyAppEventType.laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
                    );
                  });
                },
                child: const ListTile(
                  title: Text(
                    'Rate us',
                  ),
                  leading: Icon(
                    Icons.star,
                    color: Colors.yellow,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Share.share(
                      'Check out this awesome BTS Wallpapers app https://play.google.com/store/apps/details?id=com.redzone.btswallpapers',
                      subject: 'Check out this awesome BTS Wallpapers app');
                },
                child: const ListTile(
                  title: Text(
                    'Share',
                  ),
                  leading: Icon(
                    Icons.share,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
