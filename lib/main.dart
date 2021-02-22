import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kioxkenewf/models/functions.dart';
import 'package:kioxkenewf/util/checkInternet.dart';
import 'package:kioxkenewf/views/Login.dart';
import 'package:kioxkenewf/views/biblioteca/biblioteca.dart';
import 'package:kioxkenewf/views/home.dart';
import 'package:kioxkenewf/views/spash.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

void main (){
  runApp(
   MaterialApp(
     debugShowCheckedModeBanner: false,
      color: Colors.red,
      home:Main(),
      builder: EasyLoading.init(),
    )
  );
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}


class _MainState extends State<Main> {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<String> _email,_nome;
  List list = new List();
  int idConection;

  @override
  void dispose() {
    super.dispose();
  }

 

  startTimeout() {
    return new Timer(Duration(seconds: 2), handleTimeout);
  }
  
  Future<void> _checkSession(String nome,String email) async {
    final SharedPreferences prefs = await _prefs;
    //final int counter = (prefs.getInt('counter') ?? 0) + 1;
      if(prefs.getString("email") != null){
         print(prefs.getString("email")+prefs.getString("nome"));
        int value =  await getdataSave("https://www.visualfoot.com/api/?catType=Livros","dataAll.spv");
        int value2 = await getdataSave("https://www.visualfoot.com/api/acessos.php?tipo=populares","populares.spv");
        idConection= value+value2;
        print("Conection timer "+idConection.toString());
         if(idConection >= 2)
           Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) =>  HomeView(prefs.getString("nome").replaceAll('"', ""),prefs.getString("email").replaceAll('"', ""))),(Route<dynamic> route) => false);
         else
           Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) =>  Biblioteca()),(Route<dynamic> route) => false);
      }else{
        await getdataSave("https://www.visualfoot.com/api/?catType=Livros","dataAll.spv");
        await getdataSave("https://www.visualfoot.com/api/acessos.php?tipo=populares","populares.spv");
        startTimeout();
      }
  }
  
  void handleTimeout() {
    changeScreen();
  }


  changeScreen() async {
    //  if(_connectionStatus != "Conected"){
    //   Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => Biblioteca()),(Route<dynamic> route) => false);
    //   return;
    // }
     Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => Login()));
    
  }

  @override
  void initState() {
    super.initState();
     checkInternet().checkConnectionInit(context,(){
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) =>  Biblioteca()),(Route<dynamic> route) => false);
     });
    _email = _prefs.then((SharedPreferences prefs) {
      return (prefs.getString('email'));
    });
    _nome = _prefs.then((SharedPreferences prefs) {
      return (prefs.getString('nome'));
    });
     _checkSession(_nome.toString(),_email.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Splash(),
    );
  }






}