import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:translator/translator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:convert';
import 'article.dart';
import 'translate_icon_icons.dart';

class AddArticleForm extends StatefulWidget {
  final Uri inputUri;

  AddArticleForm({this.inputUri});

  @override
  AddArticleFormState createState() {
    return AddArticleFormState(inputUri);
  }
}

class AddArticleFormState extends State<AddArticleForm> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = new DateFormat.yMMMd();
  final _translator = GoogleTranslator();
  final _inputUri;
  var _chineseTitleController = TextEditingController();
  var _chineseBodyController = TextEditingController();
  var _englishTitleController = TextEditingController();
  var _englishBodyController = TextEditingController();
  var _urlController = TextEditingController();
  var _selectedDate = stripOutTime(DateTime.now());

  Future<Article> _article;

  AddArticleFormState(this._inputUri);

  static DateTime stripOutTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2010, 1),
        lastDate: DateTime(2100, 12, 31));
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = stripOutTime(picked);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _article = _inputUri != null
        ? fetchArticle(_inputUri)
        : Future.value(Article.empty());
    _article.then((article) => setState(() {
          _chineseTitleController.text = article.chineseTitle;
          _chineseBodyController.text = article.chineseBody;
          _englishTitleController.text = article.englishTitle;
          _englishBodyController.text = article.englishBody;
          _urlController.text = article.url;
          _selectedDate = article.addDate;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: FutureBuilder<Article>(
            future: _article,
            builder: (context, articleSnapshot) {
              if (articleSnapshot.hasData) {
                return buildArticleForm(articleSnapshot.data);
              } else if (articleSnapshot.hasError) {
                return Text('${articleSnapshot.error}');
              }
              return Center(child: CircularProgressIndicator());
            }));
  }

  Widget buildArticleForm(Article article) {
    return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          TextFormField(
              controller: _chineseTitleController,
              decoration: const InputDecoration(
                hintText: 'The name of the article in Chinese.',
                labelText: 'Chinese Title',
              ),
              onSaved: (value) => setState,
              validator: (String value) {
                return value.trim().isEmpty
                    ? 'Chinese title must not be empty.'
                    : null;
              }),
          TextFormField(
              controller: _chineseBodyController,
              minLines: 1,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'The content of the article in Chinese.',
                labelText: 'Chinese article content',
              ),
              onSaved: (value) => setState,
              validator: (String value) {
                return value.trim().isEmpty
                    ? 'Chinese article content must not be empty.'
                    : null;
              }),
          Row(children: [
            Expanded(
                child: TextFormField(
                    controller: _englishTitleController,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'The name of the article in English.',
                      labelText: 'English Title',
                    ),
                    onSaved: (value) => setState,
                    validator: (String value) {
                      return value.trim().isEmpty
                          ? 'English title must not be empty.'
                          : null;
                    })),
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Ink(
                    child: IconButton(
                  iconSize: 36,
                  color: Colors.blue,
                  splashColor: Colors.blue[300],
                  icon: Icon(MdiIcons.googleTranslate),
                  onPressed: () {
                    if (_chineseTitleController?.text?.isEmpty ?? true) {
                      return;
                    }
                    _translator
                        .translate(_chineseTitleController.text,
                            from: 'zh-tw', to: 'en')
                        .then((engTitle) {
                      setState(() {
                        _englishTitleController.text = engTitle;
                      });
                    });
                  },
                )))
          ]),
          TextFormField(
              controller: _englishBodyController,
              minLines: 1,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'The content of the article in English.',
                labelText: 'English article content',
              ),
              onSaved: (value) => setState,
              validator: (String value) {
                return value.trim().isEmpty
                    ? 'English article content must not be empty.'
                    : null;
              }),
          TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'The url of the article website.',
                labelText: 'Article url',
              ),
              onSaved: (value) => setState,
              validator: (String value) {
                return value.trim().isEmpty
                    ? 'Article url must not be empty.'
                    : null;
              }),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(_dateFormat.format(_selectedDate)),
                    RaisedButton(
                      onPressed: () => _selectDate(context),
                      child: Text('Select submitted date'),
                    )
                  ])),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    if (_formKey.currentState.validate()) {
                      // If the form is valid, we want to show a Snackbar
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('Processing Data')));

                      Firestore.instance.collection('articles').add({
                        'chineseBody': _chineseBodyController.text,
                        'chineseTitle': _chineseTitleController.text,
                        'englishBody': _englishBodyController.text,
                        'englishTitle': _englishTitleController.text,
                        'url': _urlController.text,
                        'addDate': _selectedDate,
                      }).then((docRef) {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          ScaffoldState scaffoldState = Scaffold.of(context);
                          scaffoldState.removeCurrentSnackBar();
                          scaffoldState.showSnackBar(SnackBar(
                              content: Text(
                                  'Added article! DocRef: ${docRef.documentID}')));

                          Future.delayed(const Duration(milliseconds: 1000),
                              () {
                            if (_inputUri != null) {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            }
                          });
                        });
                      });
                    }
                  },
                  child: Text('Submit')))
        ]);
  }

  Future<Article> fetchArticle(Uri uri) async {
    http.Response response = await http.get(uri);
    final document = parse(utf8.decode(response.bodyBytes));
    final englishBody = document.querySelectorAll('div.col-xs-12 > p').first.text.trim();
    final articleBodies = document.querySelectorAll('div.col-xs-12')[1];
    final chineseBody = articleBodies.text.trim().replaceFirst(englishBody, '');
    final chineseTitle = document.querySelector('div.news_tit').text.trim();
    final extractedDate = RegExp(r"\d+").firstMatch(uri.toString())[0] ?? "";
    return Article.fromMap({
      'chineseTitle': chineseTitle,
      'chineseBody': chineseBody.trim(),
      'englishTitle': '',
      'englishBody': englishBody.trim(),
      'url': uri.toString(),
      'addDate': DateTime.tryParse(extractedDate) ?? DateTime.now(),
    });
  }
}
