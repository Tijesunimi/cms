import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

import 'package:cms/models/container_filter.dart';

import 'package:cms/services/container.dart';

import 'package:cms/elements/round_dropdown_form_field.dart';
import 'package:cms/elements/round_text_form_field.dart';
import 'package:cms/elements/round_autocomplete_text_form_field.dart';
import 'package:cms/elements/primary_button.dart';

class ContainerFilter extends StatefulWidget {
  final ShippingContainerFilter previousFilter;

  ContainerFilter({this.previousFilter});

  @override
  State<StatefulWidget> createState() => _ContainerFilterState(this.previousFilter);
}

class _ContainerFilterState extends State<ContainerFilter> {
  final ShippingContainerFilter previousFilter;

  _ContainerFilterState(this.previousFilter);

  List<String> shippingLineAutoCompleteItems = List<String>();
  List<String> exporterAutoCompleteItems = List<String>();
  List<String> importerAutoCompleteItems = List<String>();
  List<String> sizeAutoCompleteItems = List<String>();
  List<String> produceAutoCompleteItems = List<String>();
  List<String> shipmentPortAutoCompleteItems = List<String>();
  List<String> destinationAutoCompleteItems = List<String>();

  final LocalStorage localStorage = LocalStorage('autocompleteitems');

  final TextEditingController containerNumberController = TextEditingController();
  final TextEditingController produceController = TextEditingController();
  final TextEditingController shipmentStartDateController = TextEditingController();
  final TextEditingController shipmentEndDateController = TextEditingController();
  final TextEditingController fumigationStartDateController = TextEditingController();
  final TextEditingController fumigationEndDateController = TextEditingController();
  final TextEditingController departureStartDateController = TextEditingController();
  final TextEditingController departureEndDateController = TextEditingController();

  final dateFormatter = new DateFormat('yyyy-MM-dd');

  String shippingLine, exporter, importer, size, shipmentPort, destination;

  bool isProcessing;

