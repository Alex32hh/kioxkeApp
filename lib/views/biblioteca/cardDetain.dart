import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Cardeails extends StatefulWidget {
  @override
  _CardeailsState createState() => _CardeailsState();
  final Function callback;
  final String idCode;
  Cardeails(this.callback,this.idCode);
}

class _CardeailsState extends State<Cardeails> {

    List historicoAll = new List(); 
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
                      backgroundColor:Color(0xFF0E3311).withOpacity(0.5),
                      child: IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.close_rounded,size: 16,), onPressed: widget.callback)
                    ),

                    Text("Código da Compra: ${widget.idCode}", style: TextStyle(color:Colors.white,fontSize:15),),

                    CircleAvatar(
                      radius: 18,
                      backgroundColor:Color(0xFF0E3311).withOpacity(0),
                      child: IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.info_outline,size: 25,), onPressed: ShowPaymentDetails)
                    ),

                ],
              ),
            ),

            Container(
               width: MediaQuery.of(context).size.width,
               height: MediaQuery.of(context).size.height-70,
              child:ListView.builder(
                itemCount: historicoAll.length,
                itemBuilder: (BuildContext context, int index) {
                  return widget.idCode == historicoAll[index]['id_carrinho']? cardItem(historicoAll[index]['titulo'],historicoAll[index]['capa'],historicoAll[index]['preco_pagar']):SizedBox();
                }) 
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
      setState(() {});
    } else {
      throw Exception('Failed to load photos');
    }
    if(showPopop)
    EasyLoading.dismiss();
}


void ShowPaymentDetails(){
  
  showMaterialModalBottomSheet(
    expand:false,
    context: context,
    builder: (context) => Container(
      height: 300,
    ),
  );

}


}