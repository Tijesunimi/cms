import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

import 'package:cms/models/container.dart';

import 'package:cms/services/container.dart';

import 'package:cms/elements/round_autocomplete_text_form_field.dart';
import 'package:cms/elements/round_text_form_field.dart';
import 'package:cms/elements/primary_button.dart';

import 'package:cms/helpers/alert_helper.dart';

class ContainerForm extends StatefulWidget {
  final ShippingContainer shippingContainer;

  ContainerForm({this.shippingContainer});

  @override
  State<StatefulWidget> createState() => _ContainerFormState(this.shippingContainer);
}

class _ContainerFormState extends State<ContainerForm> {
  final ShippingContainer shippingContainer;

  _ContainerFormState(this.shippingContainer);

  bool isEdit;
  bool hasFetchedAutoCompleteItems;

  final TextEditingController containerNumberController = TextEditingController();
  final TextEditingController shippingLineController = TextEditingController();
  final TextEditingController exporterController = TextEditingController();
  final TextEditingController importerController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController produceController = TextEditingController();
  final TextEditingController shipmentDateController = TextEditingController();
  final TextEditingController shipmentPortController = TextEditingController();
  final TextEditingController fumigationDateController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController departureDateController = TextEditingController();

  final LocalStorage localStorage = LocalStorage('autocompleteitems');

  final _formKey = GlobalKey<FormState>();
  final dateFormatter = new DateFormat('yyyy-MM-dd');

  List<String> shippingLineAutoCompleteItems = List<String>();
  List<String> exporterAutoCompleteItems = List<String>();
  List<String> importerAutoCompleteItems = List<String>();
  List<String> sizeAutoCompleteItems = List<String>();
  List<String> produceAutoCompleteItems = List<String>();
  List<String> shipmentPortAutoCompleteItems = List<String>();
  List<String> destinationAutoCompleteItems = List<String>();

  bool isProcessing;

