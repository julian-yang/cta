import 'package:chineseTextLoader/known_word_uploader/stats_refresh.dart';
import 'package:flutter/material.dart';

import 'known_word_uploader.dart';

class RefreshSection extends StatefulWidget {
  @override
  _RefreshSectionState createState() => new _RefreshSectionState();
}

class _RefreshSectionState extends State<RefreshSection> {
  static final Color selectedColor = Colors.orange[800];
  static final Color unselectedColor = Colors.grey;

  final KnownWordUploader _knownWordUploader = KnownWordUploader();
  final StatsRefresh _statsRefresh = StatsRefresh();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(children: <Widget>[
        Material(
//            color: Colors.orange[900],
            child: TabBar(
//              indicator: BoxDecoration(
////                color: Colors.blue[700]
//              ),
          labelColor: selectedColor,
          unselectedLabelColor: unselectedColor,
          indicatorColor: selectedColor,
          tabs: [
            Tab(icon: Icon(Icons.cloud_upload), text: 'Upload vocab'),
            Tab(icon: Icon(Icons.sync), text: 'Update stats'),
          ],
        )),
        Expanded(
            child: TabBarView(children: [
          _knownWordUploader,
          _statsRefresh,
        ]))
      ]),
    );
  }
}
