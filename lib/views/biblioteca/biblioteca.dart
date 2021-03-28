import 'dart:io';
import 'package:badges/badges.dart';
import 'package:epub_viewer/epub_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:kioxkenewf/models/offinedabase.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:kioxkenewf/views/biblioteca/pdfViewer.dart';
import 'package:kioxkenewf/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class Biblioteca extends StatefulWidget {
  @override
  _BibliotecaState createState() => _BibliotecaState();
}

class _BibliotecaState extends State<Biblioteca> {

    List<Map<String,dynamic>> queryRowsCard = new List<Map<String,dynamic>>();
      final TextEditingController _filter = new TextEditingController();

   @override
  void initState(){
    super.initState();
    loadLocalBook();
  }

  @override
  Widget build(BuildContext context) {
    // loadLocalBook();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: primaryColor,
       title: Text("Minha Biblioteca"),
       actions: [
         IconButton(icon: Icon(Feather.home), onPressed: () async{
             SharedPreferences prefs = await SharedPreferences.getInstance();
             Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) =>  HomeView(prefs.getString("nome").replaceAll('"', ""),prefs.getString("email").replaceAll('"', ""))),(Route<dynamic> route) => false);
         })
       ],
      ),
      body: queryRowsCard.length == 0? emptyWid():
       SingleChildScrollView(
         child:Column(
        crossAxisAlignment:CrossAxisAlignment.start ,
        children:[
           Padding(padding: EdgeInsets.all(10),
            child:TextField(
                controller:_filter,
                textInputAction: TextInputAction.go,
                onSubmitted: (value) {
                    print("search");
                },
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                ),
                cursorColor: primaryColor,
                decoration: InputDecoration(
                  prefixIcon: _filter.value.text.length > 0?IconButton(icon: Icon(Icons.close, color: primaryColor,), onPressed: (){
                    _filter.clear();
                    // _filter.dispose();
                  }):null,
                  alignLabelWithHint: false,
                  hintText: "O que Procura?",
                  hintStyle: TextStyle(
                    fontSize: 15
                  ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    // prefix: IconButton(icon: Icon(Icons.close_rounded, color: primaryColor,), onPressed: (){}),
                    suffixIcon: _filter.value.text.length > 0?IconButton(icon: Icon(Icons.dashboard_outlined, color: primaryColor,), onPressed: (){
             
                    }):null,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                        EdgeInsets.only(left: 15, bottom: 16, top: 11, right: 15),
                    ),
              )
              
              ),


       Container(
         padding: EdgeInsets.all(10),
          child:Text("A Ler",style: subtitle,),
       ),

        Container(
          height: 240,
          child:Container(
          // height:  MediaQuery.of(context).size.height,
          child: ListView.builder(
               scrollDirection: Axis.horizontal,
                itemCount: queryRowsCard.length,
                itemBuilder: (BuildContext context, int index) {
            return biblotecaitem((){
                openBookall(queryRowsCard[index]['bookLink']);
            },queryRowsCard[index]['nomeBook'],queryRowsCard[index]['imgLink']);
          
        }),
      )),


       Container(
         padding: EdgeInsets.all(10),
          child:Text("Lidos",style: subtitle,),
       ),

        Container(
          height: 240,
          child:Container(
          // height:  MediaQuery.of(context).size.height,
          child: ListView.builder(
               scrollDirection: Axis.horizontal,
                itemCount: queryRowsCard.length,
                itemBuilder: (BuildContext context, int index) {
            return biblotecaitem((){
                final xtension = p.extension(queryRowsCard[index]['bookLink']);

                if(xtension.toLowerCase().contains(("epub").toLowerCase()))
                  openBookall(queryRowsCard[index]['bookLink']);
                else if(xtension.toLowerCase().contains(("pdf").toLowerCase()))
                   Navigator.push(context,MaterialPageRoute(builder: (context) =>  OpenAnotherBook(pathUrl:queryRowsCard[index]['bookLink'],nameBook:queryRowsCard[index]['nomeBook'])));

            },queryRowsCard[index]['nomeBook'],queryRowsCard[index]['imgLink']);
          
        }),
      )),

        ]
      )
    ));
  }

  Widget emptyWid(){
    return Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
               width: MediaQuery.of(context).size.width,
               height: 210,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("images/bibliotec/Bib1.png"),fit: BoxFit.contain, colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dst),)
              ),
              child: GestureDetector(
                onTap:(){
                  print("tapped");
                }
              ),
              ),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width/2,
                    height: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage("images/bibliotec/Bib2.png"),fit: BoxFit.contain, colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dst),)
                    ),
                    child: GestureDetector(
                      onTap:(){
                       print("tapped");
                       }
                     ),
                  ),
                    Container(
                    width: MediaQuery.of(context).size.width/2,
                    height: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage("images/bibliotec/Bib3.png"),fit: BoxFit.contain, colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dst),)
                    ),
                    child: GestureDetector(
                      onTap:(){
                       print("tapped");
                       }
                     ),
                  ),

                ],
              )
            ],
        )
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
             child: TextButton(onPressed: (){
               openBookall(linkPath);
             },
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
                allowSharing: false,
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