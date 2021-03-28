import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kioxkenewf/models/database.dart';
import 'package:kioxkenewf/models/functions.dart';
import 'package:kioxkenewf/util/bookItem.dart';



class BooksModel extends ChangeNotifier{
   
   List<BookItem> _docs = [];
   List<BookItem> get docs => _docs;

   List<BookItem> _bookPopulares = [];
   List<BookItem> get bookPopulares => _bookPopulares;

   List<BookItem> _docCart = [];
   List<BookItem> get docCart => _docCart;

   List<BookItem> _bookItem = [];
   List<BookItem> get bookItem => _bookItem;

   BooksModel(){
      fetchAndSetWorkouts();
      getCard();
      bookGet();
      booktMostWotch(); 
   }

 

   Future<List<BookItem>> fetchAndSetWorkouts() async {
        final dataList = await DatabaseHelper.instance.queryAll(0);
       _docs = dataList.map(
          (item) => BookItem(
            id: item['id'].toString(),
            titulo: item['nome'],
            preco:item['preco'],
            descricao:item['descricao'],
            src:item['pathName'],
            capa:item['imageUrl'],
            tipo:0,
            idCloud:item['idcloud']
          ),
        ).toList();
        notifyListeners();
  }

   Future<List<BookItem>> getCard() async {
       final dataList = await DatabaseHelper.instance.queryAll(1);
       _docCart = dataList.map(
          (item) => BookItem(
            id: item['id'].toString(),
            titulo: item['nome'],
            preco:item['preco'],
            descricao:item['descricao'],
            src:item['pathName'],
            capa:item['imageUrl'],
          ),
        ).toList();
        notifyListeners();
   }

   void deliteBookDesejo(int id) async{
      int value = await DatabaseHelper.instance.delete(id);
      notifyListeners();
      fetchAndSetWorkouts();
      print(docs.length);
   }
   void deliteBookCard(int id) async{
      int value = await DatabaseHelper.instance.delete(id);
      notifyListeners();
      getCard();
   }

   void addbookFile(String id, String nome, String descricao, String preco, String imageUrl, String fileSrc, String pathName, String idident, int tipo){
      saveList(id,nome,descricao,preco,imageUrl,fileSrc,"desejos","desejos",0);
      fetchAndSetWorkouts();
      notifyListeners();
   }

   void addCart(String id, String nome, String descricao, String preco, String imageUrl, String fileSrc, String pathName, String idident, int tipo){
      saveList(id,nome,descricao,preco,imageUrl,fileSrc,"carrinho","carrinho",1);
      getCard();
      notifyListeners();
   }

   Future bookGet() async{
     List temList = json.decode(await readContent("dataAll.spv")) as List;
      _bookItem = temList.map(
          (item) => BookItem(
             id:item["id"],
            titulo:item["titulo"], 
            preco:item["preco"], 
             descricao:item["descricao"], 
             data:item["data"], 
             likes:item["likes"], 
             views:item["views"], 
             src:item["src"], 
             capa:item["capa"], 
             autor:item["autor"], 
             categoria:item["categoria"], 
             subcate:item["subcate"], 
             isFavorite:item["IsFavorite"]==0?true:false,  
          ),
        ).toList();
        notifyListeners();
   }


   Future booktMostWotch() async{
     List temList = json.decode(await readContent("populares.spv")) as List;
      _bookPopulares = temList.map(
          (item) => BookItem(
             id:item["id"],
            titulo:item["titulo"], 
            preco:item["preco"], 
             descricao:item["descricao"], 
             data:item["data"], 
             likes:item["likes"], 
             views:item["views"], 
             src:item["src"], 
             capa:item["capa"], 
             autor:item["autor"], 
             categoria:item["categoria"], 
             subcate:item["subcate"], 
             isFavorite:item["IsFavorite"]==0?true:false,  
          ),
        ).toList();
        notifyListeners();
   }


}


