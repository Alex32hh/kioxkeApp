import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:animations/animations.dart';
import 'package:badges/badges.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kioxkenewf/components/Endrawer.dart';
import 'package:kioxkenewf/components/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:kioxkenewf/models/database.dart';
import 'package:kioxkenewf/models/functions.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:kioxkenewf/util/checkInternet.dart';
import 'package:kioxkenewf/views/detalhes.dart';
import 'package:kioxkenewf/views/tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
  final String nome,email;
  HomeView(this.nome,this.email);


}


class _HomeViewState extends State<HomeView> {

  final TextEditingController _filter = new TextEditingController();


  final storage = new FlutterSecureStorage();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final PageController pageviewController = new PageController();
  List<Map<String,dynamic>> desejolist = new List<Map<String,dynamic>>(); 
  List<Map<String,dynamic>> carrinhodata = new List<Map<String,dynamic>>();
  
  List list = List();
  List destaques = List();
  String _searchText = "";
  int _selectedIndex = 0;

  List names = new List();
  
  Function callbackOpen;
   @override
  void initState() {
    super.initState();
    checkInternet().checkConnection(context);
    getTotalDb();
    getFiles();
    stateSimple();
    activateCount(widget.email);
  }

    @override
  void dispose() {
    checkInternet().listener.cancel();
    super.dispose();
  }

  var isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: primaryColor,
       title: Text("Kioxke"),
       leading:  IconButton(icon: Icon(Icons.sort), onPressed: () => _scaffoldKey.currentState.openDrawer(),),
       actions: [
           InkWell(
             onTap:() => _scaffoldKey.currentState.openEndDrawer(),
             child:SizedBox(
             width: 45,
             child:desejolist.length <= 0 && carrinhodata.length <= 0?Icon(Icons.more_vert,color: Colors.white,):
             Badge(
              padding:EdgeInsets.all(4),
              alignment:Alignment.center,
              position: BadgePosition.topEnd(top: 10,end: 10),
              badgeColor:Colors.red,
              child: Icon(Icons.more_vert,color: Colors.white,),
            )
             
             )
            ),

        ],
      ),
      body:PageView(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection:Axis.horizontal,
        controller: pageviewController,
        children: [
          _homeView(),
          Tabs()
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
     endDrawer: EndDrawerPage(widget.nome,carrinhodata.length.toString(),desejolist.length.toString()),
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
                textInputAction: TextInputAction.go,
                onSubmitted: (value) {
                    print("search");
                },
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                ),
                cursorColor: primaryColor,
                decoration: InputDecoration(
                  prefixIcon: _filter.value.text.length > 0?IconButton(icon: Icon(Icons.close, color: primaryColor,), onPressed: (){
                    _filter.clear();
                    // _filter.dispose();
                  }):null,
                  alignLabelWithHint: false,
                  hintText: "O que Procura?",
                  hintStyle: TextStyle(
                    fontSize: 15
                  ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    // prefix: IconButton(icon: Icon(Icons.close_rounded, color: primaryColor,), onPressed: (){}),
                    suffixIcon: IconButton(icon: Icon(Icons.dashboard_outlined, color: primaryColor,), onPressed: (){}),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding:
                        EdgeInsets.only(left: 15, bottom: 16, top: 11, right: 15),
                    ),
              )),
           _filter.value.text.length <= 0?   
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
        tempList.add(list[i]);
      }
    }
    // names.clear();
    names = tempList;
  }
  return Container(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    
    child:ListView.builder(
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
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
           pageTitle("Novos",context),
           Container(
            width: MediaQuery.of(context).size.width,
            height: 240,
             child: ListView.builder(
               scrollDirection: Axis.horizontal,
                itemCount: destaques.length,
                itemBuilder: (BuildContext context, int index) {
                  return new OpenContainer(
                    openElevation:0.0,
                    closedElevation: 0.0,
                    transitionType:ContainerTransitionType.fade,
                    closedBuilder:(context,action){
                      callbackOpen = action;
                   return verticalBox(action,context,destaques[index]['titulo'],destaques[index]['capa'],destaques[index]['autor'],destaques[index]['likes'],destaques[index]['src'],destaques[index]['preco'],destaques[index]['descricao'],destaques[index]['id'],0);
                  } , openBuilder: (context,action){
                     return Datalhes(action,destaques[index]['src'], destaques[index]['titulo'], destaques[index]['capa'], destaques[index]['autor'], destaques[index]['likes'], destaques[index]['preco'], destaques[index]['descricao'], destaques[index]['id'],isFavorite:0);
                  });
                })
             ),

           pageTitle("Mais Acessados",context),

         Container(
            width: MediaQuery.of(context).size.width,
            height: 190 * double.parse(list.length.toString()),
             child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index) {
                   return new OpenContainer(
                     openElevation:0.0,
                     closedElevation: 0.0,
                    closedBuilder:(context,action){
                       callbackOpen = action;
                       return horizontalBox(action,context,list[index]['titulo'],list[index]['capa'],list[index]['autor'],list[index]['likes'],list[index]['src'],list[index]['preco'],list[index]['descricao'],list[index]['id'],0);
                    },openBuilder: (context,action){
                       return Datalhes(action,list[index]['src'], list[index]['titulo'], list[index]['capa'], list[index]['autor'], list[index]['likes'], list[index]['preco'], list[index]['descricao'], list[index]['id'],isFavorite:0);
                    }

                   );
                 
                })
         )
      
          ]));
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
  String datall = await storage.read(key:"dataAll");
  list =json.decode(datall)  as List;

  String dataPopulares = await storage.read(key:"populares");
  destaques =json.decode(dataPopulares)  as List;
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


}
