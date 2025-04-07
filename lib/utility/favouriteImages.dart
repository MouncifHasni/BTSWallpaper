// @dart=2.9

import 'package:bts_wallpapers/models/imagesModel.dart';
import 'package:bts_wallpapers/utility/utility.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase.dart';

class FavouriteImages{
  final dbref = FirebaseSingleton.instance.database;
  static dynamic favList;

  void setFav(String imgId,String url){
      dbref.child('users').child(globaleUserID).child(imgId).set({
        'url': url
      });
  }
  Future<List<ImageModel>> getFavs()async{
    Map<dynamic,dynamic> items = new Map();
    List<ImageModel> listfav = [];
    await dbref.child('users').child(globaleUserID).once().then((DataSnapshot snapshot) {
      if(snapshot.value!=null){
        items = snapshot.value;
      items.forEach((key, value) {
        ImageModel model = new ImageModel(id: key,url: value['url'],isfav:true);
        listfav.add(model);
      });
      }      
    });
    return listfav;
  }
  void removeFav(String imgId){
    dbref.child('users').child(globaleUserID).child(imgId).remove();
  }
}