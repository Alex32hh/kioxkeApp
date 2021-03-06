import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'dart:ui';
import 'package:kioxkenewf/models/database.dart';
import 'package:kioxkenewf/models/functions.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:kioxkenewf/util/bookModel.dart';
import 'package:kioxkenewf/views/biblioteca/historicoCompra.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CardCompras extends StatefulWidget {
  
  @override
  _CardComprasState createState() => _CardComprasState();
}

class _CardComprasState extends State<CardCompras> {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List listFiles = new List();
  String totalPagarLabel;
  double totalPagar = 0;

  bool sedOne = false;
  String sharEncode = generateRandomString(9);

  List<Map<String,dynamic>> queryRowsCard = new List<Map<String,dynamic>>();
  
  @override
  void initState() {
    super.initState();
     waitinTime();

     FlutterMoneyFormatter precoProduto = FlutterMoneyFormatter(amount:totalPagar);
     totalPagarLabel = precoProduto.output.nonSymbol;
     
     setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:primaryColor,
        centerTitle: true,
        title: Text("Carrinho de Compras",
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
      body:Consumer<BooksModel>(
        builder: (context, item, child) { 
          return Container(
        constraints: BoxConstraints.expand(),
        child: Stack(
          children: [
            Container(
              width:MediaQuery.of(context).size.width,
              height:MediaQuery.of(context).size.height /1.3,
              child:ListView.builder(
            itemCount: queryRowsCard.length,
            itemBuilder: (BuildContext context, int index){
            return queryRowsCard[index]['tipo'] == 1?horisontal(titulo:queryRowsCard[index]['nome'], imageUrl:queryRowsCard[index]['imageUrl'], autor:"", likes:"0", urlBook:queryRowsCard[index]['urlBook'], preco:queryRowsCard[index]['preco'], descricao:queryRowsCard[index]['descricao'], id:queryRowsCard[index]['id'].toString(),qtdview: queryRowsCard[index]['quantidade'],idcloud: queryRowsCard[index]['idcloud'],model: item):SizedBox();
            },
      
      )
            ),
          Align(
            alignment: Alignment.bottomCenter,
              child:Card  (
            
            child: Container(
            padding: EdgeInsets.all(5),
            height: 130,
                child: Column(children: [
                     Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                     Flexible(
                     child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Cupon de Desconto'
                        ),
                      )),
                      FlatButton(
                      color: Colors.red[300],
                      textColor: Colors.white,
                      padding: EdgeInsets.all(8.0),

                      onPressed: () {
                        /*...*/
                      },
                      child: Text(
                        "Aplicar",
                        // style: TextStyle(fontSize: 20.0),
                      ),
                    )
                    ],
                  ),
                    Divider( color: Colors.black45),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child:Text(" Total: $totalPagarLabel AOA",style:optionStyle)
                        ),
                        FlatButton(
                          color:Colors.amber,
                          onPressed:() async{
                            showNormalAlert(context,(){deployCadsOnly();},"Aviso","Tem certeza que deseja terminar a Compra?");
                          },
                        child: Container(
                          width: 150,
                          height:40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            // color: Colors.amber,
                            borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                          child:Text("Terminar a Compra")
                        ),)
                      ],
                    )
               ]
              )
            ),

          )

        )],
        )
      );
     }
    ));
  }

   waitinTime() {
    return new Timer(Duration(milliseconds: 1),()async{loadAsset();});
  }


