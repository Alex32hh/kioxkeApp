import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kioxkenewf/main.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:kioxkenewf/views/cadastro.dart';
import 'package:kioxkenewf/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kioxkenewf/models/functions.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

   Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
   Future<String> _email,_nome;

    final _formKey = GlobalKey<FormState>();
    final _senhaController = TextEditingController();
    final _emailController = TextEditingController();

    final _scafoldkey = GlobalKey<ScaffoldState>();
    bool isloading = false,isbosecured = true;

    Future<void> _login() async{
     if(_senhaController.text == "" || _emailController.text == ""){
         falha();
       return;
     }
     final response = await http.post('https://www.visualfoot.com/api/login.php',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
       'use_email': _emailController.text,
       'use_senha': _senhaController.text,
    }),

  );

    var encodeFirst = json.encode(response.body);
    var data = json.decode(encodeFirst);

    if(data.toString().replaceAll('"', '') == 'erro')
    {
      falha();
    }else{
      
      print(data.toString());

        if(data == "erro"){
           falha();
         return;
        }
      if(!data.toString().contains(','))
      return;
      sucesso(data.toString().split(',')[0],data.toString().split(',')[1]);   
    }
  }
   
  Future<void> _checkSession(String nome,String email) async {
       final SharedPreferences prefs = await _prefs;
    //final int counter = (prefs.getInt('counter') ?? 0) + 1;
      if(prefs.getString("email") != null){
         print(prefs.getString("email")+prefs.getString("nome"));
         await checkdata();
         Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) =>  HomeView(prefs.getString("nome"),prefs.getString("email"))),(Route<dynamic> route) => false);
      }
    }

  Future<void> _saveSession(String nome) async {
    final SharedPreferences prefs = await _prefs;
    //final int counter = (prefs.getInt('counter') ?? 0) + 1;

    setState(() {
      _email = prefs.setString("email", _emailController.text).then((bool success) {
        return  _email;
      });
        _nome = prefs.setString("nome", nome).then((bool success) {
        return  _nome;
      });
    });
  }

@override
  void initState() {
    super.initState();
      _email = _prefs.then((SharedPreferences prefs) {
      return (prefs.getString('email'));
    });
      _nome = _prefs.then((SharedPreferences prefs) {
      return (prefs.getString('nome'));
    });

     _checkSession(_nome.toString(),_email.toString());
  }


  @override
Widget build(BuildContext context) {
  return Scaffold( 
    key: _scafoldkey,
    body:SingleChildScrollView(
          child:Container(
          width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            // color:Color.fromRGBO(115, 115, 115, 1)
          ),
          child: Column(
            children: [

          Container(
             width: MediaQuery.of(context).size.width,
             height: MediaQuery.of(context).size.height /2.6,
             alignment: Alignment.topCenter,
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               mainAxisAlignment: MainAxisAlignment.center,
              children: [
               logo(),
               textLogo()
              ],
             ),
            ),

            Container(
             width: MediaQuery.of(context).size.width,
            //  height: MediaQuery.of(context).size.height /2.4,
             child: Container(
               child:Column(
               children: [
                 Form(
                 key: _formKey,
                 child: Column(
                 children: <Widget>[
                     Text(""),
                     inputlista("Email",false,TextInputType.emailAddress),
                     senhaInput("Palavra-Passe"),
                     
                     contButton("Esqueceu a senha?",Colors.black,(){
                          Navigator.push(context,MaterialPageRoute(builder: (context) => Cadastro()));
                     }),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         socialDott("images/faceLogo.png",Colors.blue),
                          socialDott("images/goLogo.png",Colors.white),
                           socialDott("images/apLogo.png",Colors.grey[800])
                      ],
                    ),

                     SizedBox(
                       height: 20,
                     ),

                     loginButton("Iniciar Sessao",Color.fromRGBO(253, 172, 66,1),true,Colors.white,(){
                        _login();
                         setState(() {
                          isloading = true;
                         });
                     }),
                    
                     contButton("Não tem Conta? Crie uma aqui",primaryColor,(){
                          Navigator.push(context,MaterialPageRoute(builder: (context) => Cadastro()));
                     })

                   ]
                    )
                 )
               ],
             ),
            ))
            ], 
          ),
        )
  )
);
}

Widget loginButton(String labelText,Color cor,bool isSubmited,Color corTexto,Function submit){
  return Padding(
    padding: EdgeInsets.all(10),
    child: SizedBox(
      width: 60,
      height: 60,
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
   child:isSubmited? isloading? SpinKitWave(color: Colors.white,size: 40.0,):
   Icon(Feather.arrow_right_circle,color: Colors.white,):
   Text("$labelText",style: TextStyle(color:corTexto, fontSize: 13, fontWeight: FontWeight.bold),),
 )
   )
   );
}


