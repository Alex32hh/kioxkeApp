
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:im_stepper/stepper.dart';
import 'package:kioxkenewf/models/functions.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

const TextStyle optionStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.bold);
const TextStyle profileStyle = TextStyle(fontSize: 19, fontWeight: FontWeight.bold);
const TextStyle subtitle = TextStyle(fontSize: 19,color: Colors.black);
const Color primaryColor = Color.fromRGBO(246, 165, 46,1);

Widget shimerEfect(BuildContext context){
    return Container(
    decoration: BoxDecoration(color: Colors.grey[200],borderRadius: BorderRadius.all(Radius.circular(10))),
     width: MediaQuery.of(context).size.width,alignment: Alignment.center,height: 180, child: SpinKitWave(color: primaryColor,size: 40.0,));
  }
Widget shimerVertical(BuildContext context){
  return Container(
        width: 140,
        height: 250,
        alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[100],
              borderRadius: BorderRadius.all(Radius.circular(10))
          )
        ,
        child: SpinKitCubeGrid(
        color: primaryColor,
        size: 40.0,
      ),
    );
}

Widget pageTitle (String title,BuildContext context){
   return Container(
      width: MediaQuery.of(context).size.width,
      height: 40,
      padding: EdgeInsets.only(left:10),
      alignment: Alignment.centerLeft,
      child: Text(title,style: optionStyle,),
   );
 }

Widget cardComments(){
  return Card(
      child:CachedNetworkImage(
        imageUrl: "https://image.cnbcfm.com/api/v1/image/106069136-1565284193572gettyimages-1142580869.jpeg?v=1576531407&w=1400&h=950",
        imageBuilder: (context, imageProvider) => ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
          image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
             ),
          ),
        ),
        title: Text('Marcelo Maquina'),
        subtitle: Text(
          'achei muito interesante mas acredito que darei o meu comentario depois de ler o book'
        ),
        trailing: Icon(Icons.more_vert),
        isThreeLine: true,
      ),
        placeholder: (context, url) => SpinKitCubeGrid(color: primaryColor,size: 40.0,),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
}

Widget cardItem(String titulo,String imag,String preco,{Function download,int estado,double progress}){
   FlutterMoneyFormatter precoProduto = FlutterMoneyFormatter(amount: double.parse(preco));
  return Card(
      child:CachedNetworkImage(
        imageUrl: imag,
        imageBuilder: (context, imageProvider) => ListTile(
        contentPadding: EdgeInsets.all(5),
        trailing: estado <= 0?
        IconButton(icon: Icon(Icons.cloud_download_outlined,size:30,color:estado <= 0?Colors.grey:Colors.green), onPressed:() async{if(estado > 0)download();}):
        CircularPercentIndicator(
                radius: 35.0,
                lineWidth: 4.0,
                animation: false,
                percent: progress,
                center: IconButton(icon:Icon(Icons.stop,size: 20,color: Colors.grey,), onPressed:(){if(estado > 0)download();}),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: primaryColor,
              )
        ,
        leading: Container(
          height: 60,
          width: 100,
          decoration: BoxDecoration(
          image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
             ),
          ),
        ),
        title: Text('$titulo'),
        subtitle: Text('${precoProduto.output.nonSymbol} kzs',style:TextStyle(fontSize:15,fontWeight: FontWeight.bold,color: primaryColor)),
        // trailing: Icon(Icons.more_vert),
        isThreeLine: true,
      ),
        placeholder: (context, url) => SpinKitCubeGrid(color: primaryColor,size: 40.0,),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
}


Widget produts(Function action,int counter,String imageUrl,String titulo,String preco,int id,String data,String hora,String estado,Function update,Function download,{String idCarrinho}){
  FlutterMoneyFormatter precoProduto = FlutterMoneyFormatter(amount: double.parse(preco));
  return Container(
    height: estado == "2"?120:140,
    child: Card(
      child:CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => ListTile(
        contentPadding: EdgeInsets.all(5),
        dense:false,
       
        title:RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style:subtitle,
                  text:'Encomenda Nº:$id'),
                  ),
        subtitle:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ 
            Text('${data.replaceAll('-',':')} - $hora'),
            estado != "2"?Text(('Total: ${precoProduto.output.nonSymbol} kzs'),style:TextStyle(fontSize:15,fontWeight: FontWeight.bold,color: primaryColor),):SizedBox(),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                  estado == "0"? FlatButton(
                    onPressed: () async{showNormalAlert(context,(){deletaCarrinho(idCarrinho);update();},"Aviso","Tem certeza que deseja desistir da compra?");}, 
                    color:primaryColor,
                    child: Text("Cancelar")
                 ):FlatButton(
                    onPressed: action,
                    color:Colors.green,
                    child: Text("Pago")
                 ),
                Expanded(
                  child:IconStepper(
                     alignment:Alignment.centerRight,
                    lineColor:primaryColor,
                    activeStepBorderPadding:2.0,
                    enableStepTapping:false,
                    stepRadius:17.0,
                    lineLength:48.0,
                    enableNextPreviousButtons:false,
                    // scrollingDisabled:false,
                icons: [
                  Icon(Icons.access_time_rounded),
                  Icon(Icons.assignment_turned_in),
                  Icon(Icons.archive),
                ],

                // activeStep property set to activeStep variable defined above.
                activeStep: int.parse(estado),

                // This ensures step-tapping updates the activeStep. 
                onStepReached: (index) {
                  // setState(() {
                  //   activeStep = index;
                  // });
                },
              ),
                )

                //  Text("Pendente")
              ]
              )

            ]
          ),
        trailing: Column(
          children: [
            // Icon(Icons.arrow_drop_down),
            Badge(
                  position: BadgePosition.topEnd(),
                  badgeColor:Colors.red,
                  badgeContent: Text((counter).toString(),style: TextStyle(color: Colors.white, fontSize: 9),),
                  child: Icon(Icons.arrow_drop_down,color: Colors.grey)
                ),
          ],
        ),
        isThreeLine: true,
      ),
        placeholder: (context, url) => SpinKitCubeGrid(color: primaryColor,size: 40.0,),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    )
  );
}

