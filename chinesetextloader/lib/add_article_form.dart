import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddArticleForm extends StatefulWidget {
  @override
  AddArticleFormState createState() {
    return AddArticleFormState();
  }
}

class AddArticleFormState extends State<AddArticleForm> {
  final _formKey = GlobalKey<FormState>();
  var _chineseTitleController = TextEditingController();
  var _chineseBodyController = TextEditingController();
  var _englishTitleController = TextEditingController();
  var _englishBodyController = TextEditingController();
  var _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: ListView(
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
                  decoration: const InputDecoration(
                    hintText: 'The content of the article in Chinese.',
                    labelText: 'Chinese article content',
                  ),
                  validator: (String value) {
                    return value.trim().isEmpty
                        ? 'Chinese article content must not be empty.'
                        : null;
                  }),
              TextFormField(
                  controller: _englishTitleController,
                  decoration: const InputDecoration(
                    hintText: 'The name of the article in English.',
                    labelText: 'English Title',
                  ),
                  validator: (String value) {
                    return value.trim().isEmpty
                        ? 'English title must not be empty.'
                        : null;
                  }),
              TextFormField(
                  controller: _englishBodyController,
                  decoration: const InputDecoration(
                    hintText: 'The content of the article in English.',
                    labelText: 'English article content',
                  ),
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
                  validator: (String value) {
                    return value.trim().isEmpty
                        ? 'Article url must not be empty.'
                        : null;
                  }),
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
                            'url': _urlController.text
                          }).then((docRef) => Scaffold.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Added article! DocRef: ${docRef.documentID}'))));
                        }
                      },
                      child: Text('Submit')))
            ]));
  }
}
