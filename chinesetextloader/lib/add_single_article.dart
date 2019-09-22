import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import 'dart:convert';
import 'article.dart';
import 'package:intl/intl.dart';
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
  Future<Article> _article;

  _AddSingleArticleState(AddSingleArticleData data) : uri = data.uri;

  @override
  void initState() {
    super.initState();
    _article = fetchArticle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add new single article')),
        body: FutureBuilder<Article>(
            future: _article,
            builder: (context, articleSnapshot) {
              if (articleSnapshot.hasData) {
                Article loaded = articleSnapshot.data;
                return Column(children: [
                  Expanded(
                      child: ListView(children: [
                    Text('chineseTitle: ${loaded.chineseTitle}'),
                    Text('chineseBody: ${loaded.chineseBody}'),
                    Text('englishTitle: ${loaded.englishTitle}'),
                    Text('englishBody: ${loaded.englishBody}'),
                    Text(
                        'addDate: ${DateFormat.yMMMd().format(loaded.addDate)}'),
                    Text('uri: ${loaded.url}')
                  ]))
                ]);
              } else if (articleSnapshot.hasError) {
                return Text('${articleSnapshot.error}');
              }
              return Center(child: CircularProgressIndicator());
            }));
  }

  Future<Article> fetchArticle() async {
    http.Response response = await http.get(uri);
    final document = parse(utf8.decode(response.bodyBytes));
    final articleBodies = document.querySelectorAll('div.col-xs-12 > p');
    final englishBody = articleBodies[0];
    final chineseBody = articleBodies[1];
    final chineseTitle = document.querySelector('div.news_tit').text.trim();
    final extractedDate = RegExp(r"\d+").firstMatch(uri.toString())[0] ?? "";
    return Article.fromMap({
      'chineseTitle': chineseTitle,
      'chineseBody': chineseBody.text.trim(),
      'englishTitle': '',
      'englishBody': englishBody.text.trim(),
      'url': uri.toString(),
      'addDate': DateTime.tryParse(extractedDate) ?? DateTime.now(),
    });
  }
}
