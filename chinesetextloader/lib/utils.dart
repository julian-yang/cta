import 'package:proto/google/protobuf/timestamp.pb.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore_lib;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:platform/platform.dart';
import 'package:fixnum/fixnum.dart';
import 'package:proto/article.pb.dart';

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

Uri toFullMdnUri(String path) {
  return Uri.parse("https://mdnkids.com/youth/$path");
}

final firestore_lib.CollectionReference firestoreArticles =
    firestore_lib.Firestore.instance.collection('articles');

DateTime convertTimestamp(Timestamp timestamp) {
  Int64 microseconds =
      Int64(Duration.microsecondsPerSecond) * timestamp.seconds.toInt() +
          // There are 1000 nanoseconds in a microsecond
          (timestamp.nanos / 1000).floor();

  // this is probably safe since Int32MAX => a date in 2038
  return DateTime.fromMicrosecondsSinceEpoch(microseconds.toInt());
}

int unknownWordCount(Article article) =>
    article.uniqueWords.length - article.stats.knownWordCount;

//void commit(article) {
//  Firestore.instance.runTransaction((transaction) async {
//    final freshSnapshot = await transaction.get(article.reference);
//    final freshRecord = Record.fromSnapshot(freshSnapshot);
//    await transaction
//        .update(article.reference, {'votes': freshRecord.votes + 1});
//  });
//}
