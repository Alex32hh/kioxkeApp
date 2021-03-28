import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:kioxkenewf/models/functions.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:kioxkenewf/util/bookModel.dart';
import 'package:kioxkenewf/views/detalhes.dart';
import 'package:provider/provider.dart';

class BooksList extends StatefulWidget {
  @override
  _BooksListState createState() => _BooksListState();
  final String pesquisa;
  BooksList({this.pesquisa});
}

class _BooksListState extends State<BooksList> {

    FocusNode _focus = new FocusNode();
    final TextEditingController _filter = new TextEditingController();
    List books = new List();
    List names = new List();
    String textSumited = "";

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Consumer<BooksModel>(
        builder: (context, item, child) {
          return  SingleChildScrollView(
        child:Container(
        width: MediaQuery.of(context).size.width,
        height:MediaQuery.of(context).size.height +(25*books.length),
        child: Column(
          children: [
             Padding(padding: EdgeInsets.all(10),
            child:TextField(
                onSubmitted:(a) async{
                   setState(() {
                      textSumited = a;
                    
                        if (!(textSumited.isEmpty)) {
                              List tempList = new List();
                              for (int i = 0; i < books.length; i++) {
                                if (books[i]['titulo'].toLowerCase().contains(textSumited.toLowerCase())) {
                                   if(!tempList.contains(books[i]))
                                    tempList.add(books[i]);

                                }
                              }
                              // names.clear();
                              names = tempList;
                            }
                            
                   });
                },
                controller:_filter,
                focusNode: _focus,
                textInputAction: TextInputAction.go,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                ),
                cursorColor: primaryColor,
                decoration: InputDecoration(
                  prefixIcon: _focus.hasFocus || _filter.value.text.toString().length >0?IconButton(icon: Icon(Icons.close, color: primaryColor,), onPressed: (){
                  
                    textSumited = "";
                   _focus.unfocus();
                     _filter.clear();
                  }):null,
                  alignLabelWithHint: false,
                  hintText: "O que Procura?",
                  hintStyle: TextStyle(
                    fontSize: 15
                  ),
                    filled: true,
                    fillColor: Colors.grey[200],
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                        EdgeInsets.only(left: 15, bottom: 16, top: 11, right: 15),
                    ),
              )

              ),

      textSumited!=""?
       Expanded(
         child: ListView.builder(
         itemCount:names == null ? 0 :names.length,
         itemBuilder: (BuildContext context, int index) {
           return new ListTile(
             
             title: Text(names[index]['titulo']),
              onTap: (){
                    Navigator.push(context,MaterialPageRoute(builder: (context) => Datalhes((){
                    Navigator.pop(context);
                  },names[index]['url'],names[index]['titulo'],names[index]['capa'],names[index]['autor'],names[index]['likes'],names[index]['preco'],names[index]['descricao'],names[index]['id'])));
                },
              );
            },
          )
       ):
      Expanded(
        //  width: MediaQuery.of(context).size.width,
        //  height:MediaQuery.of(context).size.height,
        child:GridView.count(
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2 ,
          childAspectRatio: MediaQuery.of(context).size.height / 840,
          children: List.generate(books.length,(index){
           return  OpenContainer(
                    openElevation:0.0,
                    closedElevation: 0.0,
                    transitionType:ContainerTransitionType.fade,
                    closedBuilder:(context,action){
                     return verticalBox(action,context,books[index]['titulo'],books[index]['capa'],books[index]['autor'],books[index]['likes'],books[index]['src'],books[index]['preco'],books[index]['descricao'],books[index]['id'],0);
                  } , openBuilder: (context,action){
                     return Datalhes(action,books[index]['src'], books[index]['titulo'], books[index]['capa'], books[index]['autor'], books[index]['likes'], books[index]['preco'], books[index]['descricao'], books[index]['id'],isFavorite:0,categoria:books[index]['categoria'],subcategoria:books[index]['subcate']);
                  });
        }),
      ),
      )

          ])
          )
      );
    }));
  }

  void getBooks() async{
     List temp = json.decode(await readContent("populares.spv")) as List;
     for(int a=0;a < temp.length;a++){
       if(temp[a]["categoria"] == widget.pesquisa)
          books.add(temp[a]);
          
         
     }
     
  }


}