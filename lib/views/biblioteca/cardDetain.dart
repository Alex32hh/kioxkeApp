import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kioxkenewf/components/download_alert.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:kioxkenewf/util/const.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class Cardeails extends StatefulWidget {
  @override
  _CardeailsState createState() => _CardeailsState();
  final int estadoDacompra;
  final Function callback;
  final String idCode,data,hora,dataCompra,formaPagamento;
  final int quantidade;
  final int totalPagar;
  final int numEcomenda;

  Cardeails(this.callback,this.idCode,{this.quantidade,this.totalPagar,this.data,this.hora,this.numEcomenda,this.dataCompra,this.formaPagamento,this.estadoDacompra});
}

class _CardeailsState extends State<Cardeails> {
    final Dio _dio = Dio();
    List historicoAll = [];
    String fileSystem ="";
    Future<String> _path;
    double _progress = 0.0;

  @override
  void initState() {
    super.initState();
     getAllHistorico(true);
  }
    @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterMoneyFormatter totalPagarAll = FlutterMoneyFormatter(amount: double.parse(widget.totalPagar.toString()));
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children:[
            Container(
               width: MediaQuery.of(context).size.width,
               height: 70,
               color: primaryColor,
               alignment: Alignment.bottomLeft,
              padding:EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                   CircleAvatar(
                      radius: 17,
                      backgroundColor:Colors.transparent,
                      child: IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.arrow_back_ios,size: 20,), onPressed: widget.callback)
                    ),

                    Text("Código da Compra: ${widget.idCode}", style: TextStyle(color:Colors.white,fontSize:15),),

                    CircleAvatar(
                      radius: 20,
                      backgroundColor:Color(0xFF0E3311).withOpacity(0),
                      child: IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.info_outline,size: 28,), onPressed:(){
                          if(widget.estadoDacompra == 0)ShowPaymentDetails(); else showPaySucessPment();
                      })
                    ),

                ],
              ),
            ),

            Container(
               width: MediaQuery.of(context).size.width,
               height: MediaQuery.of(context).size.height-70,
              child: Stack(
                children: [
                Container(
                 width: MediaQuery.of(context).size.width,
                 height: MediaQuery.of(context).size.height,  
                child: ListView.builder(
                itemCount: historicoAll.length,
                itemBuilder: (BuildContext context, int index) {
                  return widget.idCode == historicoAll[index]['id_carrinho']? cardItem(historicoAll[index]['titulo'],historicoAll[index]['capa'],historicoAll[index]['preco_pagar'],download: () async{
                        
                        downloadFile(historicoAll[index]['url'],historicoAll[index]['id_book']+"book",historicoAll[index]['titulo'],historicoAll[index]['capa']);   
                        print(historicoAll[index]['url']);

                  },estado:int.parse(historicoAll[index]['estado']),progress:_progress):SizedBox();
                })),

               Align(
                 alignment: Alignment.bottomCenter,
                 child: Padding(padding: EdgeInsets.all(10),
                 child:Card(
                   child:Container(
                  width: MediaQuery.of(context).size.width,
                  height:100,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children:[
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("SubTotal",style: TextStyle( fontSize: 15,)),
                       Text("${totalPagarAll.output.nonSymbol} kzs",style: TextStyle(color:primaryColor,fontWeight:FontWeight.bold, fontSize: 15),),
                    ],
                  ),
                    Divider( color: Colors.black45),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total",style: TextStyle(fontSize: 17,)),
                       Text("${totalPagarAll.output.nonSymbol} kzs",style: TextStyle(color:primaryColor,fontWeight:FontWeight.bold, fontSize: 20),),
                    ],
                  ),
                    ]
                  )
                ), ),
               )
               )

                ],
              )
            )

          ]
        )
      ),
    );
  }

void getAllHistorico(bool showPopop) async{
    if(showPopop)
     EasyLoading.show(status: 'Aguarde');
     SharedPreferences prefs = await SharedPreferences.getInstance();
     final dataget = await http.get("https://www.visualfoot.com/api/historico/getBooxs.php?email=${prefs.getString("email")}");
    if (dataget.statusCode == 200) {
      historicoAll = json.decode(dataget.body) as List;
      print(historicoAll);
      setState(() {});
    } else {
      throw Exception('Failed to load photos');
    }
    if(showPopop)
    EasyLoading.dismiss();

}


