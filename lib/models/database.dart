import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
class DatabaseHelper{
   static final _dbName = "kioxkedata.db";
   static final _dbVersion = 1;
   static final tableName = "desejosLista";

   static final colunid = "id";
   static final quantidade = "quantidade";

   DatabaseHelper._privateConstructor();
   static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
   String id, nome, descricao, preco, imageUrl, fileSrc, pathName, idident;

   Database _database;

   Future<Database> get database async{
     if(_database!=null) return _database;

     _database = await _initiateDatabase();
     return _database;
   }

  _initiateDatabase() async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path,_dbName);
   return await openDatabase(path,version: _dbVersion,onCreate: _onCreate);
  }
  
  Future _onCreate(Database db,int version){
     db.execute(
      '''CREATE TABLE $tableName(
      $colunid INTEGER PRIMARY KEY,
      nome TEXT NOT NULL,
      descricao TEXT  NOT NULL,
      preco TEXT NOT NULL,
      imageUrl TEXT NOT NULL,
      pathName TEXT NOT NULL,
      tipo INTEGER NOT NULL,
      idcloud INTEGER NOT NULL,
      idident TEXT NOT NULL,
      $quantidade INTEGER NOT NULL
    ) '''
    );
     db.execute(
      '''CREATE TABLE livrosBaixados(
      id INTEGER PRIMARY KEY,
      nomeBook TEXT NOT NULL,
      imgLink TEXT NOT NULL,
      bookLink TEXT  NOT NULL
    ) '''
    );
  }

   Future<int> insert(Map<String,dynamic> row) async{
     Database db = await instance.database;
     return await db.insert(tableName, row);
   }

   Future<List<Map<String,dynamic>>> queryAll(int separator) async{
     Database db = await instance.database;
     return await db.rawQuery('SELECT * FROM desejosLista WHERE tipo="$separator" ');
   }


  Future<int> update(Map<String,dynamic> row) async{
    Database db = await instance.database;
    int id = row['id'];
      return await db.update(tableName, row,where: '$id = ?',whereArgs: [id]);
  }

   Future<int> delete(int id) async{
       Database db = await instance.database;
       return await db.delete(tableName,where:'id=?',whereArgs: [id]);
   }

  Future<int> deleteBook(String id) async{
       Database db = await instance.database;
       return await db.delete(tableName,where:'nome=?',whereArgs: [id]);
  }

 Future<int> deleteBookAny(String id,String dbName) async{
       Database db = await instance.database;
       return await db.delete(dbName,where:'nome=?',whereArgs: [id]);
}


  
  void valuesupdate(int iddent,int qtd)async {
    // get a reference to the database
    // because this is an expensive operation we use async and await
    Database db = await DatabaseHelper.instance.database;

    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.colunid: iddent,
      DatabaseHelper.quantidade: qtd
    };

    // We'll update the first row just as an example
    int id = iddent;

    // do the update and get the number of affected rows
    int updateCount = await db.update(
        DatabaseHelper.tableName,
        row,
        where: '${DatabaseHelper.colunid} = ?',
        whereArgs: [id]);

     print(updateCount);
    // show the results: print all rows in the db
    // print(await db.query(DatabaseHelper.tableName));
  }



}