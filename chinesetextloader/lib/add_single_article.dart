import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import 'dart:convert';
import 'utils.dart';

class AddSingleArticleData {
  final Uri uri;

  AddSingleArticleData(this.uri);
}

class AddSingleArticle extends StatefulWidget {
  final AddSingleArticleData data;

  AddSingleArticle({Key key, @required this.data}) : super(key: key);

  @override
  _AddSingleArticleState createState() => new _AddSingleArticleState(data);
}

class _AddSingleArticleState extends State<AddSingleArticle> {
  final Uri uri;

  _AddSingleArticleState(AddSingleArticleData data) : uri = data.uri;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add new single article')),
        body: Center(child: Text(uri.toString())));
  }
}
