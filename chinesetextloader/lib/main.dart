// Create an infinite scrolling lazily loaded list
import 'package:chineseTextLoader/favorites_viewer.dart';
import 'package:chineseTextLoader/known_word_uploader/known_word_uploader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'article_table/article_table.dart';
import 'add_article_form.dart';
import 'add_article_wizard.dart';
import 'known_word_uploader/refresh_section.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData.light(),
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

  List<Widget> _tabs = <Widget>[
    FavoritesViewer(),
    ArticleTable(),
//    AddArticleForm(),
    RefreshSection(),
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
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddArticleWizard()));
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.amber[800])),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite), title: Text('Favorites')),
            BottomNavigationBarItem(
                icon: Icon(Icons.library_books), title: Text('Articles')),
//            BottomNavigationBarItem(
//                icon: Icon(Icons.library_add), title: Text('Add Article')),
            BottomNavigationBarItem(
                icon: Icon(Icons.sync), title: Text('Sync')),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped),
    );
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
