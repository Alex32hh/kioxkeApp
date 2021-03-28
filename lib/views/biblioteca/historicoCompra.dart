import 'dart:io';
import 'dart:convert';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kioxkenewf/components/download_alert.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:http/http.dart' as http;
import 'package:kioxkenewf/util/const.dart';
import 'package:kioxkenewf/views/biblioteca/cardDetain.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Historico extends StatefulWidget {
  @override
  _HistoricoState createState() => _HistoricoState();

  final isVerified;
  Historico({this.isVerified});

}

class _HistoricoState extends State<Historico> {

  List historico = new List();

  bool singletime = true;
    @override
  void initState() {
    super.initState();
    getHistorico(true);
  }
    @override
  void dispose() {
    super.dispose();
  }
 final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
     
    return Scaffold(
       appBar: AppBar(
        elevation: 0.0,
        backgroundColor: primaryColor,
        centerTitle: true,
       title: Text("Histórico de Compras"),
        actions: [
          
        ]
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height:  MediaQuery.of(context).size.height,
        child:RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh:_refresh,
        color: primaryColor,
        child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child:ListView.builder(
                itemCount: historico.length,
                itemBuilder: (BuildContext context, int index) {
                  return OpenContainer(
                    closedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
                    openElevation:0.0,
                    closedElevation: 0.0,
                    closedBuilder: (context,action){
                      return produts(action,int.parse(historico[index]['count']),historico[index]['capa'],historico[index]['titulo'],historico[index]['total_pagar'],int.parse(historico[index]['id']),historico[index]['data'],historico[index]['hora'],historico[index]['estado'],() async{getHistorico(true);},(){
                      
                        },idCarrinho:historico[index]['id_carrinho']);
                    }, 
                    openBuilder: (context,action){
                       return Cardeails(action,historico[index]['id_carrinho'],quantidade:int.parse(historico[index]['count']), totalPagar:int.parse(historico[index]['total_pagar']),data:historico[index]['data'].toString(),hora:historico[index]['hora'].toString(),numEcomenda:int.parse(historico[index]['id']),dataCompra:historico[index]['data_pagamento'].toString(),formaPagamento:historico[index]['forma_pagamento'].toString(),estadoDacompra:int.parse(historico[index]['estado']));
                    }
                    
                    );
                }) 
      )),
      )
    );
    
  }


Future<void>  _refresh() async{
   setState(() {});
   await getHistorico(true);
}

// o link abaixo pega o histirco ja agrupado por grupos de itens e singular caso so existir um
//https://www.visualfoot.com/api/historico/getBoxGoups.php?email=sds@gmail.com
  
void getHistorico(bool showPopop) async{
    if(showPopop)
     EasyLoading.show(status: 'Aguarde');

     SharedPreferences prefs = await SharedPreferences.getInstance();
     final dataget = await http.get("https://www.visualfoot.com/api/historico/getBoxGoups.php?email=${prefs.getString("email")}");
    if (dataget.statusCode == 200) {
      historico = json.decode(dataget.body) as List;
      setState(() {});
    } else {
      throw Exception('Failed to load photos');
    }
    
    for(int a =0;a < historico.length;a++){
    if(int.parse(historico[a]['estado'])== 0)
     {
        EasyLoading.dismiss();
        if(prefs.getString(historico[a]['id']+"book") != null){
        print(prefs.getString(historico[a]['id']+"book")+"<<<<");

        final dir = Directory(prefs.getString(historico[a]['id']+"book"));
        dir.deleteSync(recursive: false);
       
        prefs.remove(historico[a]['id']+"book");
       }

     }

    }

    if(showPopop)
    EasyLoading.dismiss();

    if(widget.isVerified == true && singletime == true){
        singletime = false;
        showConfirm(context,"Sucesso!","A encomenda foi processada com sucesso e um email foi enviado com os dados da encomenda. \nCaso pagamento por IBAN - queira porfavor efectuar o pagamento.");
    }
    getHistorico(false);

}



}



