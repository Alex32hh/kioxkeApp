import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:animations/animations.dart';
import 'package:badges/badges.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:kioxkenewf/components/Endrawer.dart';
import 'package:kioxkenewf/components/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:kioxkenewf/models/database.dart';
import 'package:kioxkenewf/models/functions.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:kioxkenewf/util/bookItem.dart';
import 'package:kioxkenewf/util/bookModel.dart';
import 'package:kioxkenewf/util/checkInternet.dart';
import 'package:kioxkenewf/views/detalhes.dart';
import 'package:kioxkenewf/views/tabs.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
  final String nome,email;
  HomeView(this.nome,this.email);
}
class _HomeViewState extends State<HomeView> {

  FocusNode _focus = new FocusNode();

  
  final TextEditingController _filter = new TextEditingController();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final PageController pageviewController = new PageController();
  List<Map<String,dynamic>> desejolist = []; 
  List<Map<String,dynamic>> carrinhodata = [];
  
  List list = [];
  List destaques = [];
  String _searchText = "";
  int _selectedIndex = 0;
  int dropDownValue = 0;

  List names = [];
  
  Function callbackOpen;

  //drop down menu
  String _dataSelection,_categoriaSelect,_autorSelect;

   @override
  void initState() {
    super.initState();
    checkInternet().checkConnection(context);
    getTotalDb();
    getFiles();
    stateSimple();
    activateCount(widget.email);
    _focus.addListener(_onFocusChange);
  }

    @override
  void dispose() {
    checkInternet().listener.cancel();
    super.dispose();
  }

  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    // getTotalDb();
    final model = Provider.of<BooksModel>(context, listen: false);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Color.fromRGBO(250, 250, 250, 0.9),
       title: Container(
         width: 90,
         height: 50,
         child:Image.asset('images/logoTex.png')),
       leading:  IconButton(icon: Icon(Icons.sort,color: primaryColor),onPressed: () => _scaffoldKey.currentState.openDrawer(),),
       actions: [
        Consumer<BooksModel>(
          builder: (context, item, child) {
              return InkWell(
                onTap:() => _scaffoldKey.currentState.openEndDrawer(),
                child:SizedBox(
                width: 45,
                child:item.docs.length <= 0 && item.docCart.length <= 0?Icon(Icons.more_vert,color: Colors.grey,):
                Badge(
                  padding:EdgeInsets.all(4),
                  alignment:Alignment.center,
                  position: BadgePosition.topEnd(top: 10,end: 10),
                  badgeColor:Colors.red,
                  child: Icon(Icons.more_vert,color: Colors.grey,),
                ) 
                )
              );

        }),
           
        ],
      ),
      body:PageView(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection:Axis.horizontal,
        controller: pageviewController,
        children: [
          _homeView(),
          Tabs(identify:"Livros"),
          Tabs(identify:"Revista"),
          Tabs(identify:"Jornal"),
          Tabs(identify:"Bd")
        ],
      ),
     bottomNavigationBar: BottomNavigationBar(
       type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon:  Icon(Feather.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon:Icon(Feather.book),
          label: 'Livros',
        ),
        BottomNavigationBarItem(
          icon:Icon(Feather.image),
          label: 'Revistas',
        ),
         BottomNavigationBarItem(
         icon:Icon(Feather.book_open),
          label: 'Jornais',
        ),
         BottomNavigationBarItem(
          icon:Icon(Feather.layout),
          label: 'BD',
        ),
      ],
      currentIndex: _selectedIndex, 
      selectedItemColor: primaryColor,
      onTap: _onItemTapped,
    ),
     drawer: DrawerPage(widget.nome,pageviewController,widget.email),
     endDrawer: EndDrawerPage(widget.nome,carrinhodata.length.toString()),
    );
  }

Widget _homeView(){
  return  RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh:_refresh,
        color: primaryColor,
        child:SingleChildScrollView(
        child:Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(padding: EdgeInsets.all(10),
            child:TextField(
                controller:_filter,
                focusNode: _focus,
                textInputAction: TextInputAction.go,
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                ),
                cursorColor: primaryColor,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                    borderRadius:BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  prefixIcon: _focus.hasFocus?IconButton(icon: Icon(Icons.close, color: primaryColor,), onPressed: (){
                    _filter.clear();
                   _focus.unfocus();
                  }):null,
                  alignLabelWithHint: false,
                  hintText: "O que Procura?",
                  hintStyle: TextStyle(
                    fontSize: 15
                  ),
                    filled: true,
                    fillColor: Colors.grey[200],

                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                        EdgeInsets.only(left: 15, bottom: 16, top: 11, right: 15),
                    ),
              )
              
              ),
          !_focus.hasFocus && _searchText==""?   
           mainContent():
           searchContent()
          ],

        )
      )
    ));
}

