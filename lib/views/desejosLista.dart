import 'dart:io';
import 'package:kioxkenewf/models/functions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:ui';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kioxkenewf/models/database.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:kioxkenewf/util/const.dart';
import 'package:kioxkenewf/views/detalhes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistWidget extends StatefulWidget {
  
  @override
  _WishlistWidgetState createState() => _WishlistWidgetState();
}

class _WishlistWidgetState extends State<WishlistWidget> {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<Map<String,dynamic>> queryRows = new List<Map<String,dynamic>>();
 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {  
    loadAsset();
    });
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
        backgroundColor:primaryColor,
        title: Text("Lista de Desejos",
          textAlign: TextAlign.center,
            style: TextStyle(
            fontFamily: "cuyabra",
            fontWeight: FontWeight.w400,
            fontSize: 18,
            ),
          ),
            actions: [
            //  Icon(Icons.more_vert,color: Colors.white,)
          ],
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        child:ListView.builder(
            itemCount: queryRows.length,
            itemBuilder: (BuildContext context, int index){
            
            return queryRows[index]['tipo'] == 0?horisontal(context:context,titulo:queryRows[index]['nome'], imageUrl:queryRows[index]['imageUrl'], autor:"", likes:"0", urlBook:queryRows[index]['urlBook'], preco:queryRows[index]['preco'], descricao:queryRows[index]['descricao'], id:queryRows[index]['id'].toString(),idcloud: queryRows[index]['idcloud']):SizedBox();
        },
      )
     )
    );
  }


 Widget horisontal({BuildContext context,String titulo,String imageUrl,String autor,String likes,String urlBook,String preco,String descricao,String id,int idcloud}){
  FlutterMoneyFormatter precoProduto = FlutterMoneyFormatter(amount: double.parse(preco));
  return 
  Card( 
  color: Colors.white,
  borderOnForeground:true,
  shadowColor:Colors.grey[100],
  child:CachedNetworkImage(
    imageUrl: "$imageUrl",
    imageBuilder: (context, imageProvider) => Container(
    width: MediaQuery.of(context).size.width,
    height: 180,
    child: Row(
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
          height: 200,
          padding:EdgeInsets.all(15),
          child:Column(
            children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child:RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        style:subtitle,
                        text: "$titulo"),
                  ),
                ),

               SizedBox(
                 height: 10,
               ),
                Container(
                  alignment: Alignment.centerLeft,
                  child:Text("$descricao",maxLines:3)
                ),
              
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [

                Text((precoProduto.output.nonSymbol != "0.00"?precoProduto.output.nonSymbol+"AOA":"Gratuito"),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: precoProduto.output.nonSymbol != "0.00"?primaryColor:Colors.green),),
              
       
                   ],
                 ),

                   Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [
                        
                  Container(
                          height: 30,
                          child: IconButton(icon:Icon(Feather.shopping_bag,size: 25, color:Colors.green,), onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context) => Datalhes((){
                    Navigator.pop(context);
                  },urlBook,titulo,imageUrl,autor,likes,preco,descricao,id)));
                          })
                        ),
                  Container(
                          height: 30,
                          child: IconButton(icon:Icon(Feather.trash,size: 25, color:Colors.red,), onPressed: () async{
                            
                            showAlertDialog(context,() async{
                                final SharedPreferences prefs = await _prefs;
                                prefs.remove(titulo+"_favorite");
                                int value = await DatabaseHelper.instance.delete(int.parse(id));
                                desejosDeliteItems(idcloud.toString());
                                loadAsset();
                                setState(() {});
                            });
                            
                            

                          })
                        )
                   ],),
                  
         
            ],
          ),
        )

        )
      ],
    ),
  ),
  placeholder: (context, url) => shimerEfect(context),
    errorWidget: (context, url, error) => Icon(Icons.error),
  ));
 }


      
 loadAsset() async {
     queryRows = await DatabaseHelper.instance.queryAll(0);
     //print(queryRows);
     setState(() {});
  }

}

