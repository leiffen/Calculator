import 'package:flutter/material.dart';

class Dialogs {
  ok(BuildContext context, String title, String description, String confirmText, Color color, Function onPressed) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.grey[900],
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  onPressed();
                  Navigator.pop(context);
                },
                child: Text(
                  confirmText,
                  style: TextStyle(
                    color: color,
                  ),
                ),
              )
            ],
          );
        });
  }
}
