import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:kioxkenewf/views/Cardcompras.dart';
import 'package:kioxkenewf/views/biblioteca/biblioteca.dart';
import 'package:kioxkenewf/views/biblioteca/historicoCompra.dart';
import 'package:kioxkenewf/views/desejosLista.dart';


class EndDrawerPage extends StatelessWidget {
    
    final String nomeUser,cartTotalProduts,listadesejosCount;
    EndDrawerPage(this.nomeUser,this.cartTotalProduts,this.listadesejosCount);


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 200,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("images/pattner.jpg"),fit:BoxFit.cover)
            ),
            child: FlatButton(onPressed: (){
               Navigator.pop(context);
               Navigator.push(context,MaterialPageRoute(builder: (context) => CardCompras()));   
            }, child:Column(
               mainAxisAlignment: MainAxisAlignment.end,
               crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Badge(
                  position: BadgePosition.topEnd(),
                  badgeColor:Colors.red,
                  badgeContent: Text((cartTotalProduts).toString(),style: TextStyle(color: Colors.white),),
                  child: Icon(Icons.shopping_cart,size: 80, color: Colors.white,),
                  ),
               
                 Container(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  alignment: Alignment.centerRight,
                      child:Text("Ver Carrinho",style: TextStyle(color: Colors.white, fontSize: 20))
                      )
                 ],
            ),)

          ),
          
         listItem("Lista de Desejos",Feather.flag,int.parse(listadesejosCount),(){
             Navigator.pop(context);
            Navigator.push(context,MaterialPageRoute(builder: (context) => WishlistWidget()));
         }),
         listItem("Biblioteca",Feather.bookmark,0,(){
            Navigator.pop(context);
            Navigator.push(context,MaterialPageRoute(builder: (context) => Biblioteca()));
         }),
         listItem("Historico",Icons.history,0,(){
            Navigator.pop(context);
            Navigator.push(context,MaterialPageRoute(builder: (context) => Historico()));
           
         }),
        ],

      ),

    );
  }

  Widget listItem(String titulo,IconData iconPrefix,int valueCont,Function submit){
    return ListTile(
            title: Text("$titulo"),
            trailing:valueCont > 0?Badge(
                  position: BadgePosition.topEnd(),
                  badgeColor:Colors.red,
                  badgeContent: Text((valueCont).toString(),style: TextStyle(color: Colors.white),),
                  child: Icon(iconPrefix),
                  ):Icon(iconPrefix),
            onTap: (){
              submit();
            },
      );
  }
}