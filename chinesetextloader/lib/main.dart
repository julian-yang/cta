// Create an infinite scrolling lazily loaded list
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:platform/platform.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Startup Name Generator',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<WordPair> _suggestions = <WordPair>[];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Chinese Text Loader'),
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            String text = await rootBundle.loadString('assets/test.txt');
            Clipboard.setData(new ClipboardData(text: text));
            Fluttertoast.showToast(
                msg: 'Copied text to clipboard',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black38,
                textColor: Colors.white);
            if (LocalPlatform().isAndroid) {
              MethodChannel('chinesetextloader')
                  .invokeMethod('openPlecoClipboard');
            } else {
              Fluttertoast.showToast(
                  msg: 'Could not launch',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black38,
                  textColor: Colors.white);
            }
          },
          tooltip: 'Copy chinese text',
          child: Icon(Icons.content_copy)),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('articles').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final article = Article.fromSnapshot(data);

    return Padding(
        key: ValueKey(article.englishTitle),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
                leading: Icon(Icons.description),
                title: Text(article.chineseTitle),
                subtitle: Text(article.englishTitle)),
            ButtonTheme.bar(
                child: ButtonBar(children: <Widget>[
              FlatButton(
                  child: Column(children: <Widget>[
                    Icon(Icons.assignment),
                    const Text('Copy to Pleco')
                  ]),
                  onPressed: () => copyToClipBoard(article.chineseBody)
              ),
              FlatButton(
                  child: Column(children: <Widget>[
                    Icon(Icons.open_in_browser),
                    const Text('Open in URL')
                  ]),
                onPressed: () => openUrl(article.url),
                  )
            ]))
          ],
        )));
  }
}

class Article {
  final String chineseTitle;
  final String chineseBody;
  final String englishTitle;
  final String englishBody;
  final String url;
  final DocumentReference reference;

  Article.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['chineseTitle'] != null),
        assert(map['chineseBody'] != null),
        assert(map['englishTitle'] != null),
        assert(map['englishBody'] != null),
        assert(map['url'] != null),
        chineseTitle = map['chineseTitle'],
        chineseBody = map['chineseBody'],
        englishTitle = map['englishTitle'],
        englishBody = map['englishBody'],
        url = map['url'];

  Article.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => 'Article<$chineseTitle:$url>';
}

void openUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

void copyToClipBoard(String text) async {
  Clipboard.setData(new ClipboardData(text: text));
  Fluttertoast.showToast(
      msg: 'Copied text to clipboard',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black38,
      textColor: Colors.white);
  if (LocalPlatform().isAndroid) {
    MethodChannel('chinesetextloader').invokeMethod('openPlecoClipboard');
  } else {
    Fluttertoast.showToast(
        msg: 'Could not launch',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black38,
        textColor: Colors.white);
  }
}

void commit(article) {
  Firestore.instance.runTransaction((transaction) async {
    final freshSnapshot = await transaction.get(article.reference);
    final freshRecord = Record.fromSnapshot(freshSnapshot);
    await transaction
        .update(article.reference, {'votes': freshRecord.votes + 1});
  });
}

class Record {
  final String name;
  final int votes;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['votes'] != null),
        name = map['name'],
        votes = map['votes'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$votes>";
}
