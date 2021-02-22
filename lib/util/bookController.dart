import 'dart:convert';

import 'package:kioxkenewf/models/functions.dart';
import 'package:kioxkenewf/util/BookItem.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;


List<BookItem> item = [];

fileGet() async{
  List<BookItem> temp = [];
    readContent("dataAll.spv").then((value){
      temp = json.decode(value) as List;
  });
  return temp;
}

class BooksController{    
    List<BookItem> itemTile = fileGet();
  
}
