import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditSenha extends StatefulWidget {
  @override
  _EditSenhaState createState() => _EditSenhaState();
}
  
class _EditSenhaState extends State<EditSenha> {
   Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final senhaAntiga = TextEditingController();
    final senhaNova = TextEditingController();
    final senhaNovaConfirm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0.0,
        title: Text("Alterar Senha"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children:[
              inputlista("Senha Antiga",true,senhaAntiga,Icons.lock_open_outlined),
              inputlista("Nova Senha",true,senhaNova,Icons.security_outlined),
              inputlista("Confirmar Nova Senha",true,senhaNovaConfirm,Icons.lock_outlined),
              loginButton("Alterar Senha",Colors.green,Colors.white,() async{
              final SharedPreferences prefs = await _prefs;
              updateSenha(senhaAntiga.text,senhaNova.text,senhaNovaConfirm.text,prefs.getString("email"),context);
                // senhaAntiga.text = senhaNova.text = "";  
               }),
          ]
        ),
      ),
    );
  }

  Widget loginButton(String labelText,Color cor,Color corTexto,Function submit){
  return SizedBox(
          width: MediaQuery.of(context).size.width-20, //Full width
          height: 50,
    child:FlatButton(
       color: cor,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      onPressed:() async{
        submit();
       FocusScopeNode currentFocus = FocusScope.of(context);
       if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
    },
   padding:EdgeInsets.all(0.0),
   child:Text("$labelText",style: TextStyle(color:corTexto, fontSize: 13, fontWeight: FontWeight.bold),),
 )
   );
}

  Widget inputlista(String label,bool isObcure,TextEditingController controller,IconData icon){
  return Padding(
    padding: EdgeInsets.only(left: 10,right: 10,bottom: 5,top: 5),
    child:TextField(
    controller: controller,
    style: TextStyle(fontSize: 12.0, color: Colors.black),
    textAlign: TextAlign.left,
    obscureText: isObcure,
    decoration: InputDecoration(
      prefixIcon: Icon(icon),
      hintText: '$label',
      hintStyle: TextStyle(color:Colors.grey,fontWeight: FontWeight.bold,fontSize: 12),
      fillColor: Color.fromRGBO(237, 237, 237,1),
      filled: true,
      contentPadding: const EdgeInsets.all(10.0),
      border:OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(5.0),),
    ),

    ),
  )
  );
}

  updateSenha(String senhaAntigaTmp,String senhaNovaTmp,String senhaNovaConfir,String email,BuildContext context) async {

      if(senhaNovaConfir != senhaNovaTmp){
        showConfirm(context,"Pedido de alteracao de senha.","As Senhas Não sao Iguais!");
        return;
      }
      String url = 'http://www.visualfoot.com/api/editarSenha.php?use_senha_antiga=$senhaAntigaTmp&use_senha_nova=$senhaNovaTmp&use_email=$email';
      Response response = await get(url);
      if(response.body.contains("successfully") == true){
          showConfirm(context,"Pedido de alteracao de senha.","Senha Alterada com Sucesso!");
           senhaAntiga.text = "";
             senhaNova.text = "";
             senhaNovaConfirm.text = "";
      }else{
          showConfirm(context,"Pedido de alteracao de senha.","Senha antiga Errada");
             senhaAntiga.text = "";
             senhaNova.text = "";
             senhaNovaConfirm.text = "";

      }

    }

}

  