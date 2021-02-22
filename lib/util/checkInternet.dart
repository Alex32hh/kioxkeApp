import 'dart:async';
import 'package:flutter/material.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:kioxkenewf/views/biblioteca/biblioteca.dart';

class checkInternet{
  StreamSubscription<DataConnectionStatus> listener;
  var InternetStatus = "Unknown";
  var contentmessage = "Unknown";

  checkConnection(BuildContext context) async{
  listener = DataConnectionChecker().onStatusChange.listen((status) {
    switch (status){
      case DataConnectionStatus.connected:
        var intervalo = "Conectado a internet";
        var contentm = "Conectado a internet";
        if(InternetStatus != "Unknown"){
          Navigator.pop(context);
         _showDialogConected(intervalo,contentm,context);
        }
        break;
      case DataConnectionStatus.disconnected:
        InternetStatus = "Você está desconectado da Internet";
        contentmessage = "Por favor, verifique sua conexão à internet";
        _showDialog(InternetStatus,contentmessage,context,(){
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) =>  Biblioteca()),(Route<dynamic> route) => false);
        });
        break;
    }
  });
  return await DataConnectionChecker().connectionStatus;
}

  checkConnectionInit(BuildContext context,Function callback) async{
  listener = DataConnectionChecker().onStatusChange.listen((status) {
    switch (status){
      case DataConnectionStatus.connected:
        // _showDialog(InternetStatus,contentmessage,context);
        break;
      case DataConnectionStatus.disconnected:
        InternetStatus = "Você está desconectado da Internet";
        contentmessage = "Por favor, verifique sua conexão à internet";
         callback();
        break;
    }
  });
  return await DataConnectionChecker().connectionStatus;
}

void _showDialog(String title,String content ,BuildContext context,Function calback){
  showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
            title: new Text(title),
            content: new Text(content),
            actions: <Widget>[
                  new FlatButton(
                  onPressed: (){
                    // Navigator.of(context).pop();
                    calback();
                  },
                  child:Text("Ir para a Biblioteca") ),
                  FlatButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                   },
                  child:new Text("Ok") ),
            ]
        );
      }
  );
}


void _showDialogConected(String title,String content ,BuildContext context){
  showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
            title: new Text(title),
            content: new Text(content),
            actions: <Widget>[
                
                  FlatButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child:new Text("Ok") ),
            ]
        );
      }
  );
}



}