import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cms/routes.dart';
import 'package:cms/helpers/alert_helper.dart';

import 'package:cms/services/container.dart';

import 'package:cms/models/container.dart';

import 'package:cms/elements/floating_button_with_text.dart';

class ContainerDetail extends StatefulWidget {
  final ShippingContainer shippingContainer;

  ContainerDetail({this.shippingContainer});

  @override
  State<StatefulWidget> createState() => _ContainerDetailState(this.shippingContainer);
}

class _ContainerDetailState extends State<ContainerDetail> {
  ShippingContainer shippingContainer;

  _ContainerDetailState(this.shippingContainer);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Container ${shippingContainer.containerNumber}"),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (PopupMenuOption option) {
              switch(option) {
                case PopupMenuOption.Edit:
                  editContainer();
                  break;
                case PopupMenuOption.Delete:
                  deleteContainer(context);
                  break;
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<PopupMenuOption>>[
              const PopupMenuItem<PopupMenuOption>(
                value: PopupMenuOption.Edit,
                child: Text('Edit'),
              ),
              const PopupMenuItem<PopupMenuOption>(
                value: PopupMenuOption.Delete,
                child: Text('Delete'),
              )
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButtonWithText(
        text: 'Edit',
        icon: Icons.edit,
        onPressed: () async {

        },
      ),
      body: ListView(
        children: buildContainerDetails(),
      ),
    );
  }

  List<Widget> buildContainerDetails() {
    var details = List<Widget>();
    final dateFormatter = new DateFormat('yyyy-MM-dd');

    if (shippingContainer.containerNumber.isNotEmpty)
      details.add(getSingleTile(
          Icons.info, 'Container Number', shippingContainer.containerNumber));

    if (shippingContainer.shippingLine.isNotEmpty)
      details.add(getSingleTile(Icons.shopping_cart, 'Shipping Line',
          shippingContainer.shippingLine));

    if (shippingContainer.exporter.isNotEmpty)
      details.add(
          getSingleTile(Icons.explore, 'Exporter', shippingContainer.exporter));

    if (shippingContainer.importer.isNotEmpty)
      details.add(getSingleTile(
          Icons.import_export, 'Importer', shippingContainer.importer));

    if (shippingContainer.size != null)
      details.add(getSingleTile(
          Icons.format_size, 'Size', shippingContainer.size.toString()));

    if (shippingContainer.produce.isNotEmpty)
      details.add(
          getSingleTile(Icons.folder, 'Produce', shippingContainer.produce));

    if (shippingContainer.dateOfShipment != null)
      details.add(getSingleTile(Icons.calendar_today, 'Date of Shipment',
          dateFormatter.format(shippingContainer.dateOfShipment)));

    if (shippingContainer.shipmentPort.isNotEmpty)
      details.add(getSingleTile(Icons.location_city, 'Shipment Port',
          shippingContainer.shipmentPort));

    if (shippingContainer.dateOfFumigation != null)
      details.add(getSingleTile(Icons.calendar_today, 'Date of Fumigation',
          dateFormatter.format(shippingContainer.dateOfFumigation)));

    if (shippingContainer.destination.isNotEmpty)
      details.add(getSingleTile(
          Icons.location_on, 'Destination', shippingContainer.destination));

    if (shippingContainer.dateOfDeparture != null)
      details.add(getSingleTile(Icons.calendar_today, 'Date of Departure',
          dateFormatter.format(shippingContainer.dateOfDeparture)));

    return details;
  }

  editContainer() async {
    final updatedContainer = await Navigator.of(context).pushNamed(Routes.CONTAINER_FORM, arguments: {
      RouteContainerFormArguments.SHIPPING_CONTAINER: shippingContainer
    });

    if (updatedContainer != null)
      setState(() {
        shippingContainer = updatedContainer;
      });
  }

  deleteContainer(BuildContext context) async {
    if (await AlertHelper.showConfirmDialog(context, "Are you sure you want to delete this container")) {
      var containerService = ContainerService();
      if (await containerService.deleteContainer(shippingContainer.id)) {
        await AlertHelper.showSuccessDialog(
            context, "Container deleted successfully");
        Navigator.of(context).pop();
      }
      else {
        await AlertHelper.showErrorDialog(
            context, "An error occurred. Please try again");
      }
    }
  }

  Widget getSingleTile(IconData icon, String title, String data) {
    return ListTile(
        leading: Icon(icon), title: Text(data), subtitle: Text(title));
  }
}

enum PopupMenuOption {
  Edit,
  Delete
}
