import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:http/http.dart' as http;
import 'package:kioxkenewf/views/tabs/booksList.dart';

class Tabs extends StatefulWidget {
  @override
  _TabsState createState() => _TabsState();
  final String identify;
  Tabs({this.identify});
}

class _TabsState extends State<Tabs> {

  List colecao = new List();
  List populares = new List();
  List maislidos = new List();

 bool isLoading = false;

 @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar:  PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child:TabBar(
          labelColor: Colors.black,
          indicatorColor:primaryColor,
        tabs: [
          Tab(text: "Todos",),
          Tab(text: "Populares",),
          Tab(text: "Categorias",),
        ],
      ),
    ),
  
  body: TabBarView(
  children: [
    BooksList(pesquisa:widget.identify),
    Icon(Icons.warning),
    // _boxView(context,"A","B","C"),
    Icon(Icons.warning),
  ],    
    ),
  ),
  
); 
  }

}