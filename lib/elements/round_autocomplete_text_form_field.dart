import 'package:flutter/material.dart';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class RoundAutocompleteTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final TextInputType inputType;
  final List<String> autoCompleteItems;

  RoundAutocompleteTextFormField(
      {this.controller,
      this.labelText,
      this.icon,
      this.autoCompleteItems,
      this.inputType});

  @override
  State<StatefulWidget> createState() => _RoundAutocompleteTextFormFieldState(
      this.controller,
      this.labelText,
      this.icon,
      this.autoCompleteItems,
      this.inputType);
}

class _RoundAutocompleteTextFormFieldState extends State<RoundAutocompleteTextFormField> {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final TextInputType inputType;
  final List<String> autoCompleteItems;

  final GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();

  _RoundAutocompleteTextFormFieldState(this.controller, this.labelText,
      this.icon, this.autoCompleteItems, this.inputType);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AutoCompleteTextField<String>(
        key: key,
        controller: this.controller,
        keyboardType: this.inputType,
        itemBuilder: (context, item) {
          return Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                item,
                style: TextStyle(fontSize: 16.0),
              ));
        },
        itemFilter: (item, query) {
          return item.toLowerCase().contains(query.toLowerCase());
        },
        itemSorter: (a, b) {
          return a.compareTo(b);
        },
        itemSubmitted: (text) {},
        clearOnSubmit: false,
        suggestions: this.autoCompleteItems,
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
      ),
    );
  }
}
