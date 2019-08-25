import 'package:flutter/material.dart';

class RoundTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String errorText;
  final bool obscureText;

  RoundTextFormField({this.controller, this.labelText, this.errorText, this.obscureText:false});

  @override
  State<StatefulWidget> createState() => _RoundTextFormFieldState(this.controller, this.labelText, this.errorText, this.obscureText);
}

class _RoundTextFormFieldState extends State<RoundTextFormField> {
  final TextEditingController controller;
  final String labelText;
  final String errorText;
  final bool obscureText;

  _RoundTextFormFieldState(this.controller, this.labelText, this.errorText, this.obscureText);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0)
          ),
          labelText: labelText,
          errorText: errorText,
        ),
        obscureText: obscureText,
      ),
    );
  }
}