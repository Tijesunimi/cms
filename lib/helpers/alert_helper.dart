import 'package:flutter/material.dart';

class AlertHelper {
  static Future<void> showErrorDialog(BuildContext context, String message) async {
    await _showDialog(context, message, Icons.error, Colors.red, <Widget>[
      new FlatButton(
        child: new Text("Try again"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ]);
  }

  static Future<void> showSuccessDialog(BuildContext context, String message) async {
    await _showDialog(context, message, Icons.check_circle, Colors.green, <Widget>[
      new FlatButton(
        child: new Text("OK"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ]);
  }

  static Future<bool> showConfirmDialog(BuildContext context, String message) async {
    bool isConfirmed = false;
    await _showDialog(context, message, Icons.info, Colors.blue, <Widget>[
      new FlatButton(
        child: new Text("Yes"),
        onPressed: () {
          isConfirmed = true;
          Navigator.of(context).pop();
        },
      ),
      new FlatButton(
        child: new Text("No"),
        onPressed: () {
          Navigator.of(context).pop();
        },
      )
    ]);
    return isConfirmed;
  }

  static Future<void> _showDialog(BuildContext context, String message, IconData icon, Color iconColor, List<Widget> actions) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Icon(
            icon,
            size: 80.0,
            color: iconColor,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)
          ),
          content: Text(message, textAlign: TextAlign.center),
          actions: actions,
        );
      },
    );
  }
}