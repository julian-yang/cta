import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import 'dart:convert';
import 'utils.dart';

class AddArticleWizard extends StatefulWidget {
  @override
  _AddArticleWizardState createState() => new _AddArticleWizardState();
}

class _AddArticleWizardState extends State<AddArticleWizard> {
  Future<List<ArticleLink>> _articleList;

  @override
  void initState() {
    super.initState();
    _articleList = fetchPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add new article')),
        body: Column(children: [
          FutureBuilder<List<ArticleLink>>(
              future: _articleList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Expanded(child: ListView(children: snapshot.data));
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return Center(child: CircularProgressIndicator());
              }),
          RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel')),
        ]));
  }

  Future<List<ArticleLink>> fetchPost() async {
    http.Response response = await http
        .get('https://mdnkids.com/youth/default.asp#more_browsing_bg');
    final document = parse(utf8.decode(response.bodyBytes));
    List<dom.Element> articleLinks = document.querySelectorAll('div.box');
    return articleLinks.map((element) {
      final chineseTitle = element.querySelector('div.box_title').text.trim();
      final imgUri = toFullMdnUri(
          element.querySelector('div.box_img > img').attributes['src']);
      final articleUri =
          toFullMdnUri(element.querySelector('a').attributes['href']);
      return ArticleLink(chineseTitle, imgUri, articleUri);
    }).toList();
  }
}

class ArticleLink extends StatelessWidget {
  final String chineseTitle;
  final Uri imageUri;
  final Uri articleUri;

  ArticleLink(this.chineseTitle, this.imageUri, this.articleUri);

  @override
  Widget build(BuildContext context) {
    return Padding(
//        key: ValueKey(article.englishTitle),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: InkWell(
            onTap: () {},
            child: Card(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Image.network(imageUri.toString(), width: 100),
              Flexible(
                  child: ListTile(
                      title: Text(chineseTitle),
                      subtitle: Text(articleUri.toString()))),
//          Expanded(child:
//          Column(mainAxisAlignment: MainAxisAlignment.start, children: [
//            Text(chineseTitle),
//            Text(articleUri.toString()),
            ]))));
  }
}

class ArticleList {
  String articleName;

  ArticleList(this.articleName);
}
