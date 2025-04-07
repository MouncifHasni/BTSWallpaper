// @dart=2.9
import 'package:bts_wallpapers/models/imagesModel.dart';
import 'package:bts_wallpapers/navPages/singleWallpaperPage.dart';
import 'package:bts_wallpapers/utility/favouriteImages.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FavouritesPageContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FavouritesPageContainer();
  }
}

class _FavouritesPageContainer extends State<FavouritesPageContainer> {

  Future<Null> _refreshPage() async{
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshPage,
      child: FutureBuilder(
      future: FavouriteImages().getFavs(),
      builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          if(snapshot.data!=null&&snapshot.data.isNotEmpty){
            List<ImageModel> listfavs = snapshot.data;
            return GridView.builder(
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2), 
              itemCount: listfavs.length,
              itemBuilder: (BuildContext context,int index){
                return Single_img(
                    id : listfavs[index].id,
                    image:listfavs[index].url,
                    isfav: listfavs[index].isfav,
                );
              });
          }else{
            return Center(child: Text("No image in favourites!",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),);
          }
        }
        else{
          return Center(child: CircularProgressIndicator(),);
        }
      },
    ), 
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
                  builder: (context) => new SingleWallpaperPage(id:widget.id,image: widget.image,isfav: widget.isfav,)
              ),
            );

              },
            child: Hero(
              tag: widget.id,
              child: CachedNetworkImage(
                imageUrl:widget.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

}