Widget horisontal({String titulo,String imageUrl,String autor,String likes,String urlBook,String preco,String descricao,String id,int qtdview,int idcloud,BooksModel model}){
  FlutterMoneyFormatter precoProduto = FlutterMoneyFormatter(amount: double.parse(preco));
  return Card( 
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

                Text((precoProduto.output.nonSymbol != "0.00"?precoProduto.output.nonSymbol+" KZS":"Gratuito"),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: precoProduto.output.nonSymbol != "0.00"?primaryColor:Colors.green),),
              
       
                   ],
                 ),

                Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [
                   Container(
                          height: 30,
                          child: IconButton(icon:Icon(Feather.trash,size: 25, color:Colors.red,), onPressed: () async{
                           
                            showAlertDialog(context,() async{
                              final SharedPreferences prefs = await _prefs;
                              prefs.remove(titulo+"_carrinho");
                              model.deliteBookCard(int.parse(id));
                              // int value = await DatabaseHelper.instance.delete(int.parse(id));
                              cardDeliteItems(idcloud.toString());
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
    EasyLoading.show(status: 'A carregar');
     queryRowsCard = await DatabaseHelper.instance.queryAll(1);
     totalPagar = 0;
     for(int a=0;a < queryRowsCard.length;a++){
      if(queryRowsCard[a]['tipo'] == 1){
        String preco =  queryRowsCard[a]['preco'];
        totalPagar+= double.parse(preco) *  queryRowsCard[a]['quantidade'];
      }

     }
    FlutterMoneyFormatter precoProduto = FlutterMoneyFormatter(amount:totalPagar);
    totalPagarLabel = precoProduto.output.nonSymbol;
    setState(() {});
    EasyLoading.dismiss();
}


void deployCadsOnly() async {
   
    SharedPreferences prefs = await SharedPreferences.getInstance();

    EasyLoading.show(status: 'Aguarde');

    String email = prefs.getString("email").toString();
    List respo =  new List();
    final response = http.get("https://www.visualfoot.com/api/Card_temp/getSaveData.php?identfy=tb_compras&filtreId=id_compra&filtre=$email");
    final val = response.then((value){
       return json.decode(value.body);
    });
 
    respo  = await val as List;

    if(respo.length > 0){  
       showNormalAlert(context,(){
         EasyLoading.dismiss();
         sendCardToServer(deliteCard:respo[0]['id_carrinho']);
       },"Aviso!","Não pode ter duas encomendas pendentes em simultâneo.\n\nPretende eliminar a encomenda anterior ou cancelar a actual?");
     
       EasyLoading.dismiss();
    }else{
      sendCardToServer();
    }

}


void sendCardToServer({String deliteCard}) async{
   SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email").toString();
   if(deliteCard != null)
      final response = http.get("http://visualfoot.com/api/historico/deliteHist.php?id=$deliteCard");

   queryRowsCard = await DatabaseHelper.instance.queryAll(1);
    for(int a=0;a < queryRowsCard.length;a++){
      if(queryRowsCard[a]['tipo'] == 1){
            if(!sedOne){
              final getEmalSender = await http.get('http://manifexto.com/Kioxke_App/sendCartDetails.php?user_email=$email&user_price=${queryRowsCard[a]['preco'].toString()}&book_title=${queryRowsCard[a]['nome'].toString()}&book_id=$sharEncode');
              sedOne = true;
            }

            cardItems(id:queryRowsCard[a]['idcloud'].toString(), titulo:queryRowsCard[a]['nome'], capa:queryRowsCard[a]['imageUrl'],preco:queryRowsCard[a]['preco'].toString(),encode: sharEncode,total: totalPagar.toString());
            cardDeliteItems(queryRowsCard[a]['idcloud'].toString());
            int value = await DatabaseHelper.instance.deleteBook(queryRowsCard[a]['nome']);
            prefs.setBool(queryRowsCard[a]['nome']+'_carrinho', false);
      }
    }
    
     EasyLoading.showSuccess('Sucesso',dismissOnTap:false);
     loadAsset();
     Navigator.push(context,MaterialPageRoute(builder: (context) =>  Historico(isVerified:true)));
     EasyLoading.dismiss();
}


void cardItems({String id,String titulo,String capa,String preco,String encode,String total}) async{
   EasyLoading.show(status: 'A carregar');
   SharedPreferences prefs = await SharedPreferences.getInstance();
       final response = await http.post('https://www.visualfoot.com/api/cardSave.php',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    // urlLocal,nome,id,capa,preco,titulo;
    body: jsonEncode(<String, String>{
       'book_id':id.toString(),
       'book_title':titulo.toString(),
       'book_capa':capa.toString(),
       'book_preco':preco.toString(),
       'book_buy_id':prefs.getString("email").toString(),
       'id_carrinho':encode.toString(),
       'total_pagar':total.toString()
    }),

  );
    var encodeFirst = json.encode(response.body);
    var data = json.decode(encodeFirst);
    EasyLoading.dismiss();
 }
}

