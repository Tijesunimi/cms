import 'package:flutter/material.dart';

class RoundTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String errorText;
  final bool obscureText;
  final IconData icon;
  final Function validator;

  RoundTextFormField(
      {this.controller,
      this.labelText,
      this.errorText,
      this.icon,
      this.validator,
      this.obscureText: false});

  @override
  State<StatefulWidget> createState() => _RoundTextFormFieldState(
      this.controller,
      this.labelText,
      this.errorText,
      this.obscureText,
      this.icon,
      this.validator);
}

class _RoundTextFormFieldState extends State<RoundTextFormField> {
  final TextEditingController controller;
  final String labelText;
  final String errorText;
  final bool obscureText;
  final IconData icon;
  final Function validate;

  _RoundTextFormFieldState(this.controller, this.labelText, this.errorText,
      this.obscureText, this.icon, this.validate);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        validator: validate,
        decoration: InputDecoration(
          prefixIcon: Icon(this.icon),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(20.0),
            ),
          ),
          enabledBorder: OutlineInputBorder(
              borderSide:
              BorderSide(color: Colors.grey.withOpacity(0.5), width: 1.0),
              borderRadius: const BorderRadius.all(
                const Radius.circular(20.0),
              )),
          labelText: this.labelText,
          labelStyle: TextStyle(color: Colors.grey),
        ),
        obscureText: obscureText,
      ),
    );
  }
}
