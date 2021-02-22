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
}

class _HistoricoState extends State<Historico> {

  List historico = new List();

  String fileSystem ="";
  Future<String> _path;

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
       title: Text("Historico de Compras"),
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
                      return produts(action,int.parse(historico[index]['count']),historico[index]['capa'],historico[index]['titulo'],historico[index]['total_pagar'],int.parse(historico[index]['id']),historico[index]['data'],historico[index]['hora'],historico[index]['estado'],() async{getHistorico(true);},(){startDownloadFile(historico[index]['url'],historico[index]['id_book']+"book",historico[index]['titulo'],historico[index]['capa']); });
                    }, 
                    openBuilder: (context,action){
                       return Cardeails(action,historico[index]['id_carrinho']);
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
    
    for(int a =0;a < historico.length;a++)
    if(historico[a]['estado'] == "1" && prefs.getString(historico[a]['id']+"book").isNotEmpty)
     {
        final dir = Directory(prefs.getString(historico[a]['id']+"book"));
        dir.deleteSync(recursive: true);
        prefs.remove(historico[a]['id']+"book");
     }

    print(historico.length);
    if(showPopop)
    EasyLoading.dismiss();
    getHistorico(false);
}


void startDownloadFile(String url, String filename, String bookName,String capa) async {
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


}



