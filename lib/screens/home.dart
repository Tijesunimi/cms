import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  bool shouldRefreshDataFromDb;

  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = false;

  @override
  void initState() {
    shouldRefreshDataFromDb = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Refreshing');

    return Scaffold(
      appBar: AppBar(
        title: Text('Container Management System'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final searchResult = await Navigator.of(context)
                  .pushNamed(Routes.CONTAINER_FILTER, arguments: {
                RouteContainerFilterArguments.SHIPPING_CONTAINER_FILTER:
                    searchFilter
              });

              if (searchResult != null) {
                var searchResultMap = searchResult as Map<String, dynamic>;
                if (searchResultMap['fliter'] == 'cleared') {
                  setState(() {
                    searchFilter = null;
                    shouldRefreshDataFromDb = true;
                  });
                }
                else {
                  setState(() {
                    this.searchFilter = searchResultMap['filter'];
                    this.containerList = searchResultMap['result'];
                  });
                }
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                shouldRefreshDataFromDb = true;
              });
            },
          ),
          PopupMenuButton<Option>(
            onSelected: (Option option) {
              switch (option) {
                case Option.DeleteSelection:
                  deleteSelectedContainers(context);
                  break;
                case Option.CSV:
                  break;
                case Option.PDF:
                  break;
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<Option>>[
                  PopupMenuItem<Option>(
                    value: Option.DeleteSelection,
                    child: Text('Delete Selected Items'),
                  ),
                  PopupMenuItem<Option>(
                    value: Option.CSV,
                    child: Text('Export to CSV'),
                  ),
                  PopupMenuItem<Option>(
                    value: Option.CSV,
                    child: Text('Export to PDF'),
                  )
                ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButtonWithText(
        text: 'Add',
        icon: Icons.add,
        onPressed: () async {
          var container =
              await Navigator.of(context).pushNamed(Routes.CONTAINER_FORM);
          if (container != null)
            setState(() {
              shouldRefreshDataFromDb = true;
            });
        }
      ),
      body: FutureBuilder(
        future: Future.wait([
          localStorage.ready,
          fetchContainerData()
        ]),
        builder: (context, snapshot) {
          debugPrint('Entered future builder');
          if (snapshot.hasData) {
            print(snapshot.data);
            var snapshotContainers = snapshot.data[1];
            if (snapshotContainers.length > 0) {
              debugPrint("Entered future result");

              //Store items to be used for auto complete and search in local storage
              if (shouldRefreshDataFromDb) {
                debugPrint('Entered auto complete');
                var shippingLineAutoCompleteItems = List<String>();
                var exporterAutoCompleteItems = List<String>();
                var importerAutoCompleteItems = List<String>();
                var sizeAutoCompleteItems = List<String>();
                var produceAutoCompleteItems = List<String>();
                var shipmentPortAutoCompleteItems = List<String>();
                var destinationAutoCompleteItems = List<String>();

                snapshotContainers.forEach((container) {
                  print(container.shippingLine);
                  //Sync autocomplete items
                  if (container.shippingLine.isNotEmpty &&
                      !shippingLineAutoCompleteItems
                          .contains(container.shippingLine))
                    shippingLineAutoCompleteItems.add(container.shippingLine);
                  print(shippingLineAutoCompleteItems);

                  if (container.exporter.isNotEmpty &&
                      !exporterAutoCompleteItems.contains(container.exporter))
                    exporterAutoCompleteItems.add(container.exporter);

                  if (container.importer.isNotEmpty &&
                      !importerAutoCompleteItems.contains(container.importer))
                    importerAutoCompleteItems.add(container.importer);

                  if (container.size != null &&
                      !sizeAutoCompleteItems
                          .contains(container.size.toString()))
                    sizeAutoCompleteItems.add(container.size.toString());

                  if (container.produce.isNotEmpty &&
                      !produceAutoCompleteItems.contains(container.produce))
                    produceAutoCompleteItems.add(container.produce);

                  if (container.shipmentPort.isNotEmpty &&
                      !shipmentPortAutoCompleteItems
                          .contains(container.shipmentPort))
                    shipmentPortAutoCompleteItems.add(container.shipmentPort);

                  if (container.destination.isNotEmpty &&
                      !destinationAutoCompleteItems
                          .contains(container.destination))
                    destinationAutoCompleteItems.add(container.destination);
                });

                //Update localStorage
                print(shippingLineAutoCompleteItems);
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

                localStorage
                    .deleteItem('searchFilter'); //Remove existing search filter

                shouldRefreshDataFromDb = false; //Reset should refresh from db
              }

              final containerDataSource = ShippingContainerDataSource(
                  data: snapshotContainers,
                  context: context,
                  onItemPress: (container) => viewContainer(container));

              return Scrollbar(
                child:
                    ListView(padding: EdgeInsets.all(0.0), children: <Widget>[
                  PaginatedDataTable(
                      header:
                          Text("Container List", textAlign: TextAlign.center),
                      rowsPerPage: _rowsPerPage,
                      onRowsPerPageChanged: (int value) {
                        setState(() {
                          _rowsPerPage = value;
                        });
                      },
                      onSelectAll: containerDataSource._selectAll,
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      columns: [
                        DataColumn(
                          label: Text("S/NO"),
                          numeric: true,
                        ),
                        DataColumn(
                          label: Text("CONTAINER NO"),
                          onSort: (int columnIndex, bool ascending) {
                            debugPrint("Is Ascending: $ascending");
                            containerDataSource._sort<String>(
                                (ShippingContainer d) => d.containerNumber,
                                ascending);
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        DataColumn(
                            label: Text("SHIPPING LINE"),
                            onSort: (int columnIndex, bool ascending) {
                              containerDataSource._sort<String>(
                                  (ShippingContainer d) => d.shippingLine,
                                  ascending);
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                              });
                            }),
                        DataColumn(
                            label: Text("PRODUCE"),
                            onSort: (int columnIndex, bool ascending) {
                              containerDataSource._sort<String>(
                                  (ShippingContainer d) => d.produce,
                                  ascending);
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                              });
                            }),
                        DataColumn(
                            label: Text("SIZE"),
                            numeric: true,
                            onSort: (int columnIndex, bool ascending) {
                              containerDataSource._sort<String>(
                                  (ShippingContainer d) => d.size.toString(),
                                  ascending);
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                              });
                            }),
                        DataColumn(
                            label: Text("DESTINATION"),
                            onSort: (int columnIndex, bool ascending) {
                              containerDataSource._sort<String>(
                                  (ShippingContainer d) => d.destination,
                                  ascending);
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                              });
                            }),
                        DataColumn(
                            label: Text("EXPORTER"),
                            onSort: (int columnIndex, bool ascending) {
                              containerDataSource._sort<String>(
                                  (ShippingContainer d) => d.exporter,
                                  ascending);
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                              });
                            }),
                        DataColumn(
                            label: Text("IMPORTER"),
                            onSort: (int columnIndex, bool ascending) {
                              containerDataSource._sort<String>(
                                  (ShippingContainer d) => d.importer,
                                  ascending);
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                              });
                            }),
                        DataColumn(
                            label: Text("DATE OF SHIPMENT"),
                            onSort: (int columnIndex, bool ascending) {
                              containerDataSource._sort<DateTime>(
                                  (ShippingContainer d) => d.dateOfShipment ?? new DateTime(1900, 1, 1),
                                  ascending);
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                              });
                            }),
                        DataColumn(
                            label: Text("SHIPMENT PORT"),
                            onSort: (int columnIndex, bool ascending) {
                              containerDataSource._sort<String>(
                                  (ShippingContainer d) => d.shipmentPort,
                                  ascending);
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                              });
                            }),
                        DataColumn(
                            label: Text("DATE OF FUMIGATION"),
                            onSort: (int columnIndex, bool ascending) {
                              containerDataSource._sort<DateTime>(
                                  (ShippingContainer d) => d.dateOfFumigation ?? new DateTime(1900, 1, 1),
                                  ascending);
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                              });
                            }),
                        DataColumn(
                            label: Text("DATE OF DEPARTURE"),
                            onSort: (int columnIndex, bool ascending) {
                              containerDataSource._sort<DateTime>(
                                  (ShippingContainer d) => d.dateOfDeparture ?? new DateTime(1900, 1, 1),
                                  ascending);
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                              });
                            }),
                        DataColumn(label: Text("")),
                      ],
                      source: containerDataSource),
                ]),
              );
            } else {
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

  void _sort<T>(Comparable<T> getField(ShippingContainer d), int columnIndex,
      bool ascending) {
    //_dessertsDataSource._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  viewContainer(ShippingContainer container) async {
    var result = await Navigator.of(context).pushNamed(Routes.CONTAINER_DETAIL,
        arguments: {
          RouteContainerDetailArguments.SHIPPING_CONTAINER: container
        });
    if (result != null && result == true)
      setState(() {
        shouldRefreshDataFromDb = true;
      });
  }

  deleteSelectedContainers(BuildContext context) async {
    var selectedContainers = containerList.where((container) => container.selected);
    if (selectedContainers.length > 0) {
      if (await AlertHelper.showConfirmDialog(
          context, "Are you sure you want to delete the selected containers")) {
        if (await containerService.deleteAllContainers(selectedContainers.map((c) => c.id).toList())) {
          await AlertHelper.showSuccessDialog(
              context, "Containers deleted successfully");
          setState(() {
            shouldRefreshDataFromDb = true;
          }); //Force refresh
        } else {
          await AlertHelper.showErrorDialog(
              context, "An error occurred. Please try again");
        }
      }
    }
  }

  Future<List<ShippingContainer>> fetchContainerData() async {
    if (shouldRefreshDataFromDb) {
      containerList = await containerService.getContainers();
    }
    return containerList;
  }
}

