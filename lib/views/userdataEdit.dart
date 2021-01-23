import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:kioxkenewf/models/viewStyles.dart';
import 'package:http/http.dart' as http;
import 'package:kioxkenewf/views/alterarsenha.dart'; 

class UserEdit extends StatefulWidget {

  final String email;

  UserEdit(this.email);
   
  @override
  _UserEditState createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
  
   List userdataList = new List();
 
  final nomeedit = TextEditingController();
  final sobreNomedit = TextEditingController();
  final emailedit = TextEditingController();
  final numeroedit = TextEditingController();
  final moradaedit = TextEditingController();
  final localizacaoedit = TextEditingController();
  bool isloading = false;
  @override
  void initState() {
    super.initState();

    getUserData(widget.email);

  }



  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0.0,
        title: Text("Editar Conta"),
      ),
      body: SingleChildScrollView(child:Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              SizedBox(height: 20,),
              Badge(
                // position: BadgePosition.topEnd(),
                // badgeColor:Colors.white,
                // badgeContent:Icon(Icons.edit,color: primaryColor,),
                child:Container(
                width: 130,
                height: 120,
              decoration: BoxDecoration(
                color:Colors.blueAccent,
                borderRadius: BorderRadius.all(Radius.circular(12)),
                image: DecorationImage(image: NetworkImage("https://png.pngtree.com/png-vector/20191003/ourmid/pngtree-user-login-or-authenticate-icon-on-gray-background-flat-icon-ve-png-image_1786166.jpg"),fit: BoxFit.cover)
              ),
              ),),
               SizedBox(height: 20,),
              inputlista("Carregando...",false,nomeedit,Icons.person,true), 
              inputlista("Carregando...",false,sobreNomedit,Icons.person_outline_outlined,true),
              inputlista("Carregando...",false,emailedit,Icons.alternate_email,false),
              inputlista("Carregando...",false,numeroedit,Icons.phone,true),
              inputlista("Carregando...",false,moradaedit,Icons.pin_drop,true),
                SizedBox(height: 5,),
              loginButton("Alterar Senha",Colors.grey,Colors.white,(){
                   Navigator.push(context, MaterialPageRoute(builder: (context)=> EditSenha()));
              }),
                 SizedBox(height: 10,),
                loginButton("Gravar Alterações",primaryColor,Colors.white,(){
                  updateData(context);
                })
            ],
          ),
      ),
    ));
  }


  Widget inputlista(String label,bool isObcure,TextEditingController controller,IconData icon,bool isnabled  ){
  return Padding(
    padding: EdgeInsets.only(left: 10,right: 10,bottom: 5,top: 5),
    child:TextField(
      enabled: isnabled,
    controller: controller,
    style: TextStyle(fontSize: 15.0, color: Colors.black),
    textAlign: TextAlign.left,
    obscureText: isObcure,
    decoration: InputDecoration(
      prefixIcon: Icon(icon),
      hintText: '$label',
      hintStyle: TextStyle(color:Colors.grey,fontWeight: FontWeight.bold,fontSize: 20),
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
   child:isloading? SpinKitWave(color: Colors.white,size: 40.0,):
   Text("$labelText",style: TextStyle(color:corTexto, fontSize: 13, fontWeight: FontWeight.bold),),
 )
   );
}

 getUserData(String email) async{
  final response =await http.get("https://www.visualfoot.com/api/getUserData.php?email=$email");
    if (response.statusCode == 200) {
      userdataList = json.decode(response.body) as List;
      
       setState(() {
          nomeedit.text = userdataList[0]['nome'];
          sobreNomedit.text = userdataList[0]['sobrenome'];
          emailedit.text = userdataList[0]['email'];
          numeroedit.text = userdataList[0]['telemovel'].length <= 2?" ":userdataList[0]['telemovel'].toString();
          moradaedit.text = userdataList[0]['morada'].length <= 2?" ":userdataList[0]['morada'].toString();
       });

    } else {
      throw Exception('Failed to load photos');
    }
 }



 updateData(BuildContext context) async {
    String url = 'http://www.visualfoot.com/api/editarConta.php?&use_nome=${nomeedit.text}&use_lastname=${sobreNomedit.text}&use_telefone=${numeroedit.text}&use_morada=${moradaedit.text}';
    Response response = await get(url);
    if(response.body.contains("successfully") == true){
        showConfirm(context,"Confirmação","Sucesso!");
         getUserData(emailedit.text);
    }else{
        showConfirm(context,"Confirmação","Erro ao atualizar os dados!");
        getUserData(emailedit.text);
    }
 }

}