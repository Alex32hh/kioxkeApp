import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kioxkenewf/models/functions.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:http/http.dart' as http;
import 'package:kioxkenewf/views/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  bool isloading = false;
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
   Future<String> _email,_nome;


  final _nomeUsuario = TextEditingController();
  final _sobrenomeUsuario = TextEditingController();
  final _emailController = TextEditingController();
  final _numeroTelemovel = TextEditingController();
  final _morada = TextEditingController();
  final _senhaController = TextEditingController();
  final _senhaControllerConfirmar = TextEditingController();
  final _scafoldkey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafoldkey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("Criar Conta"),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child:Container(
        child: Column(
          children: [
             SizedBox(
              height: 5,
            ),
            inputlista("Primero Nome *",false,_nomeUsuario,Icons.person,TextInputType.text,false),
            inputlista("Último Nome *",false,_sobrenomeUsuario,Icons.person_outline,TextInputType.text,false),
            //verificar sem o email existe
            inputlista("Email *",false,_emailController,Icons.alternate_email,TextInputType.emailAddress,true),
            inputlista("Morada",false,_morada,Icons.pin_drop,TextInputType.text,false),
            inputlista("+244",false,_numeroTelemovel,Icons.phone,TextInputType.number,false),
            inputlista("Senha *",true,_senhaController,Icons.lock_outline,TextInputType.text,false),
            inputlista("Confirmar Senha *",true,_senhaControllerConfirmar,Icons.lock,TextInputType.text,false),
             SizedBox(
              height: 5,
            ),
            loginButton(context,"CRIAR CONTA",Colors.amber,Colors.white,(){
                 _cadastrar();
               setState(() {
                   isloading = true;
               });
                 
            },),
             SizedBox(
              height: 10,
            ),
            loginButton(context,"JÁ TEM UMA CONTA?",Colors.green,Colors.white,(){
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => Login()));
            },),
             SizedBox(
              height: 10,
            ),
          ],
        )
      ),
      )
    );
  }

  Widget inputlista(String label,bool isObcure,TextEditingController controler,IconData icon,TextInputType type,bool isimportant){
  return Padding(
    padding: EdgeInsets.only(left: 10,right: 10,bottom: 5,top: 5),
    child:TextFormField(
    validator: isimportant == true?(val) => val.isEmpty || !val.contains("@")? "enter a valid eamil":null:null,
    keyboardType: type,
    controller: controler,
    style: TextStyle(fontSize: 15.0, color: Colors.white),
    textAlign: TextAlign.left,
    obscureText: isObcure,
    decoration: InputDecoration(
      suffixIcon: Icon(icon),
      //aplicar mais tarde
      // prefixIcon: Icon(Icons.warning,color: Colors.red, size: 15,),
      hintText: '$label',
      hintStyle: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),
      fillColor: Color.fromRGBO(175, 175, 175, .5),
      filled: true,
      contentPadding: const EdgeInsets.all(18.0),
      border:OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(5.0),),
    ),

    ),
  )
  );

}

  Widget loginButton(BuildContext context, String labelText,Color cor,Color corTexto,Function submit){
  return SizedBox(
          width: MediaQuery.of(context).size.width-20, //Full width
          height: 55,
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
   child:isloading? SpinKitWave(color: Colors.white,size: 40.0,):
   Text("$labelText",style: TextStyle(color:corTexto, fontSize: 13, fontWeight: FontWeight.bold),),
 )
   );
}

  Future<void> _cadastrar() async{
     if(_senhaController.text == "" || _emailController.text == ""){
         falha("Preencha os campos obrigatórios assinalados com *");
       return;
     }
     if(_senhaController.text !=  _senhaControllerConfirmar.text){
         falha("As senhas não são Iguais");
       return;
     }

    
     final response = await http.post('https://www.visualfoot.com/api/conta.php',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
       'use_nome': _nomeUsuario.text,
       'use_sobrenome': _sobrenomeUsuario.text,
       'use_email': _emailController.text,
       'use_telemovel': _numeroTelemovel.text.toString(),
       'use_morada': _morada.text.toString(),
       'use_senha': _senhaController.text,
    }),

  );

    var encodeFirst = json.encode(response.body);
    var data = json.decode(encodeFirst);
    
    if(data.toString().contains("email ja existe")){
      alertRecoperarSenha(context,(){
        //aqui vai a opcao de recoperacao da senha depois

      },"Aviso!","Já Existe uma conta com este email");
      setState(() {
        isloading = false;
      });
      return;
    }

    if(data.toString().replaceAll('"', '') == 'erro')
    {
      falha("Dados invalidos ,Porfavor insere os dados correctamente");
    }else{
      print(data.toString());

        if(data == "erro"){
           falha("Dados invalidos ,Porfavor insere os dados correctamente");
         return;
        }
      if(!data.toString().contains(','))
      return;
      sucesso(data.toString().split(',')[0],data.toString().split(',')[1]);   
    }
  }

  void sucesso(String nome,String email){
      _scafoldkey.currentState.showSnackBar(
        SnackBar( content: Text("Cadastro feito com sucesso!"),
        backgroundColor: Colors.green, duration: Duration(seconds: 3),)
      );
      Future.delayed(Duration(seconds: 2)).then((_){
          setState(() {
            isloading = false;
            });
           mailConfirmation(_emailController.text);
          _saveSession();
          Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) =>  HomeView(nome,email)),(Route<dynamic> route) => false);
      });
   
    }

  Future<void> _saveSession() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _email = prefs.setString("email", _emailController.text).then((bool success) {
        return  _email;
      });
        _nome = prefs.setString("nome", _nomeUsuario.text+" "+_sobrenomeUsuario.text).then((bool success) {
        return  _nome;
      });
    });
  }

  void falha(String message){
        _scafoldkey.currentState.showSnackBar(
        SnackBar( content: Text("$message",textAlign:TextAlign.right,),
           backgroundColor: Colors.redAccent, duration: Duration(seconds: 4),)
      );
       Future.delayed(Duration(seconds: 2)).then((_){
         setState(() {
            isloading = false;
         });
      });
    
  }




}