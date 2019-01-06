// Create an infinite scrolling lazily loaded list
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:platform/platform.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent/android_intent.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Startup Name Generator',
      home: new RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => new RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = <WordPair>[];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Startup Name Generator'),
      ),
      body: _buildSuggestions(),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            String text = await rootBundle.loadString('assets/test.txt');
            Clipboard.setData(new ClipboardData(text: text));
            Fluttertoast.showToast(
              msg: 'Copied text to clipboard',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black38,
              textColor: Colors.white
            );
            const url = 'plecoapi://x-callback-url/clipboard';
//            const url = 'intent://x-callback-url/clipboard;scheme=plecoapi;package=com.pleco.chinesesystem;end';
//            const url = 'plecoapi://x-callback-url/s?q=你好嗎我很好你呢我們去學校';
//            const url = 'http://flutter.io';
//            if (LocalPlatform().isAndroid) {
//              AndroidIntent intent = new AndroidIntent(
//                action: 'action_view',
//                data: url,
//              );
//              await intent.launch();

            if (await canLaunch(url)) {
              await launch(url);
            } else {
              Fluttertoast.showToast(
                  msg: 'Could not launch',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black38,
                  textColor: Colors.white
              );
            }
          },
          tooltip: 'Copy chinese text',
          child: Icon(Icons.content_copy)),
    );
  }

  Widget _buildSuggestions() {
    return new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return const Divider();
          }
          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(WordPair pair) {
    return new ListTile(
      title: new Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
    );
  }
}
