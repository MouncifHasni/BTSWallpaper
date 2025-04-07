// @dart=2.9

import 'package:bts_wallpapers/models/categoriesModel.dart';
import 'package:bts_wallpapers/utility/firebase.dart';
import 'package:bts_wallpapers/utility/utility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'listWallpapersPage.dart';

class CategoriesPageContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CategoriesPageContainer();
  }
}

class _CategoriesPageContainer extends State<CategoriesPageContainer> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getListCategories(),
      builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.done){
          List<CategoryModel> catList = snapshot.data;
          return GridView.builder(
            itemCount: catList.length,
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
             itemBuilder: (BuildContext context,int index){
               return Single_img(
                    name : catList[index].name,
                    image:catList[index].image,
                );
             }
            );
        }else{
          return Center(child: CircularProgressIndicator());
        }
      });
  }
}

// ignore: camel_case_types
class Single_img extends StatefulWidget {
  final name;
  final image;

  Single_img({this.name,this.image});


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
            onTap: () { Navigator.of(context).push(
              new MaterialPageRoute(
                  builder: (context) => new ListWallpapersPage(catName: widget.name,)
              ),
            );},
            child: GridTile(
              child: CachedNetworkImage(
                placeholder: (context,val)=>Center(child: CupertinoActivityIndicator()),
                imageUrl:widget.image,
                fit: BoxFit.cover,
              ),
              footer: Container(
                padding: const EdgeInsets.only(top: 5,bottom: 5),
                color: Colors.grey[800],
                child: Center(child: Text(widget.name,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 19),)),
                ),
            ),
          ),
        ),
      ),
    );
  }
}




