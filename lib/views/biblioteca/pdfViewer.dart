import 'dart:io';

import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:kioxkenewf/models/viewStyles.dart';


class OpenAnotherBook extends StatefulWidget {
  @override
  _OpenAnotherBookState createState() => _OpenAnotherBookState();
  final String pathUrl;
  final String nameBook;
  OpenAnotherBook({this.pathUrl,this.nameBook});
}

class _OpenAnotherBookState extends State<OpenAnotherBook> {
   PDFDocument doc;
   bool _isLoading = false;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadinFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: primaryColor,
        centerTitle: true,
       title: Text(widget.nameBook),
        actions: [
          
        ]
      ),
      body: Center(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : PDFViewer(document: doc)),
    );
  }

  void loadinFile() async{
    File file  = File(widget.pathUrl);
    doc = await PDFDocument.fromFile(file);
    _isLoading = true;
  }


}