void ShowPaymentDetails(){

   FlutterMoneyFormatter precoProduto = FlutterMoneyFormatter(amount: double.parse(widget.totalPagar.toString()));

  showMaterialModalBottomSheet(
    expand:false,
    context: context,
    builder: (context) => Container(
      height: 300,
      child: Column(
        children:[
          SizedBox(height: 5,),
           Container(
             width: MediaQuery.of(context).size.width/5,
             height: 10,
             decoration: BoxDecoration(
               color: Colors.grey[300],
               borderRadius: BorderRadius.circular(30)
             ),
           ),
          
           Container(
             padding: EdgeInsets.all(10),
             child:  Text("Encomenda Pendente"),
           ),
            ListTile(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Text("Encomenda Nº: ${widget.numEcomenda} "),
                ]
              ),
              subtitle:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Text("Emissão:  ${widget.data} e  ${widget.hora}"),
                
                ]
              ),
            ),

            ListTile(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Text("Código da Encomenda: ${widget.idCode} ",style: TextStyle(fontSize: 15),),
                   Text("Quantidade: ${widget.quantidade} ",style: TextStyle(fontSize: 15),)
                ]
              ),
             
            ),

             ListTile(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Text("Email de envio: kioxkecomercial@kioxke.com ",style: TextStyle(fontSize: 15),),
                ]
              ),
             
            ),

             ListTile(
               tileColor:Colors.grey[200],
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      Text("Total a Pagar:",style: TextStyle(fontSize: 20),),
                      Text("${precoProduto.output.nonSymbol} kzs",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: primaryColor),)
                    ]
                  )
                
                ]
              ),
             
            )


        ]
      ),
    ),
  );

}


void showPaySucessPment(){

   FlutterMoneyFormatter precoProduto = FlutterMoneyFormatter(amount: double.parse(widget.totalPagar.toString()));

  showMaterialModalBottomSheet(
    expand:false,
    context: context,
    builder: (context) => Container(
      height: 300,
      child: Column(
        children:[
          SizedBox(height: 5,),
           Container(
             width: MediaQuery.of(context).size.width/5,
             height: 10,
             decoration: BoxDecoration(
               color: Colors.green[300],
               borderRadius: BorderRadius.circular(30)
             ),
           ),
          
           Container(
             padding: EdgeInsets.all(10),
             child:  Text("Encomenda Concluida"),
           ),
            ListTile(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Text("Encomenda Nº: ${widget.numEcomenda} "),
                ]
              ),
              subtitle:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Text("Emissão:  ${widget.data} e  ${widget.hora}"),
                ]
              ),
            ),

            ListTile(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[

                   Text("Quantidade: ${widget.quantidade} ",style: TextStyle(fontSize: 15),),

                   Text("Forma de Pagamaento: ${widget.formaPagamento} ",style: TextStyle(fontSize: 15),),
                   
                ]
              ),
                subtitle: Text("Data da Compra: ${widget.dataCompra}"),
             
            ),

             ListTile(
              tileColor:Colors.green[400],
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
              
                  Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      Text("Concluido",style: TextStyle(fontSize: 20,color:Colors.white),),
                     Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      Text("Total a Pago:",style: TextStyle(fontSize: 15),),
                      Text(" ${precoProduto.output.nonSymbol} kzs",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)
                    ]
                  )
                    ]
                  )
                
                ]
              ),
            
             
            ),


        ]
      ),
    ),
  );

}


void startDownloadFile(String url, String filename, String bookName,String capa) async {
  final xtension = p.extension(url);
  print(xtension);
  print(url);

   Directory appDocDir = Platform.isAndroid? await getExternalStorageDirectory(): await getApplicationDocumentsDirectory();

   if (Platform.isAndroid) {
          Directory(appDocDir.path.split('Android')[0] + '${Constants.appName}').createSync();
        }

    String path = Platform.isIOS
        ? appDocDir.path + '/$filename$xtension'
        : appDocDir.path.split('Android')[0] +
            '${Constants.appName}/$filename$xtension';

    print(path);
    File file = File(path);
    if (!await file.exists()) {
      await file.create();
      
    } else {
      await file.delete();
      await file.create();
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => DownloadAlert(
        url: url,
        path: path,
        bookname: bookName,
        imageUrl: capa
      ),
    ).then((v) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     final String pathaved = path;
     fileSystem =  path;
      if (v != null) {

        setState(() {
       _path = prefs.setString(filename, pathaved).then((bool success) {
        return pathaved;
        });

      });
     }
    });
  }
  


void downloadFile(String url, String filename, String bookName,String capa)async{
    final xtension = p.extension(url);
    print(xtension);
    print(url);

    Directory appDocDir = Platform.isAndroid? await getExternalStorageDirectory(): await getApplicationDocumentsDirectory();

    if (Platform.isAndroid) {
            Directory(appDocDir.path.split('Android')[0] + '${Constants.appName}').createSync();
          }

      String path = Platform.isIOS
          ? appDocDir.path + '/$filename$xtension'
          : appDocDir.path.split('Android')[0] +
              '${Constants.appName}/$filename$xtension';

      print(path);
      File file = File(path);
      if (!await file.exists()) {
        await file.create();
        
      } else {
        await file.delete();
        await file.create();
      }
      _dio.download(url, path,onReceiveProgress:_onReceiveProgress);
  }

  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        // _progress = (received / total * 100).toStringAsFixed(0) + "%";
         _progress = (received / total);
      });
    }
  }

}