  @override
  void initState() {
    isProcessing = false;
    hasFetchedAutoCompleteItems = false;
    isEdit = shippingContainer != null;
    if (isEdit) {
      containerNumberController.text = shippingContainer.containerNumber;
      shippingLineController.text = shippingContainer.shippingLine;
      exporterController.text = shippingContainer.exporter;
      importerController.text = shippingContainer.importer;
      if (shippingContainer.size != null)
        sizeController.text = shippingContainer.size.toString();
      produceController.text = shippingContainer.produce;
      if (shippingContainer.dateOfShipment != null)
        shipmentDateController.text = dateFormatter.format(shippingContainer.dateOfShipment);
      shipmentPortController.text = shippingContainer.shipmentPort;
      if (shippingContainer.dateOfFumigation != null)
        fumigationDateController.text = dateFormatter.format(shippingContainer.dateOfFumigation);
      destinationController.text = shippingContainer.destination;
      if (shippingContainer.dateOfDeparture != null)
        departureDateController.text = dateFormatter.format(shippingContainer.dateOfDeparture);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Container' : 'Add Container'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<bool>(
          future: initAutoCompleteItems(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    RoundTextFormField(
                      labelText: 'Container Number',
                      icon: Icons.info,
                      controller: containerNumberController,
                      validator: (value) {
                        if (value
                            .toString()
                            .isEmpty)
                          return "Container number is required";
                        return null;
                      },
                    ),
                    RoundAutocompleteTextFormField(
                      labelText: 'Shipping Line',
                      icon: Icons.shopping_cart,
                      controller: shippingLineController,
                      autoCompleteItems: shippingLineAutoCompleteItems,
                    ),
                    RoundAutocompleteTextFormField(
                      labelText: 'Exporter',
                      icon: Icons.explore,
                      controller: exporterController,
                      autoCompleteItems: exporterAutoCompleteItems,
                    ),
                    RoundAutocompleteTextFormField(
                      labelText: 'Importer',
                      icon: Icons.import_export,
                      controller: importerController,
                      autoCompleteItems: importerAutoCompleteItems,
                    ),
                    RoundAutocompleteTextFormField(
                      labelText: 'Size',
                      icon: Icons.format_size,
                      controller: sizeController,
                      autoCompleteItems: sizeAutoCompleteItems,
                    ),
                    RoundAutocompleteTextFormField(
                      labelText: 'Produce',
                      icon: Icons.folder,
                      controller: produceController,
                      autoCompleteItems: produceAutoCompleteItems,
                    ),
                    InkWell(
                      onTap: () async {
                        var date = await _selectDate(
                            context, shipmentDateController.text);
                        if (date != null)
                          setState(() {
                            shipmentDateController.text = date;
                          });
                      },
                      child: IgnorePointer(
                          child: RoundAutocompleteTextFormField(
                            labelText: 'Date of Shipment',
                            icon: Icons.calendar_today,
                            controller: shipmentDateController,
                          )
                      ),
                    ),
                    RoundAutocompleteTextFormField(
                      labelText: 'Port of Shipment',
                      icon: Icons.location_city,
                      controller: shipmentPortController,
                      autoCompleteItems: shipmentPortAutoCompleteItems,
                    ),
                    InkWell(
                      onTap: () async {
                        var date = await _selectDate(
                            context, fumigationDateController.text);
                        if (date != null)
                          setState(() {
                            fumigationDateController.text = date;
                          });
                      },
                      child: IgnorePointer(
                          child: RoundAutocompleteTextFormField(
                            labelText: 'Date of Fumigation',
                            icon: Icons.calendar_today,
                            controller: fumigationDateController,
                          )
                      ),
                    ),
                    RoundAutocompleteTextFormField(
                      labelText: 'Destination',
                      icon: Icons.location_on,
                      controller: destinationController,
                      autoCompleteItems: destinationAutoCompleteItems,
                    ),
                    InkWell(
                      onTap: () async {
                        var date = await _selectDate(
                            context, departureDateController.text);
                        if (date != null)
                          setState(() {
                            departureDateController.text = date;
                          });
                      },
                      child: IgnorePointer(
                          child: RoundAutocompleteTextFormField(
                            labelText: 'Date of Departure',
                            icon: Icons.calendar_today,
                            controller: departureDateController,
                          )
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                    ),
                    PrimaryButton(
                      isProcessing: isProcessing,
                      label: 'Submit',
                      onPressed: () => saveContainer(context),
                    )
                  ],
                ),
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          }
        )
      ),
    );
  }

  Future<bool> initAutoCompleteItems() async {
    if (await localStorage.ready && !hasFetchedAutoCompleteItems) {
      shippingLineAutoCompleteItems = localStorage.getItem('shippingLine') != null ? List<String>.from(localStorage.getItem('shippingLine')) : List<String>();
      exporterAutoCompleteItems = localStorage.getItem('exporter') != null ? List<String>.from(localStorage.getItem('exporter')) : List<String>();
      importerAutoCompleteItems = localStorage.getItem('importer') != null ? List<String>.from(localStorage.getItem('importer')) : List<String>();
      sizeAutoCompleteItems = localStorage.getItem('size') != null ? List<String>.from(localStorage.getItem('size')) : List<String>();
      produceAutoCompleteItems = localStorage.getItem('produce') != null ? List<String>.from(localStorage.getItem('produce')) : List<String>();
      shipmentPortAutoCompleteItems = localStorage.getItem('shipmentPort') != null ? List<String>.from(localStorage.getItem('shipmentPort')) : List<String>();
      destinationAutoCompleteItems = localStorage.getItem('destination') != null ? List<String>.from(localStorage.getItem('destination')) : List<String>();
      hasFetchedAutoCompleteItems = true;
    }

    return true;
  }

  Future<String> _selectDate(BuildContext context, String currentDate) async {
    DateTime datePicked = await showDatePicker(
        context: context,
        initialDate: currentDate.isNotEmpty
            ? dateFormatter.parse(currentDate)
            : DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2101));

    if (datePicked != null && datePicked.toString() != currentDate) {
      return dateFormatter.format(datePicked);
    }
    return null;
  }

  Future<void> saveContainer(BuildContext context) async {
    setState(() {
      isProcessing = true;
    });

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      var container = ShippingContainer(
        id: isEdit ? shippingContainer.id : null,
        containerNumber: containerNumberController.text,
        shippingLine: shippingLineController.text,
        exporter: exporterController.text,
        importer: importerController.text,
        size: sizeController.text.isNotEmpty ? int.tryParse(sizeController.text) : null,
        produce:  produceController.text,
        shipmentPort: shipmentPortController.text,
        destination: destinationController.text,
        dateOfShipment: shipmentDateController.text.isNotEmpty ? dateFormatter.parse(shipmentDateController.text) : null,
        dateOfDeparture: departureDateController.text.isNotEmpty ? dateFormatter.parse(departureDateController.text) : null,
        dateOfFumigation: fumigationDateController.text.isNotEmpty ? dateFormatter.parse(fumigationDateController.text) : null,
      );

      var containerService = ContainerService();
      bool isSaved = await containerService.upsertContainer(container);
      if (isSaved) {
        await AlertHelper.showSuccessDialog(context, "Saved successfully");
        Navigator.of(context).pop(container);
      }
      else {
        await AlertHelper.showErrorDialog(context, "Could not save. Please try again");
      }
    }

    setState(() {
      isProcessing = false;
    });
  }
}