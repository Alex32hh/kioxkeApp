import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';


class DatabaseHelperLocal{
   //verificar a criacao de conta do modo singular/para cada usuario.
   //incript do banco de dados local...
   static final _dbName = "kioxkedata.db";
   static final _dbVersion = 1;
   static final tableName = "livrosBaixados";

   DatabaseHelperLocal._privateConstructor();
   static final DatabaseHelperLocal instance = DatabaseHelperLocal._privateConstructor();

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

   Future<List<Map<String,dynamic>>> queryAll() async{
     Database db = await instance.database;
     return await db.rawQuery('SELECT * FROM $tableName ');
   }

  Future<int> update(Map<String,dynamic> row) async{
    Database db = await instance.database;
    int id = row['id'];
    return await db.update(tableName, row,where: '$id = ?',whereArgs: [id]);
  }

   Future<int> deleteBook(String id) async{
       Database db = await instance.database;
       return await db.delete(tableName,where:'bookLink=?',whereArgs: [id]);
   }



}