Widget searchContent(){
    if (!(_searchText.isEmpty)) {
    List tempList = new List();
    for (int i = 0; i < list.length; i++) {
      if (list[i]['titulo'].toLowerCase().contains(_searchText.toLowerCase())) {
        if(_dataSelection != null || _categoriaSelect != null || _autorSelect != null){

          if(_dataSelection == list[i]['data'])
           if(!tempList.contains(list[i]))
           tempList.add(list[i]);

           if(_autorSelect == list[i]['autor'])
             if(!tempList.contains(list[i]))
              tempList.add(list[i]);

           if(_categoriaSelect == list[i]['subcate'])
            if(!tempList.contains(list[i]))
            tempList.add(list[i]);

        }else
           tempList.add(list[i]);

      }
    }
    // names.clear();
    names = tempList;
  }
  return Container(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    
    child: Column(
      children:[
        Padding(
          padding: EdgeInsets.all(10),
          child:
         
         _filter.value.text.toString().length>0?Container(
           width: MediaQuery.of(context).size.width,
           height: 44,
           child: ListView(
          scrollDirection: Axis.horizontal,
          children:[
              DropdownButton<String>(
                hint: Text('Autor'), // Not necessary for Option 1
                value: _autorSelect,
                items: itemsAutor.map((String value) {
                  return  DropdownMenuItem<String>(
                    value: value,
                    child:  Text(value,style:TextStyle(color: primaryColor)),
                  );
                }).toList(),
                onChanged: (a) {
                  setState(() {
                    _autorSelect = a;
                  });
                },
              ),
              
               DropdownButton<String>(
                hint: Text('Categoria'), // Not necessary for Option 1
                value: _categoriaSelect,
                items: itemsCategoria.map((String value) {
                  return  DropdownMenuItem<String>(
                    value: value,
                    child:  Text(value,style:TextStyle(color: primaryColor)),
                  );
                }).toList(),
                onChanged: (a) {
                  setState(() {
                    _categoriaSelect = a;
                  });
                },
              ),

              DropdownButton<String>(
                hint: Text('Data'), // Not necessary for Option 1
                value: _dataSelection,
                items: itemsData.map((String value) {
                  return  DropdownMenuItem<String>(
                    value: value,
                    child:  Text(value,style:TextStyle(color: primaryColor)),
                  );
                  }).toList(),
                onChanged: (a) {
                  setState(() {
                    _dataSelection = a;
                  });
                },
              ),

              

          ]
          )
        ):SizedBox()
      ),
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
       )

      ]
    )
  );
}

stateSimple() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          // names = list;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

