import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import 'package:cms/models/container.dart';
import 'package:cms/models/container_filter.dart';

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

  ShippingContainerFilter searchFilter;
  List<ShippingContainer> containerList;

  bool isListSearchResultData;

  @override
  void initState() {
    isListSearchResultData = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Container Management System'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final searchResult = await Navigator.of(context).pushNamed(Routes.CONTAINER_FILTER,
                arguments:{
                  RouteContainerFilterArguments.SHIPPING_CONTAINER_FILTER: searchFilter
                }
              );

              if (searchResult != null) {
                var searchResultMap = searchResult as Map<String, dynamic>;
                setState(() {
                  isListSearchResultData = true;
                  this.searchFilter = searchResultMap['filter'];
                  this.containerList = searchResultMap['result'];
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {

            },
          ),
          PopupMenuButton<ExportOption>(
            onSelected: (ExportOption option) {
              switch (option) {
                case ExportOption.CSV:
                  break;
                case ExportOption.PDF:
                  break;
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<ExportOption>> [
              PopupMenuItem<ExportOption>(
                value: ExportOption.CSV,
                child: Text('Export to CSV'),
              ),
              PopupMenuItem<ExportOption>(
                value: ExportOption.CSV,
                child: Text('Export to PDF'),
              )
            ],
          )
        ],
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
              //Store items to be used for auto complete and search in local storage
              if (!isListSearchResultData) {
                debugPrint('Entered auto complete');
                var shippingLineAutoCompleteItems = localStorage.getItem(
                    'shippingLine') != null ? List<String>.from(
                    localStorage.getItem('shippingLine')) : List<String>();
                var exporterAutoCompleteItems = localStorage.getItem(
                    'exporter') != null ? List<String>.from(
                    localStorage.getItem('exporter')) : List<String>();
                var importerAutoCompleteItems = localStorage.getItem(
                    'importer') != null ? List<String>.from(
                    localStorage.getItem('importer')) : List<String>();
                var sizeAutoCompleteItems = localStorage.getItem('size') != null
                    ? List<String>.from(localStorage.getItem('size'))
                    : List<String>();
                var produceAutoCompleteItems = localStorage.getItem(
                    'produce') != null ? List<String>.from(
                    localStorage.getItem('produce')) : List<String>();
                var shipmentPortAutoCompleteItems = localStorage.getItem(
                    'shipmentPort') != null ? List<String>.from(
                    localStorage.getItem('shipmentPort')) : List<String>();
                var destinationAutoCompleteItems = localStorage.getItem(
                    'destination') != null ? List<String>.from(
                    localStorage.getItem('destination')) : List<String>();

                snapshot.data.forEach((container) {
                  //Sync autocomplete items
                  if (container.shippingLine.isNotEmpty &&
                      !shippingLineAutoCompleteItems.contains(
                          container.shippingLine))
                    shippingLineAutoCompleteItems.add(container.shippingLine);

                  if (container.exporter.isNotEmpty &&
                      !exporterAutoCompleteItems.contains(container.exporter))
                    exporterAutoCompleteItems.add(container.exporter);

                  if (container.importer.isNotEmpty &&
                      !importerAutoCompleteItems.contains(container.importer))
                    importerAutoCompleteItems.add(container.importer);

                  if (container.size != null && !sizeAutoCompleteItems.contains(
                      container.size.toString()))
                    sizeAutoCompleteItems.add(container.size.toString());

                  if (container.produce.isNotEmpty &&
                      !produceAutoCompleteItems.contains(container.produce))
                    produceAutoCompleteItems.add(container.produce);

                  if (container.shipmentPort.isNotEmpty &&
                      !shipmentPortAutoCompleteItems.contains(
                          container.shipmentPort))
                    shipmentPortAutoCompleteItems.add(container.shipmentPort);

                  if (container.destination.isNotEmpty &&
                      !destinationAutoCompleteItems.contains(
                          container.destination))
                    destinationAutoCompleteItems.add(container.destination);
                });

                //Update localStorage
                localStorage.setItem(
                    'shippingLine', shippingLineAutoCompleteItems);
                localStorage.setItem('exporter', exporterAutoCompleteItems);
                localStorage.setItem('importer', importerAutoCompleteItems);
                localStorage.setItem('size', sizeAutoCompleteItems);
                localStorage.setItem('produce', produceAutoCompleteItems);
                localStorage.setItem(
                    'shipmentPort', shipmentPortAutoCompleteItems);
                localStorage.setItem(
                    'destination', destinationAutoCompleteItems);

                localStorage.deleteItem('searchFilter'); //Remove existing search filter
              }

              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  final container = snapshot.data[index];
                  return ListTile(
                    title: Text("${container.containerNumber.toString()} ${container.produce.isNotEmpty ? '- ' + container.produce : ''}"),
                    subtitle: Text(container.shippingLine),
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        (index + 1).toString() + ".",
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteContainer(context, container.id)
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                          Routes.CONTAINER_DETAIL,
                          arguments: {
                            RouteContainerDetailArguments.SHIPPING_CONTAINER: container
                          }
                      );
                    },
                  );
                },
              );
            }
            else {
              return Center(
                child: Text("No containers"),
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
    if (await AlertHelper.showConfirmDialog(context, "Are you sure you want to delete this container")) {
      if (await containerService.deleteContainer(id)) {
        await AlertHelper.showSuccessDialog(
            context, "Container deleted successfully");
        setState(() {}); //Force refresh
      }
      else {
        await AlertHelper.showErrorDialog(
            context, "An error occurred. Please try again");
      }
    }
  }

  Future<List<ShippingContainer>> fetchContainerData() async {
    await localStorage.ready;
    if (isListSearchResultData) {
      return containerList;
    }
    else {
      containerList = await containerService.getContainers();
      return containerList;
    }
  }
}

enum ExportOption {
  CSV,
  PDF
}