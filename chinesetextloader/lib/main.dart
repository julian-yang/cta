// Create an infinite scrolling lazily loaded list
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'article_toolbar.dart';
import 'article_viewer.dart';
import 'article.dart';
import 'add_article_form.dart';
import 'add_article_wizard.dart';

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

typedef Widget ContextToWidget(BuildContext context);

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<ContextToWidget> _tabs = <ContextToWidget>[
    _MyHomePageState._buildArticleList,
    _MyHomePageState._buildAddArticle
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Chinese Text Loader'),
      ),
      body: _tabs.elementAt(_selectedIndex)(context),
      floatingActionButton: Builder(builder: (context) =>
        FloatingActionButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddArticleWizard()));
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.amber[800])
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.library_books), title: Text('Articles')),
            BottomNavigationBarItem(
                icon: Icon(Icons.library_add), title: Text('Add Article'))
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped),
    );
  }

  static Widget _buildAddArticle(BuildContext context) {
    return AddArticleForm();
  }

  static Widget _buildArticleList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('articles').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  static Widget _buildList(
      BuildContext context, List<DocumentSnapshot> snapshot) {
    List<Article> articles = snapshot
        .map((data) => Article.fromSnapshot(data))
        .toList()
          ..sort((a, b) => a.addDate.compareTo(b.addDate));
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: articles.reversed
          .map((data) => _buildListItem(context, data))
          .toList(),
    );
  }

  static Widget _buildListItem(BuildContext context, Article article) {
    return Padding(
        key: ValueKey(article.englishTitle),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ArticleViewer(article: article)));
            },
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
//                      leading: Icon(Icons.description),
                      title: Text(article.chineseTitle),
                      subtitle: Text(article.englishTitle)),
                  ArticleToolbar(article: article)
                ],
              ),
            )));
  }
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
