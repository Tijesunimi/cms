import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final Function onPressed;
  final bool isProcessing;

  PrimaryButton({this.label, this.onPressed, this.isProcessing});

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: 200.0,
      height: 40.0,
      child: RaisedButton(
        child: isProcessing ? CircularProgressIndicator(backgroundColor: Colors.white) : Text(label),
        onPressed: isProcessing ? null : onPressed,
        textTheme: ButtonTextTheme.primary,
        disabledColor: Theme.of(context).primaryColor,
      ),
    );
  }
}