class ShippingContainerDataSource extends DataTableSource {
  final List<ShippingContainer> data;
  final BuildContext context;
  final Function onItemPress;

  ShippingContainerDataSource({this.data, this.context, this.onItemPress});

  void _sort<T>(Comparable<T> getField(ShippingContainer d), bool ascending) {
    data.sort((ShippingContainer a, ShippingContainer b) {
      if (ascending) {
        final ShippingContainer c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    final dateFormatter = new DateFormat('yyyy-MM-dd');

    assert(index >= 0);
    if (index >= data.length) return null;
    final ShippingContainer container = data[index];
    return DataRow.byIndex(
      index: index,
      selected: container.selected,
      onSelectChanged: (bool value) {
        if (container.selected != value) {
          _selectedCount += value ? 1 : -1;
          assert(_selectedCount >= 0);
          container.selected = value;
          notifyListeners();
        }
      },
      cells: <DataCell>[
        DataCell(Text('${(index + 1).toString()}')),
        DataCell(Text('${container.containerNumber}')),
        DataCell(Text('${container.shippingLine}')),
        DataCell(Text('${container.produce}')),
        DataCell(
            Text('${container.size != null ? container.size.toString() : ""}')),
        DataCell(Text('${container.destination}')),
        DataCell(Text('${container.exporter}')),
        DataCell(Text('${container.importer}')),
        DataCell(Text(
            '${container.dateOfShipment != null ? dateFormatter.format(container.dateOfShipment) : ""}')),
        DataCell(Text('${container.shipmentPort}')),
        DataCell(Text(
            '${container.dateOfFumigation != null ? dateFormatter.format(container.dateOfFumigation) : ""}')),
        DataCell(Text(
            '${container.dateOfDeparture != null ? dateFormatter.format(container.dateOfDeparture) : ""}')),
        DataCell(IconButton(
            icon: Icon(Icons.keyboard_arrow_right),
            color: Theme.of(context).primaryColor,
            onPressed: () => onItemPress(container))),
      ],
    );
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  void _selectAll(bool checked) {
    for (ShippingContainer container in data) container.selected = checked;
    _selectedCount = checked ? data.length : 0;
    notifyListeners();
  }
}

enum Option { CSV, PDF, DeleteSelection }