import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import 'package:cms/models/container.dart';

import 'package:cms/services/container.dart';

import 'package:cms/routes.dart';
import 'package:cms/helpers/alert_helper.dart';

import 'package:cms/elements/floating_button_with_text.dart';

class Homepage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final ContainerService containerService = ContainerService();
  final LocalStorage localStorage = LocalStorage('autocompleteitems');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Container Management System'),
      ),
      floatingActionButton: FloatingActionButtonWithText(
        text: 'Add',
        icon: Icons.add,
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.CONTAINER_FORM);
        }
      ),
      body: FutureBuilder<List<ShippingContainer>>(
        future: fetchContainerData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              var shippingLineAutoCompleteItems = localStorage.getItem('shippingLine') != null ? List<String>.from(localStorage.getItem('shippingLine')) : List<String>();
              var exporterAutoCompleteItems = localStorage.getItem('exporter') != null ? List<String>.from(localStorage.getItem('exporter')) : List<String>();
              var importerAutoCompleteItems = localStorage.getItem('importer') != null ? List<String>.from(localStorage.getItem('importer')) : List<String>();
              var sizeAutoCompleteItems = localStorage.getItem('size') != null ? List<String>.from(localStorage.getItem('size')) : List<String>();
              var produceAutoCompleteItems = localStorage.getItem('produce') != null ? List<String>.from(localStorage.getItem('produce')) : List<String>();
              var shipmentPortAutoCompleteItems = localStorage.getItem('shipmentPort') != null ? List<String>.from(localStorage.getItem('shipmentPort')) : List<String>();
              var destinationAutoCompleteItems = localStorage.getItem('destination') != null ? List<String>.from(localStorage.getItem('destination')) : List<String>();

              var listTiles = new List<Widget>();
              int index = 1;

              snapshot.data.forEach((container) {
                //Sync autocomplete items
                if (container.shippingLine.isNotEmpty && !shippingLineAutoCompleteItems.contains(container.shippingLine))
                  shippingLineAutoCompleteItems.add(container.shippingLine);

                if (container.exporter.isNotEmpty && !exporterAutoCompleteItems.contains(container.exporter))
                  exporterAutoCompleteItems.add(container.exporter);

                if (container.importer.isNotEmpty && !importerAutoCompleteItems.contains(container.importer))
                  importerAutoCompleteItems.add(container.importer);

                if (container.size != null && !sizeAutoCompleteItems.contains(container.size.toString()))
                  sizeAutoCompleteItems.add(container.size.toString());

                if (container.produce.isNotEmpty && !produceAutoCompleteItems.contains(container.produce))
                  produceAutoCompleteItems.add(container.produce);

                if (container.shipmentPort.isNotEmpty && !shipmentPortAutoCompleteItems.contains(container.shipmentPort))
                  shipmentPortAutoCompleteItems.add(container.shipmentPort);

                if (container.destination.isNotEmpty && !destinationAutoCompleteItems.contains(container.destination))
                  destinationAutoCompleteItems.add(container.destination);

                //Add list tile widget
                listTiles.add(ListTile(
                  title: Text("${container.containerNumber.toString()} ${container.produce.isNotEmpty ? '- ' + container.produce : ''}"),
                  subtitle: Text(container.shippingLine),
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      index.toString() + ".",
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async { 
                      if (await AlertHelper.showConfirmDialog(context, "Are you sure you want to delete this container")) {
                        deleteContainer(context, container.id);
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                        Routes.CONTAINER_DETAIL,
                        arguments: {
                          RouteContainerDetailArguments.SHIPPING_CONTAINER: container
                        }
                    );
                  },
                ));
                index++;
              });

              //Update localStorage
              localStorage.setItem('shippingLine', shippingLineAutoCompleteItems);
              localStorage.setItem('exporter', exporterAutoCompleteItems);
              localStorage.setItem('importer', importerAutoCompleteItems);
              localStorage.setItem('size', sizeAutoCompleteItems);
              localStorage.setItem('produce', produceAutoCompleteItems);
              localStorage.setItem('shipmentPort', shipmentPortAutoCompleteItems);
              localStorage.setItem('destination', destinationAutoCompleteItems);

              return ListView(
                children: listTiles,
              );
            }
            else {
              return Center(
                child: Text("No containers have been created"),
              );
            }
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
              child: Text("An error occurred. Please restart the app"),
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  deleteContainer(BuildContext context, int id) async {
    if (await containerService.deleteContainer(id)) {
      await AlertHelper.showSuccessDialog(context, "Container deleted successfully");
    }
    else {
      await AlertHelper.showErrorDialog(context, "An error occurred. Please try again");
    }
  }

  Future<List<ShippingContainer>> fetchContainerData() async {
    await localStorage.ready;
    return await containerService.getContainers();
  }
}