import 'package:flutter/material.dart';

class FabWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
          onPressed: () {
            Scaffold.of(context)
                .showSnackBar(SnackBar(content: Text('Clicked fab2!')));
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.amber[800]);
  }
}