  @override
  void initState() {
    isProcessing = false;

    if (previousFilter != null) {
      shippingLine = previousFilter.shippingLine;
      exporter = previousFilter.exporter;
      importer = previousFilter.importer;
      size = previousFilter.size;
      shipmentPort = previousFilter.shipmentPort;
      destination = previousFilter.destination;

      containerNumberController.text = previousFilter.containerNumber;
      produceController.text = previousFilter.produce;
      shipmentStartDateController.text = previousFilter.shipmentStartDate;
      shipmentEndDateController.text = previousFilter.shipmentEndDate;
      fumigationStartDateController.text = previousFilter.fumigationStartDate;
      fumigationEndDateController.text = previousFilter.fumigationEndDate;
      departureStartDateController.text = previousFilter.departureStartDate;
      departureEndDateController.text = previousFilter.departureEndDate;
    }
    else {
      shippingLine = "";
      exporter = "";
      importer = "";
      size = "";
      shipmentPort = "";
      destination = "";
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: FutureBuilder(
        future: initAutoCompleteItems(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: Column(
                children: buildFilterParams(),
              ),
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }

  List<Widget> buildFilterParams() {
    List<Widget> params = [
      RoundTextFormField(
        controller: containerNumberController,
        icon: Icons.info,
        labelText: 'Container Number',
      )
    ];

    if (shippingLineAutoCompleteItems.length > 0) {
      params.add(RoundDropdownFormField(
        labelText: 'Shipping Line',
        icon: Icons.shopping_cart,
        items: shippingLineAutoCompleteItems,
        onChanged: (value) {
          shippingLine = value;
        },
        initialValue: shippingLine,
        hasAllOption: true
      ));
    }

    params.add(RoundAutocompleteTextFormField(
      labelText: 'Produce',
      icon: Icons.folder,
      controller: produceController,
      autoCompleteItems: produceAutoCompleteItems,
    ));

    if (exporterAutoCompleteItems.length > 0) {
      params.add(RoundDropdownFormField(
        labelText: 'Exporter',
        icon: Icons.explore,
        items: exporterAutoCompleteItems,
        onChanged: (value) {
          exporter = value;
        },
        initialValue: exporter,
        hasAllOption: true
      ));
    }

    if (importerAutoCompleteItems.length > 0) {
      params.add(RoundDropdownFormField(
        labelText: 'Importer',
        icon: Icons.import_export,
        items: importerAutoCompleteItems,
        onChanged: (value) {
          importer = value;
        },
        initialValue: importer,
        hasAllOption: true
      ));
    }

    if (sizeAutoCompleteItems.length > 0) {
      params.add(RoundDropdownFormField(
        labelText: 'Size',
        icon: Icons.format_size,
        items: sizeAutoCompleteItems,
        onChanged: (value) {
          size = value;
        },
        initialValue: size,
        hasAllOption: true
      ));
    }

    if (shipmentPortAutoCompleteItems.length > 0) {
      params.add(RoundDropdownFormField(
        labelText: 'Shipment Port',
        icon: Icons.location_city,
        items: shipmentPortAutoCompleteItems,
        onChanged: (value) {
          shipmentPort = value;
        },
        initialValue: shipmentPort,
        hasAllOption: true
      ));
    }

    if (destinationAutoCompleteItems.length > 0) {
      params.add(RoundDropdownFormField(
        labelText: 'Destination',
        icon: Icons.location_on,
        items: destinationAutoCompleteItems,
        onChanged: (value) {
          destination = value;
        },
        initialValue: destination,
        hasAllOption: true
      ));
    }

    params.add(Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Date of Shipment',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.0
            ),
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: () async {
                  var date = await _selectDate(
                      context, shipmentStartDateController.text);
                  if (date != null)
                    setState(() {
                      shipmentStartDateController.text = date;
                    });
                },
                child: IgnorePointer(
                    child: RoundTextFormField(
                      labelText: 'Start Date',
                      icon: Icons.calendar_today,
                      controller: shipmentStartDateController,
                    )
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () async {
                  var date = await _selectDate(
                      context, shipmentEndDateController.text);
                  if (date != null)
                    setState(() {
                      shipmentEndDateController.text = date;
                    });
                },
                child: IgnorePointer(
                    child: RoundTextFormField(
                      labelText: 'End Date',
                      icon: Icons.calendar_today,
                      controller: shipmentEndDateController,
                    )
                ),
              ),
            )
          ],
        )
      ]
    ));

    params.add(Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Date of Fumigation',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17.0
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () async {
                    var date = await _selectDate(
                        context, fumigationStartDateController.text);
                    if (date != null)
                      setState(() {
                        fumigationStartDateController.text = date;
                      });
                  },
                  child: IgnorePointer(
                      child: RoundTextFormField(
                        labelText: 'Start Date',
                        icon: Icons.calendar_today,
                        controller: fumigationStartDateController,
                      )
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    var date = await _selectDate(
                        context, fumigationEndDateController.text);
                    if (date != null)
                      setState(() {
                        fumigationEndDateController.text = date;
                      });
                  },
                  child: IgnorePointer(
                      child: RoundTextFormField(
                        labelText: 'End Date',
                        icon: Icons.calendar_today,
                        controller: fumigationEndDateController,
                      )
                  ),
                ),
              )
            ],
          )
        ]
    ));

    params.add(Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Date of Departure',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17.0
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () async {
                    var date = await _selectDate(
                        context, departureStartDateController.text);
                    if (date != null)
                      setState(() {
                        departureStartDateController.text = date;
                      });
                  },
                  child: IgnorePointer(
                      child: RoundTextFormField(
                        labelText: 'Start Date',
                        icon: Icons.calendar_today,
                        controller: departureStartDateController,
                      )
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    var date = await _selectDate(
                        context, departureEndDateController.text);
                    if (date != null)
                      setState(() {
                        departureEndDateController.text = date;
                      });
                  },
                  child: IgnorePointer(
                      child: RoundTextFormField(
                        labelText: 'End Date',
                        icon: Icons.calendar_today,
                        controller: departureEndDateController,
                      )
                  ),
                ),
              )
            ],
          )
        ]
    ));

    params.add(Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: PrimaryButton(
        isProcessing: isProcessing,
        label: 'Search',
        onPressed: searchContainers,
      ),
    ));

    return params;
  }

  searchContainers() async {
    debugPrint(shippingLine);
    var filter = ShippingContainerFilter(
      containerNumber: containerNumberController.text,
      shippingLine: shippingLine,
      exporter: exporter,
      importer: importer,
      size: size,
      produce: produceController.text,
      shipmentPort: shipmentPort,
      destination: destination,
      shipmentStartDate: shipmentStartDateController.text,
      shipmentEndDate: shipmentEndDateController.text,
      fumigationStartDate: fumigationStartDateController.text,
      fumigationEndDate: fumigationEndDateController.text,
      departureStartDate: departureStartDateController.text,
      departureEndDate: departureEndDateController.text
    );

    final containerService = ContainerService();
    final result = await containerService.searchContainers(filter);
    Navigator.of(context).pop({
      'filter': filter,
      'result': result
    });
  }

  Future<bool> initAutoCompleteItems() async {
    if (await localStorage.ready) {
      shippingLineAutoCompleteItems = localStorage.getItem('shippingLine') != null ? List<String>.from(localStorage.getItem('shippingLine')) : List<String>();
      exporterAutoCompleteItems = localStorage.getItem('exporter') != null ? List<String>.from(localStorage.getItem('exporter')) : List<String>();
      importerAutoCompleteItems = localStorage.getItem('importer') != null ? List<String>.from(localStorage.getItem('importer')) : List<String>();
      sizeAutoCompleteItems = localStorage.getItem('size') != null ? List<String>.from(localStorage.getItem('size')) : List<String>();
      produceAutoCompleteItems = localStorage.getItem('produce') != null ? List<String>.from(localStorage.getItem('produce')) : List<String>();
      shipmentPortAutoCompleteItems = localStorage.getItem('shipmentPort') != null ? List<String>.from(localStorage.getItem('shipmentPort')) : List<String>();
      destinationAutoCompleteItems = localStorage.getItem('destination') != null ? List<String>.from(localStorage.getItem('destination')) : List<String>();
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
}