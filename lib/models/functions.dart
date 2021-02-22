import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:kioxkenewf/models/database.dart';
import 'package:kioxkenewf/util/const.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'offinedabase.dart';
import 'package:http/http.dart' as http;

saveList(String id,String nome,String descricao,String preco,String imageUrl,String fileSrc,String pathName,String idident,int tipo) async {
   
    List<Map<String,dynamic>> queryRowsCard = new List<Map<String,dynamic>>();
    queryRowsCard = await DatabaseHelper.instance.queryAll(1);

    for(int a=0;a < queryRowsCard.length;a++){
        if(queryRowsCard[a]['nome'] == nome){
          DatabaseHelper.instance.valuesupdate(queryRowsCard[a]['id'],queryRowsCard[a]['quantidade']+1);
          return;
        }
    }
    
       
    int i = await DatabaseHelper.instance.insert({
      'nome':''+nome.toString(),
      'descricao':descricao.toString(),
      'preco':preco.toString(),
      'imageUrl':imageUrl.toString(),
      'pathName':pathName.toString(),
      'tipo':tipo,
      'idcloud':id,
      'idident':idident.toString(),
      'quantidade':1
      });
      print('valor inserido:$i');
      
      if(tipo == 1)
            cardSaveItems(id:id,titulo:nome.toString(),capa:imageUrl.toString(),preco:preco.toString(),urlbook:fileSrc.toString(),descricao:descricao.toString());
        else
            desejoSaveItems(id:id,titulo:nome.toString(),capa:imageUrl.toString(),preco:preco.toString(),urlbook:fileSrc.toString(),descricao:descricao.toString());

  }






saveListLocalBook(String nomeBook,String imgLink,String bookLink) async {
     int i = await DatabaseHelperLocal.instance.insert({
      'nomeBook':nomeBook.toString(),
      'imgLink':imgLink,
      'bookLink':bookLink.toString(),
      });
      print('valor inserido->:$i'+imgLink);
}

updateview(int id) async {
  String url = 'https://www.visualfoot.com/api/views/?id=$id';
  Response response = await get(url);
  // sample info available in response
  int statusCode = response.statusCode;
  Map<String, String> headers = response.headers;
  String contentType = headers['content-type'];
  String json = response.body;
}

updateFavorite(int id,int isFavorite) async {
  String url = 'https://www.visualfoot.com/api/views/updateFavorite.php?id=$id&favorite=$isFavorite';
  Response response = await get(url);
  // sample info available in response
  int statusCode = response.statusCode;
  Map<String, String> headers = response.headers;
  String contentType = headers['content-type'];
  String json = response.body;
}

void mailConfirmation(String  email)async{
     final response = await http.get('https://manifexto.com/Kioxke_App/mailSender.php?user_email=${email}',
     headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },

  );

    var encodeFirst = json.encode(response.body);
    var data = json.decode(encodeFirst);

    print(data);
  }

void deletaCarrinho(String id)async{
     EasyLoading.showSuccess('Eliminado',dismissOnTap:false,maskType:EasyLoadingMaskType.custom);
     final response = await http.get('http://visualfoot.com/api/historico/deliteHist.php?id=${id}',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
       },
      );

      var encodeFirst = json.encode(response.body);
      var data = json.decode(encodeFirst);
      EasyLoading.dismiss();
}

void updateStateCompra(String titulo)async{
     final response = await http.get('http://visualfoot.com/api/historico/downloadedBook.php?titulo=${titulo}',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
       },
      );

      var encodeFirst = json.encode(response.body);
      var data = json.decode(encodeFirst);
}


String generateRandomString(int len) {
  var r = Random();
  const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
}


void cardSaveItems({String id,String titulo,String capa,String preco,String urlbook,String descricao}) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();   
    final response = await http.post('https://www.visualfoot.com/api/Card_temp/savetempCard.php',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    // urlLocal,nome,id,capa,preco,titulo;
    body: jsonEncode(<String, String>{
       'titulo':titulo.toString(),
       'capa':capa.toString(),
       'id_book':id.toString(),
       'url_book':urlbook.toString(),
       'preco':preco.toString(),
       'descricao':descricao.toString(),
       'user_email':prefs.getString("email")
    }),

  );
    var encodeFirst = json.encode(response.body);
    var data = json.decode(encodeFirst);
    print(data);
 }

void desejoSaveItems({String id,String titulo,String capa,String preco,String urlbook,String descricao}) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();   
    final response = await http.post('https://www.visualfoot.com/api/Card_temp/savelistDesejos.php',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    // urlLocal,nome,id,capa,preco,titulo;
    body: jsonEncode(<String, String>{
       'titulo':titulo.toString(),
       'capa':capa.toString(),
       'id_book':id.toString(),
       'url_book':urlbook.toString(),
       'preco':preco.toString(),
       'descricao':descricao.toString(),
       'user_email':prefs.getString("email")
    }),

  );
    var encodeFirst = json.encode(response.body);
    var data = json.decode(encodeFirst);
    print(data);
 }

void cardDeliteItems(String id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();   
    final response = await http.post('https://www.visualfoot.com/api/Card_temp/delCardTemp.php',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    // urlLocal,nome,id,capa,preco,titulo;
    body: jsonEncode(<String, String>{
       'id_book':id.toString(),
        'user_email':prefs.getString("email")
       
    }),
  );

 }


//get data and store in local file
getdataSave(String url,String keyPath) async{
    final response = await http.get(url);
    if (response.statusCode == 200) {
      String datail = "";
      readContent(keyPath).then((value){
        datail = value;
      });

      if(datail.isEmpty || json.decode(datail) == json.decode(response.body)){
         writeContent(keyPath,(response.body));
      }
      return 1;
    } else {
      // return 0;
      throw Exception('Failed to load photos');
    }
}


 Future<String> get _localPath async {
    Directory appDocDir = Platform.isAndroid?await getExternalStorageDirectory():await getApplicationDocumentsDirectory();

    if (Platform.isAndroid) {
      Directory(appDocDir.path.split('Android')[0] + '${Constants.appName}').createSync();
    }
    return appDocDir.path;
}

 Future<File> _localFile(String key) async {
    final path = await _localPath;
    return File('$path/$key');
 }

Future<File> writeContent(String key,String content) async {
    // PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
    // if (permission != PermissionStatus.granted) {
    //  await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    //    File file = await _localFile(key);
    //    // Write the file
    //    return file.writeAsString(content);        
    //   }
      File file = await _localFile(key);
      print(file.path);
       // Write the file
      return file.writeAsString(content);   
}


Future<String> readContent(String key) async {
    try {
      File file = await _localFile(key);
      // Read the file
      String contents = await file.readAsString();
      // Returning the contents of the file
      return contents;
    } catch (e) {
      // If encountering an error, return
      return 'Error!';
    }
  }











 void desejosDeliteItems(String id) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();   
    final response = await http.post('https://www.visualfoot.com/api/Card_temp/delListDesejos.php',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    // urlLocal,nome,id,capa,preco,titulo;
    body: jsonEncode(<String, String>{
       'id_book':id.toString(),
       'user_email':prefs.getString("email")
    }),
  );
 }