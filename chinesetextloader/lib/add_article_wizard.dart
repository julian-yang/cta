import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import 'dart:convert';
import 'utils.dart';
import 'add_article_form.dart';

class AddArticleWizard extends StatefulWidget {
  @override
  _AddArticleWizardState createState() => new _AddArticleWizardState();
}

class _AddArticleWizardState extends State<AddArticleWizard> {
  Future<List<ArticleLink>> _articleLinks;
  Set<Uri> _selectedArticles = {};

  @override
  void initState() {
    super.initState();
    _articleLinks = fetchArticleLinks();
  }

  void navigateGenerateArticle() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(
                appBar: AppBar(title: Text('ArticleAdder')),
                body: AddArticleForm(
                    inputUri:
                        (_selectedArticles.toList()..sort()).reversed.first))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add new article')),
        body: NotificationListener<ArticleSelectionNotification>(
            onNotification: (notification) {
              setState(() {
                if (notification.selected) {
                  _selectedArticles.add(notification.articleUri);
                } else {
                  _selectedArticles.remove(notification.articleUri);
                }
              });
              // cancel notification bubbling
              return true;
            },
            child: Column(children: [
              ArticleList(_articleLinks),
              Divider(
                color: Colors.amber[700],
                height: 0,
                thickness: 5,
              ),
              ButtonBar(children: [
                Padding(
                    padding: EdgeInsets.only(right: 20),
                    child:
                        Text('${_selectedArticles.length} articles selected')),
                RaisedButton(
                    child: Text('Generate'),
                    onPressed: _selectedArticles.isNotEmpty
                        ? () {
                            navigateGenerateArticle();
                          }
                        : null),
                RaisedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel')),
              ])
            ])));
  }

  Future<List<ArticleLink>> fetchArticleLinks() async {
    http.Response response = await http
        .get('https://mdnkids.com/youth/default.asp#more_browsing_bg');
    final document = parse(utf8.decode(response.bodyBytes));
    List<dom.Element> rawArticleLinks = document.querySelectorAll('div.box');
    return rawArticleLinks.map((element) {
      final chineseTitle = element.querySelector('div.box_title').text.trim();
      final imgUri = toFullMdnUri(
          element.querySelector('div.box_img > img').attributes['src']);
      final articleUri =
          toFullMdnUri(element.querySelector('a').attributes['href']);
      return ArticleLink(chineseTitle, imgUri, articleUri);
    }).toList();
  }
}

class ArticleList extends StatefulWidget {
  final Future<List<ArticleLink>> _articleLinks;

  ArticleList(this._articleLinks);

  @override
  ArticleListState createState() => ArticleListState(_articleLinks);
}

class ArticleListState extends State<ArticleList> {
  final Future<List<ArticleLink>> _articleLinks;

  ArticleListState(this._articleLinks);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ArticleLink>>(
        future: _articleLinks,
        builder: (context, articleLinksSnapshot) {
          if (articleLinksSnapshot.hasData) {
            return Expanded(
                child: ListView(children: articleLinksSnapshot.data));
          } else if (articleLinksSnapshot.hasError) {
            return Text("${articleLinksSnapshot.error}");
          }
          return Expanded(child: Center(child: CircularProgressIndicator()));
        });
  }
}

class ArticleLink extends StatefulWidget {
  final String chineseTitle;
  final Uri imageUri;
  final Uri articleUri;

  ArticleLink(this.chineseTitle, this.imageUri, this.articleUri);

  @override
  ArticleLinkState createState() =>
      new ArticleLinkState(chineseTitle, imageUri, articleUri);
}

class ArticleLinkState extends State<ArticleLink> {
  static final selectedBorder = RoundedRectangleBorder(
      side: BorderSide(color: Colors.amber[500], width: 3),
      borderRadius: BorderRadius.all(Radius.circular(4)));
  final String chineseTitle;
  final Uri imageUri;
  final Uri articleUri;
  final Stream<QuerySnapshot> _querySnapshot;
  bool uriExistsInFirestore = false;
  bool selected = false;

  ArticleLinkState(this.chineseTitle, this.imageUri, this.articleUri)
      : _querySnapshot = firestoreArticles
            .where('url', isEqualTo: articleUri.toString())
            .limit(1)
            .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _querySnapshot,
        builder: (context, snapshot) {
          bool uriExistsInFirestore =
              snapshot.data?.documents?.isNotEmpty ?? false;
          return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: InkWell(
                  onTap: () {
                    setState(() => selected = !selected);
                    ArticleSelectionNotification(articleUri, selected)
                        .dispatch(context);
                  },
                  child: Card(
                      shape: selected ? selectedBorder : null,
                      color: uriExistsInFirestore ? Colors.amber[200] : null,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.network(imageUri.toString(), width: 100),
                            Flexible(
                                child: ListTile(
                                    title: Text(chineseTitle),
                                    subtitle: Text(articleUri.toString()))),
                          ]))));
        });
  }
}

class ArticleSelectionNotification extends Notification {
  final Uri articleUri;
  final bool selected;

  const ArticleSelectionNotification(this.articleUri, this.selected);
}