Widget contButton(String labelText,Color corTexto,Function submit){
  return Padding(
    padding: EdgeInsets.all(4),
    child: SizedBox(
      width: MediaQuery.of(context).size.width/2,
      height: 30,
      child:TextButton(
     style: ButtonStyle(
      
     ),
      onPressed:() async{
        submit();
       FocusScopeNode currentFocus = FocusScope.of(context);
       if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
    },
   child:Text("$labelText", textAlign:TextAlign.end , style: TextStyle(color:corTexto, fontSize: 13),),
 )
   )
   );
}


Widget socialDott(String imgUrl,Color colorData){
  return Padding(
    padding: EdgeInsets.all(5),
    child: SizedBox(
      width: MediaQuery.of(context).size.width/3.4,
      height: 40,
      child:FlatButton(
       color:colorData,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed:(){},
    padding:EdgeInsets.all(0.0),
    child:Image.asset(imgUrl,width: 25,height: 25,)
 )
   )
   );
}

Widget logo(){
  return Container(
     width:200,
     height:100,
     alignment: Alignment.center,
     child: Image.asset('images/logo.png')
  );
}

Widget textLogo(){
  return Container(
    // color: Colors.red,
    alignment: Alignment.center,
    width: MediaQuery.of(context).size.width-10,
    height: 60,
    child: Text(' A sua livraria na palma da mão. \n Inicio de sessão',textAlign:TextAlign.center, style: TextStyle(color:Color.fromRGBO(253, 172, 66,1), fontSize: 13)),
  );
}

Widget inputlista(String label,bool isObcure,TextInputType typeKeib){
  return Padding(
    padding: EdgeInsets.only(left: 10,right: 10,bottom: 10,top: 10),
    child:TextField(
    keyboardType: typeKeib,
    controller: isObcure?_senhaController:_emailController,
    style: TextStyle(fontSize: 15.0, color: Colors.white),
    textAlign: TextAlign.left,
    obscureText: isObcure,
    decoration: InputDecoration(
      suffixIcon: isObcure?IconButton(icon: Icon(Feather.eye,color: Colors.grey,), onPressed: (){
        setState(() {
          isObcure = false;
        });
      }):Icon(Icons.person,color: Colors.grey,),
      hintText: '$label',
      hintStyle: TextStyle(color:Colors.grey),
      fillColor: Color.fromRGBO(175, 175, 175, .2),
      filled: true,
      contentPadding: const EdgeInsets.all(15.0),
      border:OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(5.0),),
    ),

    ),
  )
  );
}

Widget senhaInput(String label){
  return Padding(
    padding: EdgeInsets.only(left: 10,right: 10,bottom: 10,top: 10),
    child:TextField(
    controller: _senhaController,
    keyboardType: TextInputType.text,
    style: TextStyle(fontSize: 15.0, color: Colors.white),
    textAlign: TextAlign.left,
    obscureText: isbosecured,
    decoration: InputDecoration(
      suffixIcon:IconButton(icon: Icon(isbosecured == true?Icons.visibility_off:Icons.visibility,color: Colors.grey,), onPressed: (){
        setState(() {
         isbosecured = !isbosecured; 
        });
      }),
      hintText: '$label',
      hintStyle: TextStyle(color:Colors.grey),
      fillColor: Color.fromRGBO(175, 175, 175, .2),
      filled: true,
      contentPadding: const EdgeInsets.all(15.0),
      border:OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(5.0),),
    ),

    ),
  )
  );

}

void sucesso(String nome,String email) async {
     
      _scafoldkey.currentState.showSnackBar(
        SnackBar( content: Text("Login feito com sucesso!"),
        backgroundColor: Colors.green, duration: Duration(seconds: 3),)
      );
      _saveSession(nome);

      await checkdataPub();
      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) =>  Main()),(Route<dynamic> route) => false);
   
    }

void falha(){
        // ignore: deprecated_member_use
        _scafoldkey.currentState.showSnackBar(
        SnackBar( content: Text("Dados inválidos. Por favor inserir dados corretos."),
           backgroundColor: Colors.redAccent, duration: Duration(seconds: 4),)
      );
       Future.delayed(Duration(seconds: 2)).then((_){
         setState(() {
            isloading = false;
         });
      });
    
    }

}

