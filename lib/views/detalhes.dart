
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:epub_viewer/epub_viewer.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:kioxkenewf/components/download_alert.dart';
import 'package:kioxkenewf/models/database.dart';
import 'package:kioxkenewf/models/functions.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:kioxkenewf/util/bookModel.dart';
import 'package:kioxkenewf/util/const.dart';
import 'package:kioxkenewf/views/biblioteca/historicoCompra.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Datalhes extends StatefulWidget {
  @override
  _DatalhesState createState() => _DatalhesState();
   
   final String url,titulo,capa,autor,like,preco,descricao,id,categoria,subcategoria;
   final int isFavorite;
   final Function closeF;

   Datalhes(this.closeF,this.url,this.titulo,this.capa,this.autor,this.like,this.preco,this.descricao,this.id,{this.isFavorite,this.categoria,this.subcategoria});
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


   List<Widget> subCate = List();

   @override
  void initState() {
    super.initState();
  
    getTypeCatgory();
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
       body: SingleChildScrollView(
         child:Consumer<BooksModel>(
        builder: (context, item, child) {
          return Column(
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
                      icon:favactive==0?Icon(Icons.favorite,color: Colors.red):Icon(Icons.favorite), onPressed: (){
                        setfavorite();
                        item.addbookFile(widget.id,widget.titulo,widget.descricao,widget.preco,widget.capa,widget.url,"desejos","desejos",0);
                        
                      },)),
                   SizedBox(width: 5,),
                   CircleAvatar(
                    backgroundColor:Color(0xFF0E3311).withOpacity(0.5),
                    child:  !idDownloaded?IconButton(icon:!isonCard?Icon(Icons.add_shopping_cart, size: 25,color: Colors.white,):Icon(Feather.shopping_bag,color: primaryColor, size: 25), onPressed: (){
                      item.addCart(widget.id,widget.titulo,widget.descricao,widget.preco,widget.capa,widget.url,"carrinho","carrinho",1);
                      setCarrinho();
                    }):
                     IconButton(icon: Icon(Feather.share_2), onPressed: () => {})
                  )
                   ])

            )
           
           
          ]
        ),
      ),
      Row(
        children: [
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
                        text: widget.categoria =="Livros"? ("by "+widget.autor):("Edição: "+widget.autor)),
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
                    //  widget.closeF();
                    // showConfirm(context,"Confirmação","Item Removido do carrinho com sucesso");
                   },
                   child:Text("Remover do Carrinho",style: TextStyle(color:Colors.white),)
                  ):
                  idDownloaded==false?
                  FlatButton(
                   padding: EdgeInsets.zero,
                   color:primaryColor,
                   onPressed: () async{
                      showPaymentDetails(context,(){
                        item.addCart(widget.id,widget.titulo,widget.descricao,widget.preco,widget.capa,widget.url,"carrinho","carrinho",1);
                      });
                   },
                   child:Text("Comprar",style: TextStyle(color:Colors.white),)
                  ):
                   FlatButton(
                   padding: EdgeInsets.zero,
                   color: Colors.green,
                   onPressed: () async{

                      final SharedPreferences prefs = await _prefs;
                    
                      openBook(prefs.getString(widget.id+"book"));
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
  Container(
    width:  MediaQuery.of(context).size.width,
    height:60,
    padding: EdgeInsets.only(bottom: 10,top: 10),
    child: ListView(
      scrollDirection: Axis.horizontal,
      children:subCate
    ),
  ),
  pageTitle("Descrição",context),
Container(
        padding: EdgeInsets.all(10),
        alignment: Alignment.center,
         child:ExpandablePanel(
        header: Text( widget.descricao,
          maxLines: 5,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        expanded: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.descricao,
              softWrap: true,
            )),
      )),

    pageTitle("Comentários",context),
    cardComments(),
    cardComments(),
    cardComments(),
    cardComments(),
  
    ]);
    })
    )
    );

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

       if(prefs.getInt(widget.titulo+"save") != 1)
           int value = await DatabaseHelper.instance.deleteBook(widget.titulo);

       getFavorite();
  }


  void setCarrinho() async{
  final SharedPreferences prefs = await _prefs;

      //  saveList(widget.id,widget.titulo,widget.descricao,widget.preco,widget.capa,widget.url,"carrinho","carrinho",1);
       
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


Widget normalButton(String labelText,Color cor,bool isSubmited,Function callback){
  return Padding(padding: EdgeInsets.all(5),
  child:SizedBox(
          width: MediaQuery.of(context).size.width-20, //Full width
          height: 60,
    child:FlatButton(
       color: cor,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      onPressed:() async{
      //  Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) =>  MainPage()),(Route<dynamic> route) => false);
      callback();
    },
   padding:EdgeInsets.all(0.0),
   child:
   Text("$labelText",style: TextStyle(color:Colors.white, fontSize: 15, fontWeight: FontWeight.bold),)
 )
   ));
}


void showPaymentDetails(BuildContext contextop,calback){
  showMaterialModalBottomSheet(
    expand:false,
    context: context,
    builder: (context) => 
    Container(
      height: 170,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          normalButton("Adicionar no Carrinho",Colors.green,false,(){
            calback();
            setCarrinho();
             
             Navigator.pop(context);
          }),
          normalButton("Terminar a Compra",Colors.redAccent,false,() async{

           EasyLoading.show(status: 'Aguarde');
           SharedPreferences prefs = await SharedPreferences.getInstance();
           String sharEncode = generateRandomString(9);
           String email = prefs.getString("email").toString();
           List respo =  new List();
           final response = http.get("https://www.visualfoot.com/api/Card_temp/getSaveData.php?identfy=tb_compras&filtreId=id_compra&filtre=$email");
           final val = response.then((value){
              return json.decode(value.body);
            });
 
          respo  = await val as List;

          if(respo.length > 0){  
            EasyLoading.dismiss();
            Navigator.pop(context);

           showNormalAlert(contextop,() async{
            EasyLoading.show(status: 'Aguarde');
            final response = await http.get("https://visualfoot.com/api/historico/deliteHist.php?id=${respo[0]['id_carrinho']}");
            var result = await sendOneCard(id:widget.id.toString(), titulo:widget.titulo, capa:widget.capa,preco:widget.preco.toString(),encode: sharEncode,total: widget.preco.toString());
           
            Navigator.push(contextop,MaterialPageRoute(builder: (contextop) =>  Historico(isVerified:true)));
            
            EasyLoading.dismiss();
           },"Aviso!","Não pode ter duas encomendas pendentes em simultâneo.\n\nPretende eliminar a encomenda anterior ou cancelar a actual?");

            return;
          }
            var result = await sendOneCard(id:widget.id.toString(), titulo:widget.titulo, capa:widget.capa,preco:widget.preco.toString(),encode: sharEncode,total: widget.preco.toString());
            if(result == 1){
              widget.closeF();
              Navigator.pop(context);
              Navigator.push(context,MaterialPageRoute(builder: (context) =>  Historico(isVerified:true)));
            }else{
              Navigator.pop(context);
              widget.closeF();
            }

            EasyLoading.dismiss();

          })


        ],
      )
    ),
  );
}

void getTypeCatgory(){
   if(widget.subcategoria !=null&&!widget.subcategoria.toString().contains("/")){
       subCate.add( Padding(
         padding: EdgeInsets.all(5),
         child:  FlatButton(
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(color: primaryColor)),
          textColor:primaryColor,
          padding: EdgeInsets.all(8.0),
          onPressed: () {},
          child: Text(widget.subcategoria.toUpperCase(),
          style: TextStyle(
            fontSize: 12.0,
          ),
      ),
    )));

    }else
    if(widget.subcategoria !=null)
    for(int i=0; i < widget.subcategoria.split("/").length;i++){
        subCate.add( Padding(
         padding: EdgeInsets.all(5),
         child:  FlatButton(
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(color: primaryColor)),
          textColor:primaryColor,
          padding: EdgeInsets.all(8.0),
          onPressed: () {},
          child: Text((widget.subcategoria.split("/")[i]).toUpperCase(),
          style: TextStyle(
            fontSize: 12.0,
          ),
      ),
    ))
    
    );

    }
}



}