Widget mainContent(){
  return Container(
        width: MediaQuery.of(context).size.width,
        child: Consumer<BooksModel>(
        builder: (context, item, child) {
          return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
           pageTitle("Novos",context),
           Container(
            width: MediaQuery.of(context).size.width,
            height: 240,
             child: ListView.builder(
               scrollDirection: Axis.horizontal,
                itemCount: item.bookItem.length,
                itemBuilder: (BuildContext context, int index) {
                  return new OpenContainer(
                    openElevation:0.0,
                    closedElevation: 0.0,
                    transitionType:ContainerTransitionType.fade,
                    closedBuilder:(context,action){
                      callbackOpen = action;
                   return verticalBox(action,context, item.bookItem[index].titulo,item.bookItem[index].capa,item.bookItem[index].autor,item.bookItem[index].likes,item.bookItem[index].src,item.bookItem[index].preco,item.bookItem[index].descricao,item.bookItem[index].id,0);
                  } , openBuilder: (context,action){
                     return Datalhes(action,item.bookItem[index].src, item.bookItem[index].titulo, item.bookItem[index].capa, item.bookItem[index].autor, item.bookItem[index].likes, item.bookItem[index].preco, item.bookItem[index].descricao, item.bookItem[index].id,isFavorite:0,categoria:item.bookItem[index].categoria,subcategoria:item.bookItem[index].subcate);
                  });
                })
             ),

           pageTitle("Mais Acessados",context),
      
      Consumer<BooksModel>(
        builder: (context, item, child) {
         return Container(
            width: MediaQuery.of(context).size.width,
            height: 190 * double.parse(item.bookPopulares.length.toString()),
             child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: item.bookPopulares.length,
                itemBuilder: (BuildContext context, int index) {
                   return new OpenContainer(
                     openElevation:0.0,
                     closedElevation: 0.0,
                    closedBuilder:(context,action){
                       callbackOpen = action;
                       return horizontalBox(action,context,item.bookPopulares[index].titulo,item.bookPopulares[index].capa,item.bookPopulares[index].autor,item.bookPopulares[index].likes,item.bookPopulares[index].src,item.bookPopulares[index].preco,item.bookPopulares[index].descricao,item.bookPopulares[index].id,0);
                    },openBuilder: (context,action){
                       return Datalhes(action,item.bookPopulares[index].src, item.bookPopulares[index].titulo, item.bookPopulares[index].capa, item.bookPopulares[index].autor, item.bookPopulares[index].likes, item.bookPopulares[index].preco, item.bookPopulares[index].descricao, item.bookPopulares[index].id,isFavorite:0,categoria:item.bookPopulares[index].categoria,subcategoria:item.bookPopulares[index].subcate);
                    }

                   );
                 
                })
         );
      
         })

        ]);
         }
        )
      );
}

void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
    pageviewController.jumpToPage(index);
  });
}

Future<void>  _refresh() async{
  await getdataSave("https://www.visualfoot.com/api/?catType=Livros","dataAll");
  await getdataSave("https://www.visualfoot.com/api/acessos.php?tipo=populares","populares");
  setState(() {});
  getTotalDb();
  //  return  Navigator.pushReplacement(context,MaterialPageRoute(builder: (BuildContext context) => super.widget));
   //Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) =>  HomeView(widget.nome,widget.email)),(Route<dynamic> route) => false);
}

void getFiles() async{

  list = json.decode(await readContent("dataAll.spv")) as List;
  destaques = json.decode(await readContent("populares.spv")) as List;
  
  for(int x =0;x < list.length;x++){
    if(!itemsData.contains(list[x]['data']))
        itemsData.add(list[x]['data']);

    if(!itemsAutor.contains(list[x]['autor']))
        itemsAutor.add(list[x]['autor']);

    if(!itemsCategoria.contains(list[x]['subcate']))
        if(list[x]['subcate'].toString().contains("/"))
           for(int a=0;a< list[x]['subcate'].toString().split("/").length;a++){
              itemsCategoria.add(list[x]['subcate'].toString().split("/")[a]);
           }
        else
          itemsCategoria.add(list[x]['subcate']);

  }


}


void getTotalDb() async{
    desejolist = await DatabaseHelper.instance.queryAll(0);
    carrinhodata= await DatabaseHelper.instance.queryAll(1);
    setState(() {
      
    });
 }


void activateCount(String email) async{

  final response =await http.get("https://www.visualfoot.com/api/getUserData.php?email=$email");
    String isd = "";
    if (response.statusCode == 200) {
     
     List userdataList = json.decode(response.body) as List;

     setState(() {
       isd = userdataList[0]['active'];
     });

    } else {
      throw Exception('Failed to load photos');
    }

    if(isd != "0")
      return;

    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          padding:EdgeInsets.all(10),
           content:Container(
            height: 35,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Verifique o seu e-mail",textAlign:TextAlign.center,),
              GestureDetector(
                  onTap: () async{
                  final SharedPreferences prefs = await _prefs;
                  showNormalAlert(context,(){
                    mailConfirmation(prefs.getString("email"));
                  },
                  "Confirmação",
                  "Tem certeza que deseja reenviar o e-mail?"); 
                },
                child: Text("Não recebeu o e-mail de verificação?",textAlign:TextAlign.left,style: TextStyle(fontSize: 12,  decoration: TextDecoration.underline,)) ,)
            ],
          ),
        ),
           backgroundColor: Colors.redAccent, duration: Duration(minutes: 30)),
    );
    
    }



void _onFocusChange(){
    print("Focus: "+_focus.hasFocus.toString());
  }


}
