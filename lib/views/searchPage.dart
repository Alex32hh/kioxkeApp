import 'package:flutter/material.dart';
import 'package:kioxkenewf/models/viewStyles.dart';

class Pesquisa extends StatefulWidget {
  @override
  _PesquisaState createState() => _PesquisaState();
}

class _PesquisaState extends State<Pesquisa> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor:primaryColor,
        title: Text("O que Procura?",
          textAlign: TextAlign.center,
            style: TextStyle(
            fontFamily: "cuyabra",
            fontWeight: FontWeight.w400,
            fontSize: 18,
            ),
          ),
          actions: [
            Icon(Icons.more_vert,color: Colors.white,)
          ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10),
        height: 110,
        child: TextField(
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                ),
                cursorColor: primaryColor,
                decoration: InputDecoration(
                  alignLabelWithHint: false,
                  hintText: "O que Procura?",
                  hintStyle: TextStyle(
                    fontSize: 17
                  ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    suffixIcon: IconButton(icon: Icon(Icons.search, color: primaryColor,), onPressed: (){}),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                    
                    )
                ),
              ),
      ),
    );
  }
}