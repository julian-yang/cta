import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:platform/platform.dart';

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

//void commit(article) {
//  Firestore.instance.runTransaction((transaction) async {
//    final freshSnapshot = await transaction.get(article.reference);
//    final freshRecord = Record.fromSnapshot(freshSnapshot);
//    await transaction
//        .update(article.reference, {'votes': freshRecord.votes + 1});
//  });
//}