Widget horizontalBox(Function openAction,BuildContext context,String titulo,String imageUrl,String autor,String likes,String urlBook,String preco,String descricao,String id,int isFavorite){
  FlutterMoneyFormatter precoProduto = FlutterMoneyFormatter(amount: double.parse(preco));
  return  GestureDetector(
    onTap:(){
    //  Navigator.push(context,MaterialPageRoute(builder: (context) => Datalhes(urlBook,titulo,imageUrl,autor,likes,preco,descricao,id,isFavorite: isFavorite,)));
    openAction();
    },
    child:
  Card( 
  color: Colors.white,
  borderOnForeground:true,
  shadowColor:Colors.grey[100],
  child:CachedNetworkImage(
    imageUrl: "$imageUrl",
    imageBuilder: (context, imageProvider) => Container(
    width: MediaQuery.of(context).size.width,
    height: 180,
    child: Row(
      children: [
        Container(
          width: 130,
          height: 180,
         decoration: BoxDecoration(
           borderRadius:BorderRadius.all(Radius.circular(10)),
           image: DecorationImage(image: imageProvider,fit: BoxFit.cover,),
        ),
        ),
        Expanded(
          child:Container(
          width: 200,
          height: 200,
          padding:EdgeInsets.all(15),
          child:Column(
            children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child:RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        style:subtitle,
                        text: "$titulo"),
                  ),
                ),

                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top:10,bottom:10),
                  child:RichText(
                    overflow: TextOverflow.fade,
                    text: TextSpan(
                        style: TextStyle(fontSize:15,color: primaryColor),
                        text: "by $autor"),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child:Text("$descricao",maxLines:3)
                ),
              
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [

                Text((precoProduto.output.nonSymbol != "0.00"?precoProduto.output.nonSymbol+" KZS":"Gratuito"),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: precoProduto.output.nonSymbol != "0.00"?primaryColor:Colors.green),),
                Container(
                  height: 25,
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.centerRight,
                  child: IconButton(icon:Icon(isFavorite==1?Icons.favorite:Icons.favorite_border,size: 20, color:isFavorite==1?Colors.red:primaryColor,), onPressed: (){})
                )
                   ],
                 )

            ],
          ),
        )

        )
      ],
    ),
  ),
  placeholder: (context, url) => shimerEfect(context),
    errorWidget: (context, url, error) => Icon(Icons.error),
  )));
 }

