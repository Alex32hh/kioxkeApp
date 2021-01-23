import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:kioxkenewf/views/Login.dart';
import 'package:kioxkenewf/views/userdataEdit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerPage extends StatelessWidget {
    
  final String nomeUser,emailUser;
  final PageController pageviewController;
  DrawerPage(this.nomeUser,this.pageviewController,this.emailUser);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("images/pattner.jpg"),fit:BoxFit.cover)
            ),
            child: Column(
               mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage("https://png.pngtree.com/png-vector/20191003/ourmid/pngtree-user-login-or-authenticate-icon-on-gray-background-flat-icon-ve-png-image_1786166.jpg"),
                ),
                 Container(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  alignment: Alignment.center,
                 
                    child:Text(nomeUser.replaceAll('"', ""),style: TextStyle(color:Colors.white,fontSize: 18,fontWeight: FontWeight.bold))
                  )

                 ],
            ),

          ),
            listItem(Feather.user,"Minha Conta",() async{
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> UserEdit(prefs.getString("email"))));
                      }),
                            listItem(Feather.settings,"Definições",(){}),
                              listItem(Icons.power,"Sair",()async{
                                showAlertDialog(context,() async{
                                    logoff(context);
                                });
                              })
                    ],

                  ),

    );
  }
Widget listItem(IconData icon,String titulo,Function calback){
    return ListTile(
            leading: Icon(icon),
            title: Text("$titulo"),
            onTap: (){
              calback();
            },
      );
  }

 void logoff(BuildContext context)async{
   SharedPreferences preferences = await SharedPreferences.getInstance();
   await preferences.remove('email');
   await preferences.remove('nome');
   //adiocionar opcoes de remover os livros baixados
   Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) =>  Login()),(Route<dynamic> route) => false);
 }

 showAlertDialog(BuildContext context,Function callBack) {
  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Não"),
    onPressed:  () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = FlatButton(
    child: Text("Sim"),
    onPressed: (){
      callBack();
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Aviso"),
    content: Text("Tem a certeza que pretende terminar a Sessão"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}


}