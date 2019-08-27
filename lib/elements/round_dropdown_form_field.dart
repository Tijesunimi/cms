import 'package:flutter/material.dart';

class RoundDropdownFormField extends StatefulWidget {
  final String labelText;
  final IconData icon;
  final List<String> items;
  final Function onChanged;
  final String initialValue;
  final bool hasAllOption;

  RoundDropdownFormField(
      {this.labelText,
        this.icon,
        this.items,
        this.onChanged,
        this.initialValue,
        this.hasAllOption:false});

  @override
  State<StatefulWidget> createState() => _RoundDropdownFormFieldState(
      this.labelText,
      this.icon,
      this.items,
      this.onChanged,
      this.initialValue,
      this.hasAllOption);
}

class _RoundDropdownFormFieldState extends State<RoundDropdownFormField> {
  final String labelText;
  final IconData icon;
  final List<String> items;
  final Function onChanged;
  final String initialValue;
  final bool hasAllOption;

  _RoundDropdownFormFieldState(this.labelText, this.icon, this.items, this.onChanged,
      this.initialValue, this.hasAllOption);

  String selectedItem;

  @override
  void initState() {
    if (initialValue != null && initialValue.isNotEmpty)
      selectedItem = initialValue;
    else if (hasAllOption)
      selectedItem = '';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dropDownItems = List<DropdownMenuItem<String>>();
    if (hasAllOption) {
      dropDownItems.add(DropdownMenuItem<String>(
        value: '',
        child: Text('All'),
      ));
    }
    dropDownItems.addAll(items.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField(
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
        value: selectedItem,
        items: dropDownItems,
        onChanged: (value) {
          setState(() {
            selectedItem = value;
          });
          if (this.onChanged != null)
            this.onChanged(value);
        },
      ),
    );
  }
}