Widget verticalBox(Function openAction, BuildContext context,String titulo,String imageUrl,String autor,String likes,String urlBook,String preco,String descricao,String id,int isFavorite){
  return  GestureDetector(
    onTap:(){
      openAction();
    },
    child:Container(
     width: 150,
     height: 250,
     padding: EdgeInsets.all(5),
      child: CachedNetworkImage(
  imageUrl: "$imageUrl",
  imageBuilder: (context, imageProvider) => 
       Container(
        width: 200,
        decoration: BoxDecoration(
          color:Colors.grey[200],
          borderRadius: BorderRadius.all(Radius.circular(15))
        ),
        child:Column(
          mainAxisSize: MainAxisSize.max,
         children: [
            Container(
              width: 200,
              height: 200,
             decoration: BoxDecoration(
               borderRadius: BorderRadius.all(Radius.circular(10)),
                image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
              ),),
               Expanded(
                child:Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(5),
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        style: TextStyle(color: Colors.grey[700],fontSize: 12,fontWeight: FontWeight.bold),
                        text: "$titulo"),
                  ),
                ),
              ),


         ],
        ),
      ),
     placeholder: (context, url) => shimerVertical(context),
     errorWidget: (context, url, error) => Icon(Icons.error),
   ),
  )
 );
}


Widget biblotecaitem(Function openAction,String titulo,String imageUrl){
  return  InkWell(
    onTap:(){
      openAction();
    },
    child:Container(
     width: 150,
     height: 250,
     padding: EdgeInsets.all(5),
      child: CachedNetworkImage(
      imageUrl: "$imageUrl",
     imageBuilder: (context, imageProvider) => 
       Container(
        width: 200,
        decoration: BoxDecoration(
          color:Colors.grey[200],
          borderRadius: BorderRadius.all(Radius.circular(15))
        ),
        child:Column(
          mainAxisSize: MainAxisSize.max,
         children: [
            Container(
              width: 200,
              height: 200,
             decoration: BoxDecoration(
               borderRadius: BorderRadius.all(Radius.circular(10)),
                image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
              ),),
               Expanded(
                child:Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(5),
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        style: TextStyle(color: Colors.grey[700],fontSize: 12,fontWeight: FontWeight.bold),
                        text: "$titulo"),
                  ),
                ),
              ),


         ],
        ),
      ),
     placeholder: (context, url) => shimerVertical(context),
     errorWidget: (context, url, error) => Icon(Icons.error),
   ),
  )
 );
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
    title: Text("Confirmação"),
    content: Text("Tem a certeza que pretende eliminar este ítem?"),
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

showNormalAlert(BuildContext context,Function callBack,String title,String body) {
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
    title: Text("$title"),
    content: Text("$body"),
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

showConfirm(BuildContext context,String title,String body) {
  // set up the buttons
Widget continueButton = FlatButton(
    child: Text("Ok"),
    onPressed: (){
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("$title"),
    content: Text("$body"),
    actions: [
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


alertRecoperarSenha(BuildContext context,Function callBack,String title,String body) {
  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Esqueci a Senha"),
    onPressed:  () {
      callBack();
      Navigator.pop(context);
    },
  );
  Widget continueButton = FlatButton(
    child: Text("Ok"),
    onPressed: (){
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("$title"),
    content: Text("$body"),
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

Widget savedverticalBox(BuildContext context,String imageUrl,String titulo, Function submit){
  return  GestureDetector(
    onTap: (){
      submit();
    },
    child:Container(
     width: 150,
     height: 250,
     padding: EdgeInsets.all(5),
      child: CachedNetworkImage(
  imageUrl: "$imageUrl",
  imageBuilder: (context, imageProvider) => 
       Container(
        width: 200,
        decoration: BoxDecoration(
          color:Colors.grey[200],
          borderRadius: BorderRadius.all(Radius.circular(15))
        ),
        child:Column(
          mainAxisSize: MainAxisSize.max,
         children: [
            Container(
              width: 200,
              height: 200,
             decoration: BoxDecoration(
               borderRadius: BorderRadius.all(Radius.circular(10)),
                image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
              ),),
               Expanded(
                child:Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(5),
                  child: RichText(
                    overflow: TextOverflow.fade,
                    text: TextSpan(
                        style: TextStyle(color: Colors.grey[700],fontSize: 12,fontWeight: FontWeight.bold),
                        text: "$titulo"),
                  ),
                ),
              ),


         ],
        ),
      ),
     placeholder: (context, url) => shimerVertical(context),
     errorWidget: (context, url, error) => Icon(Icons.error),
   ),
  )
 );
}