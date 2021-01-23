import 'dart:convert';

import 'package:epub_viewer/epub_viewer.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter/material.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; 
class WaitPay extends StatefulWidget {

  @override
  _WaitPayState createState() => _WaitPayState();

  final String urlLocal,nome,id,capa,preco,titulo;
  WaitPay(this.urlLocal,this.nome,this.id,this.capa,this.preco,this.titulo,);
}

class _WaitPayState extends State<WaitPay> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<String> _path;

  bool concluido = false;
  String precolabel;
 @override
  void initState() {

    super.initState();
        FlutterMoneyFormatter precoProduto = FlutterMoneyFormatter(amount: double.parse(widget.preco));
        precolabel = precoProduto.output.nonSymbol;

    deployProdutos();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: primaryColor,
       title: Text("Requisição de Compra"),
         actions: [
             Icon(Icons.update,color: Colors.white,)
          ],
      ),
      
      //adicionar um singleScrollView....
      body: Container(
        width: MediaQuery.of(context).size.width,
      child:Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

           SizedBox(height: 20,),
          Text("Obrigado!",style: TextStyle(fontSize:30),),
            SizedBox(height: 20,),
            Text(precolabel+" AOA",style: TextStyle(fontSize:30,color: primaryColor),),
             SizedBox(height: 20,),
          Text("Ordem, N #234-234-234",),
           SizedBox(height: 20,),
          Text("Aos,25 de Julho de 2020 (13:29)",),
           SizedBox(height: 20,),
           Text("Os detalhes da sua compra foram enviados para o email registrado na sua conta.",textAlign:TextAlign.center, style: TextStyle(fontSize:15)),
            SizedBox(height: 20,),
           Text("Ver lista de Produtos", style: TextStyle(fontSize:20,color: primaryColor)),
             SizedBox(height: 20,),
          Text("Produto Pendente!",style: TextStyle(fontSize:30),),
            SizedBox(height: 10,),
          Text("Termine o proceso de compra!",style: TextStyle(fontSize:15),),
            Expanded(
              child:Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                loginButton("Enviar Comprovativo Bancario",Colors.green,true),
                loginButton("Pagar com a Carteira",primaryColor,true)
              ],
            )
          )
          
        ],
       )
      ),
    );
  }


Widget cardList(Color cor,String label,String email){
  return Card(
    elevation:0.5,
    shadowColor:Colors.grey[800],
    child: ListTile(
      title: Text("$label"),
      subtitle: Text("$email"),
      trailing: Icon(Icons.add_circle_outline,color: cor,),
      onTap: (){

      },
    ),
  
  );
}


Widget loginButton(String labelText,Color cor,bool isSubmited){
  return Padding(padding: EdgeInsets.all(5),
  child:SizedBox(
          width: MediaQuery.of(context).size.width-20, //Full width
          height: 60,
    child:FlatButton(
       color: cor,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      onPressed:() async{
      //  openBook(widget.url);
      showNormalAlert(context,(){ Navigator.pop(context);},"Confirmação","Verifique o seu Correio Electrónico");
    },
   padding:EdgeInsets.all(0.0),
   child:
   Text("$labelText",style: TextStyle(color:Colors.white, fontSize: 15, fontWeight: FontWeight.bold),)
 )
   ));
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

void deployProdutos() async{
    final SharedPreferences prefs = await _prefs;
       final response = await http.post('https://www.visualfoot.com/api/cardSave.php',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    // urlLocal,nome,id,capa,preco,titulo;
    body: jsonEncode(<String, String>{
       'book_id':  widget.id.toString(),
       'book_title':  widget.titulo.toString(),
       'book_capa':  widget.capa.toString(),
       'book_preco':  widget.preco.toString(),
       'book_buy_id':  prefs.getString("email").toString()
    }),

  );

    String email = prefs.getString("email").toString();

    var encodeFirst = json.encode(response.body);
    var data = json.decode(encodeFirst);

    if(data.contains("sucess")){
      final getEmalSender = await http.get('http://manifexto.com/Kioxke_App/sendCartDetails.php?user_email=$email&user_price=${widget.preco.toString()}&book_title=${widget.titulo.toString()}&book_id=${widget.id.toString()}');
    }
}

}