import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Historico extends StatefulWidget {
  @override
  _HistoricoState createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  
  List historico = new List();

    @override
  void initState() {
    super.initState();
    getHistorico();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        elevation: 0.0,
        backgroundColor: primaryColor,
        centerTitle: true,
       title: Text("Historico de Compras"),
        actions: [
          
        ]
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
                // physics: NeverScrollableScrollPhysics(),
                itemCount: historico.length,
                itemBuilder: (BuildContext context, int index) {
                  return  produts(historico[index]['capa'],historico[index]['titulo'],historico[index]['preco_pagar']);
                }) 
      ),
    );
  }

  void getHistorico() async{
     SharedPreferences prefs = await SharedPreferences.getInstance();
     final dataget = await http.get("https://www.visualfoot.com/api/historico/getBooxs.php?email=${prefs.getString("email")}");
    if (dataget.statusCode == 200) {
      historico = json.decode(dataget.body) as List;
      setState(() {
        
      });
    } else {
      throw Exception('Failed to load photos');
    }
  }

}


