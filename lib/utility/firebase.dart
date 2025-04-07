// @dart=2.9

import 'package:bts_wallpapers/models/categoriesModel.dart';
import 'package:bts_wallpapers/models/imagesModel.dart';
import 'package:bts_wallpapers/utility/utility.dart';
import 'package:firebase_database/firebase_database.dart';


class FirebaseSingleton {
  static final FirebaseSingleton _dbSingleton = FirebaseSingleton._internal();
  static FirebaseSingleton get instance => _dbSingleton;
  static DatabaseReference _db;

  factory FirebaseSingleton() {
    return _dbSingleton;
  }
  FirebaseSingleton._internal();

  DatabaseReference get database {
    if (_db != null) return _db;
    _db = FirebaseDatabase.instance.reference();
    return _db;
  }
}

Future<List<ImageModel>> getImagesFromFirebase() async{
    List<ImageModel> urlList = [];
    final dbref = FirebaseSingleton.instance.database;
    Map<dynamic, dynamic> favitems = new Map();
    await dbref
        .child('users')
        .child(globaleUserID)
        .once()
        .then(( snapshot) {
      if (snapshot.value != null) {
        favitems = snapshot.value;
      }
    });

    await dbref.child("images").once().then(( data) {
      Map items = data.value;
      Map secondItems = new Map();
      items.forEach((key, value) {
        secondItems.addAll(value);
      });
      secondItems.forEach((key, value) {
        bool isfav = false;
        if (favitems.isNotEmpty) {
          if (favitems.containsKey(key)) isfav = true;
        }

        ImageModel model =
        new ImageModel(id: key, url: value['url'], isfav: isfav);
        urlList.add(model);
        isfav = false;
      });
    });

    urlList.shuffle();
    await Future.delayed(Duration(seconds: 2));
  return urlList;
}

Future<List<CategoryModel>> getListCategories() async {
  final dbref = FirebaseSingleton.instance.database;
  Map<dynamic, dynamic> items = new Map();
  List<CategoryModel> catList = [];
  await dbref.child('categories').once().then((DataSnapshot snapshot) {
    if (snapshot.value != null) {
      items = snapshot.value;
      items.forEach((key, value) {
        CategoryModel model =
            new CategoryModel(name: key, image: value['thumbnail']);
        catList.add(model);
      });
    }
  });
  return catList;
}

Future<List<ImageModel>> getCatImageList(String catName) async {
  final dbref = FirebaseSingleton.instance.database;
  Map<dynamic, dynamic> favitems = new Map();
  List<ImageModel> imagesList = [];

  await dbref
      .child('users')
      .child(globaleUserID)
      .once()
      .then((DataSnapshot snapshot) {
    if (snapshot.value != null) {
      favitems = snapshot.value;
    }
  });

  await dbref
      .child('images')
      .child(catName)
      .once()
      .then((DataSnapshot snapshot) {
    Map<dynamic, dynamic> items = new Map();
    if (snapshot.value != null) {
      items = snapshot.value;
      items.forEach((key, value) {
        bool isfav = false;
        if (favitems.isNotEmpty) {
          if (favitems.containsKey(key)) isfav = true;
        }
        ImageModel model =
            new ImageModel(id: key, url: value['url'], isfav: isfav);
        imagesList.add(model);
      });
    }
  });
  return imagesList;
}

Future<List<String>> getLiveWallpapersList() async {
  final dbref = FirebaseSingleton.instance.database;
  List<String> wallpapersList = [];

  await dbref
      .child('Live')
      .once()
      .then((DataSnapshot snapshot) {
    Map<dynamic, dynamic> items = new Map();
    if (snapshot.value != null) {
      items = snapshot.value;
      items.forEach((key, value) {
        wallpapersList.add(value['url']);
      });
    }
  });

  return wallpapersList;
}

