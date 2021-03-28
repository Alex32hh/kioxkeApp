import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:kioxkenewf/models/database.dart';
import 'package:kioxkenewf/util/const.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'offinedabase.dart';
import 'package:http/http.dart' as http;



List<String> itemsData = [];
List<String> itemsAutor = [];
List<String> itemsCategoria = [];



 void checkdata() async{
     SharedPreferences prefs = await SharedPreferences.getInstance();
  
     int value =  await getdataSave("https://www.visualfoot.com/api/?catType=Livros","dataAll.spv");
     int value2 = await getdataSave("https://www.visualfoot.com/api/acessos.php?tipo=populares","populares.spv");
    await getsaveLocal("https://www.visualfoot.com/api/Card_temp/getSaveData.php?identfy=tb_listdesejos&filtreId=id_user&filtre=${prefs.getString('email')}",0);
    await getsaveLocal("https://www.visualfoot.com/api/Card_temp/getSaveData.php?identfy=tb_carrinhobk&filtreId=id_user&filtre=${prefs.getString('email')}",1);
}


 void checkdataPub() async{
     int value =  await getdataSave("https://www.visualfoot.com/api/?catType=Livros","dataAll.spv");
     int value2 = await getdataSave("https://www.visualfoot.com/api/acessos.php?tipo=populares","populares.spv");
}


saveList(String id,String nome,String descricao,String preco,String imageUrl,String fileSrc,String pathName,String idident,int tipo) async {
   
    // List<Map<String,dynamic>> queryRowsCard = new List<Map<String,dynamic>>();
    // queryRowsCard = await DatabaseHelper.instance.queryAll(1);

    // for(int a=0;a < queryRowsCard.length;a++){
    //     if(queryRowsCard[a]['nome'] == nome){
    //       DatabaseHelper.instance.valuesupdate(queryRowsCard[a]['id'],queryRowsCard[a]['quantidade']+1);
    //       return;
    //     }
    // }
    
       
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

Future<List> getAllDoc(String url) async{
  Response response = await get(url);
  // sample info available in response
  int statusCode = response.statusCode;
  Map<String, String> headers = response.headers;
  String contentType = headers['content-type'];
  return jsonDecode(response.body) as List;
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
      // try {
      //   var image = await ImagePicker.pickImage(source: ImageSource.camera);

      // } catch (e) {
      //   print(e);
      // }
      // File file = await localFileget(keyPath);

      // if(File(file.path).existsSync()){
      writeContent(keyPath,(response.body));

      // }else
      //   writeContent(keyPath,(response.body));

      return 1;
    } else {
      // return 0;
      throw Exception('Failed to load photos');
    }
}

//get data and store in local file
getsaveLocal(String url,int tipo) async{

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.get(url);
    if (response.statusCode == 200) {
     
         List<Map<String,dynamic>> queryRowsCard = new List<Map<String,dynamic>>();
         List cloudItem = json.decode(response.body) as List;

         queryRowsCard = await DatabaseHelper.instance.queryAll(tipo);

         try{
          for(int a=0;a < cloudItem.length;a++){
                      if(queryRowsCard.length <= 0 && cloudItem.length >0){

                            int i = await DatabaseHelper.instance.insert({
                            'nome':''+cloudItem[a]['titulo'].toString(),
                            'descricao':cloudItem[a]['descricao'].toString().replaceAll(",", "").replaceAll('"',""),
                            'preco':cloudItem[a]['preco'].toString(),
                            'imageUrl':cloudItem[a]['capa'].toString(),
                            'pathName':cloudItem[a]['url_book'].toString(),
                            'tipo':tipo,
                            'idcloud':cloudItem[a]['id_book'],
                            'idident':(tipo==0?"desejos":"carrinho").toString(),
                            'quantidade':1
                            });
                            
                            print('valor inserido:$i');
                            if(tipo == 0)
                            prefs.setInt(cloudItem[a]['titulo'].toString()+"save",1);
                              else
                            prefs.setBool(cloudItem[a]['titulo'].toString()+'_carrinho', true);
                    }
                  }
         }catch(error){
            print(error);
         }
    
         

      return 1;
    } else {
      // return 0;
      throw Exception('Failed to load photos');
    }
}


 Future<String> get getlocalPath async {
  
    Directory appDocDir = Platform.isAndroid?await getExternalStorageDirectory():await getApplicationDocumentsDirectory();
    if (Platform.isAndroid) {
        Directory(appDocDir.path.split('Android')[0] + '${Constants.appName}').createSync();
      }

    return appDocDir.path;
}

 Future<File> localFileget(String key) async {
    final path = await getlocalPath;

    if(!File('$path/$key').existsSync()){
      File('$path/$key').createSync(recursive: true);
    }

    return File('$path/$key');
 }

Future<File> writeContent(String key,String content) async {
      File file = await localFileget(key);
      print(file.path);
       // Write the file
      return file.writeAsString(content);   
}


void deliteAlldata(String key) async {
      File file = await localFileget(key);
      file.deleteSync();
}

Future<String> readContent(String key) async {
    try {
      File file = await localFileget(key);
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


 sendOneCard({String id,String titulo,String capa,String preco,String encode,String total}) async{
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
    return 1;
 }