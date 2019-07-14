
import 'package:flutter/material.dart';
import 'package:kamino/ui/elements.dart';
import 'package:kamino/ui/loading.dart';

class SearchingSourcesDialog extends StatefulWidget {

  final Function onCancel;

  SearchingSourcesDialog({
    this.onCancel
  });

  @override
  State<StatefulWidget> createState() => SearchingSourcesDialogState();

}

class SearchingSourcesDialogState extends State<SearchingSourcesDialog> {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
          title: TitleText('Searching for sources...'),
          content: SingleChildScrollView(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 20),
                    child: ApolloLoadingSpinner()
                ),
                Center(child: Text("Please wait..."))
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Theme.of(context).primaryColor,
              child: Text('Cancel'),
              onPressed: () async {
                await widget.onCancel();
                Navigator.of(context).pop();
              },
            ),
          ]
      ),
    );
  }

}