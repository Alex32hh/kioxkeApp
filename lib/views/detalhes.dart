
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:epub_viewer/epub_viewer.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:kioxkenewf/components/download_alert.dart';
import 'package:kioxkenewf/models/database.dart';
import 'package:kioxkenewf/models/functions.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:kioxkenewf/util/const.dart';
import 'package:kioxkenewf/views/pagamento.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Datalhes extends StatefulWidget {
  @override
  _DatalhesState createState() => _DatalhesState();
   
   final String url,titulo,capa,autor,like,preco,descricao,id;
   final int isFavorite;
   final Function closeF;

   Datalhes(this.closeF,this.url,this.titulo,this.capa,this.autor,this.like,this.preco,this.descricao,this.id,{this.isFavorite});
}

class _DatalhesState extends State<Datalhes> {

   bool downloading = false;
   bool idDownloaded = false;
   double progressInt = 0;
   bool isonCard = false;
   int favorite;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<String> _path;
  Future<bool> _favorite,_isonCard;

  String fileSystem ="";
  String precoProd = "";

    int favactive;

   @override
  void initState() {
    super.initState();
  
    updateview(int.parse(widget.id));
    getFavorite();
    checkDownload(widget.id+"book");
    getCart(widget.titulo+'_carrinho');
    FlutterMoneyFormatter precoProduto = FlutterMoneyFormatter(amount: double.parse(widget.preco));
    precoProd = precoProduto.output.nonSymbol;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: SingleChildScrollView( child:Column(
         mainAxisSize: MainAxisSize.max,
         children: [
    Padding(padding: EdgeInsets.all(0), 
      child:CachedNetworkImage(
      imageUrl: widget.capa,
      imageBuilder: (context, imageProvider) => 
    Container(
      padding: EdgeInsets.only(left: 10,right: 10),
      width: MediaQuery.of(context).size.width,
      height: 300,
       decoration: BoxDecoration(
         image: DecorationImage(image: AssetImage("images/bgBook.jpg"),fit: BoxFit.fill, colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.dst),)
       ),
      child: Column(
      children: [
      Container(
        width: MediaQuery.of(context).size.width,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children:[
            CircleAvatar(
                backgroundColor:Color(0xFF0E3311).withOpacity(0.5),
              child: IconButton(
              padding:EdgeInsets.all(8.0),
              color: Colors.white,
              icon: Icon(Icons.close_rounded), onPressed: widget.closeF)),

          Container(
              child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:[
                   CircleAvatar(
               backgroundColor:Color(0xFF0E3311).withOpacity(0.5),
              child: IconButton(
              padding:EdgeInsets.all(8.0),
              color: Colors.white,
              icon:favactive==0?Icon(Icons.favorite,color: Colors.red):Icon(Icons.favorite), onPressed: () => setfavorite(),)),
                   SizedBox(width: 5,),
                   CircleAvatar(
                    backgroundColor:Color(0xFF0E3311).withOpacity(0.5),
                    child:  !idDownloaded?IconButton(icon:!isonCard?Icon(Icons.add_shopping_cart, size: 25,color: Colors.white,):Icon(Feather.shopping_bag,color: primaryColor, size: 25), onPressed: () =>setCarrinho()):
                     IconButton(icon: Icon(Feather.share_2), onPressed: () => {})
                  )
                   ])

            )
           
           
          ]
        ),
      ),
      Row(children: [
        Container(
          width: 130,
          height: 180,
         decoration: BoxDecoration(
           borderRadius:BorderRadius.all(Radius.circular(10)),
           image: DecorationImage(image: imageProvider,fit: BoxFit.cover,),
        ),
        ),
        
        Expanded(
          child:Container(
          width: 200,
          height: 210,
          padding:EdgeInsets.all(10),
          child:Column(
            children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child:RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        style:subtitle,
                        text: widget.titulo),
                  ),
                ),

                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top:5,bottom:5),
                  child:RichText(
                    overflow: TextOverflow.fade,
                    text: TextSpan(
                        style: TextStyle(fontSize:15,color: primaryColor),
                        text: "by "+widget.autor),
                  ),
                ),

               Container(
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.centerLeft,
                  child: Text( ( int.parse(widget.preco) <= 0?"Gratuito":precoProd+" AOA"),
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)
                ),
             
                 Column(
                   children: [
                  Container(
                   width: double.infinity,
                   child:isonCard?FlatButton(
                   padding: EdgeInsets.zero,
                   color: Colors.red,
                   onPressed: () async{
                   
                    setCarrinho();
                     widget.closeF();
                    // showConfirm(context,"Confirmação","Item Removido do carrinho com sucesso");
                   },
                   child:Text("Remover do Carrinho",style: TextStyle(color:Colors.white),)
                  ):
                  idDownloaded==false?
                  FlatButton(
                   padding: EdgeInsets.zero,
                   color:primaryColor,
                   onPressed: () async{
                     PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
                    if (permission != PermissionStatus.granted) {
                      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
                        // startDownload(context,widget.url,widget.id+"book");
                          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => Pay(widget.url,widget.id+"book",widget.id,widget.capa,widget.preco,widget.titulo,widget.descricao)));
                    } else {
                        // startDownload(context,widget.url,widget.id+"book");
                          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => Pay(widget.url,widget.id+"book",widget.id,widget.capa,widget.preco,widget.titulo,widget.descricao)));
                    }
                      //  widget.closeF();
                   },
                   child:Text("Comprar",style: TextStyle(color:Colors.white),)
                  ):
                   FlatButton(
                   padding: EdgeInsets.zero,
                   color: Colors.green,
                   onPressed: () async{

                      final SharedPreferences prefs = await _prefs;
                      PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
                    if (permission != PermissionStatus.granted) {
                      await PermissionHandler().requestPermissions([PermissionGroup.storage]);
                      openBook(prefs.getString(widget.id+"book"));
                    } else {
                      openBook(prefs.getString(widget.id+"book"));
                    }
                      
                   },
                   child:Text("Abrir",style: TextStyle(color:Colors.white),)
                  )
                )
               
                   ],
                 )

            ],
          ),
        )

        )
      ],
    )]),
  ),
  placeholder: (context, url) => shimerEfect(context),
    errorWidget: (context, url, error) => Icon(Icons.error),
   )
  ),
  pageTitle("Descrição",context),
     Container(
        padding: EdgeInsets.all(10),
        alignment: Alignment.center,
         child:RichText(
            overflow: TextOverflow.fade,
            text: TextSpan(
            style: TextStyle(fontSize:15, color: Colors.black),
                text: widget.descricao),
          ),
        ),
    pageTitle("Comentários",context),
    cardComments(),
    cardComments(),
    cardComments(),
    cardComments(),
  
    ]),

  ));

  }

  startDownload(BuildContext context, String url, String filename) async {
    Directory appDocDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();

    if (Platform.isAndroid) {
      Directory(appDocDir.path.split('Android')[0] + '${Constants.appName}').createSync();
    }

    String path = Platform.isIOS
        ? appDocDir.path + '/$filename.epub'
        : appDocDir.path.split('Android')[0] +
            '${Constants.appName}/$filename.epub';

    print(path);
    File file = File(path);
    if (!await file.exists()) {
      await file.create();
       
       idDownloaded = true;

    } else {
      await file.delete();
      await file.create();

       idDownloaded = true;
       
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => DownloadAlert(
        url: url,
        path: path,
      ),
    ).then((v) async {

     final SharedPreferences prefs = await _prefs;
     final String pathaved = path;
     fileSystem =  path;
      if (v != null) {
        idDownloaded = true;
        setState(() {
       _path = prefs.setString(filename, pathaved).then((bool success) {
        return pathaved;
        });
      });
     }
    });
  }

  checkDownload(String filename) async {
     final SharedPreferences prefs = await _prefs;
     if(prefs.getString(filename) != null)
    if (prefs.getString(filename).isNotEmpty) {
      // check if book has been deleted
      String path = prefs.getString(filename);
      print(path);
      if(await File(path).exists()){
         idDownloaded = true;
      }else{
          idDownloaded = false;
      }
    } else {
        idDownloaded = false;
     }
   }


  void setfavorite() async{
  final SharedPreferences prefs = await _prefs;
      setState(() {
          favorite = prefs.getInt(widget.titulo+"save")==1?0:1;
          prefs.setInt(widget.titulo+"save", favorite);
       });

       if(prefs.getInt(widget.titulo+"save") == 1)
           saveList(widget.id,widget.titulo,widget.descricao,widget.preco,widget.capa,widget.url,"desejos","desejos",0);
       else
           int value = await DatabaseHelper.instance.deleteBook(widget.titulo);

       getFavorite();
  }


  void setCarrinho() async{
  final SharedPreferences prefs = await _prefs;

       saveList(widget.id,widget.titulo,widget.descricao,widget.preco,widget.capa,widget.url,"carrinho","carrinho",1);
       
       isonCard =  !isonCard;

       if(!isonCard){
         int value = await DatabaseHelper.instance.deleteBook(widget.titulo);
         cardDeliteItems(widget.id);
       }

        _isonCard = prefs.setBool(widget.titulo+'_carrinho', isonCard).then((bool success) {
        return isonCard;
       
        });
   setState(() {  });
  }


  void getCart(String nomeBook) async{
     final SharedPreferences prefs = await _prefs;
    setState(() {
       isonCard = prefs.getBool(nomeBook)==null?false: prefs.getBool(nomeBook);
    });
  }

  void getFavorite() async{
      final SharedPreferences prefs = await _prefs;
      setState(() {
        favorite = prefs.getInt(widget.titulo+"save")==1?0:1;
        favactive = favorite;
      });
  }

  
  openBook(String src) async{
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