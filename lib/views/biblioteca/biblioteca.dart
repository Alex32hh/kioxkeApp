import 'dart:io';
import 'package:badges/badges.dart';
import 'package:epub_viewer/epub_viewer.dart';
import 'package:flutter/material.dart';
import 'package:kioxkenewf/models/offinedabase.dart';
import 'package:kioxkenewf/models/viewStyles.dart';


class Biblioteca extends StatefulWidget {
  @override
  _BibliotecaState createState() => _BibliotecaState();
}

class _BibliotecaState extends State<Biblioteca> {

    List<Map<String,dynamic>> queryRowsCard = new List<Map<String,dynamic>>();
   @override
  void initState() {
    super.initState();
    loadLocalBook();
  }

  @override
  Widget build(BuildContext context) {
    loadLocalBook();
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: primaryColor,
       title: Text("Biblioteca Local"),
      ),
      body: Container(
        child: GridView.count(
        crossAxisCount: 2 ,
        children: List.generate(queryRowsCard.length,(index){
          return boxBook(queryRowsCard[index]['imgLink'],queryRowsCard[index]['bookLink']);
        }),
      ),
      ),
    );
  }

  Widget boxBook(String linkImg,String linkPath){
    return Padding(
        padding: EdgeInsets.all(10),
        child:Container(
        decoration: BoxDecoration(
          // color:Colors.red,
          image: DecorationImage(image: NetworkImage(linkImg),fit: BoxFit.cover),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Badge(
             alignment:Alignment.bottomLeft,
             position: BadgePosition.topEnd(),
             badgeColor:Colors.white,
             badgeContent: IconButton(
               padding:EdgeInsets.all(0),
               iconSize:24,
               icon: Icon(Icons.delete,color: Colors.red), onPressed:() async{

                  showAlertDialog(context,() async{
                     DatabaseHelperLocal.instance.deleteBook(linkPath);
                      setState(() {});
                        final file = File(linkPath);
                        if(await file.exists())
                        await file.delete();
                      setState(() {});
                  });

                }
               ),
             child: FlatButton(onPressed: (){
               openBookall(linkPath);
             },
             color:Colors.white, 
             child: Text("Ler")),
            )
      )
    );
    
  }


 loadLocalBook() async{
    queryRowsCard = await DatabaseHelperLocal.instance.queryAll();
    setState(() {
    });
 }

openBookall(String src) async{
    if (src.isNotEmpty) {
        EpubViewer.setConfig(
                identifier: 'androidBook',
                themeColor: Theme.of(context).accentColor,
                scrollDirection: EpubScrollDirection.HORIZONTAL,
                enableTts: false,
                allowSharing: true,
              );

            EpubViewer.open(
            src,lastLocation:EpubLocator.fromJson({
              "bookId": "2239",
              "href": "/OEBPS/ch06.xhtml",
              "created": 1539934158390,
              "locations": {
                "cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"
              }
            }), // first page will open up if the value is null
          );
    }

  }



}