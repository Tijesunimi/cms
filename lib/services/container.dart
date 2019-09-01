import 'dart:async';

import 'package:cms/models/container.dart';
import 'package:cms/models/container_filter.dart';

import 'package:cms/db.dart';

class ContainerService {
  Future<List<ShippingContainer>> getContainers() async {
    var db = DatabaseHelper.instance;
    return await db.fetchContainers();

  }

  Future<bool> upsertContainer(ShippingContainer container) async {
    var db = DatabaseHelper.instance;
    if (container.id == null) {
      var result = await db.insertContainer(container);
      return result > 0;
    }
    else {
      var result = await db.updateContainer(container);
      return result > 0;
    }
  }

  Future<bool> deleteContainer(int id) async {
    var db = DatabaseHelper.instance;
    int result = await db.deleteContainer(id);
    return result > 0;
  }

  Future<bool> deleteAllContainers(List<int> ids) async {
    var db = DatabaseHelper.instance;
    int result = await db.deleteContainerList(ids);
    return result > 0;
  }

  Future<List<ShippingContainer>> searchContainers(ShippingContainerFilter filter) async {
    String filterQuery = _getFilterQueryFromFilter(filter);
    var db = DatabaseHelper.instance;
    return await db.fetchContainersUsingFilterQuery(filterQuery);
  }

  String _getFilterQueryFromFilter(ShippingContainerFilter filter) {
    List<String> filterQueryBuilder = List<String>();

    if (filter.containerNumber.isNotEmpty)
      filterQueryBuilder.add("${DatabaseHelper.containerColumnContainerNo} LIKE '%${filter.containerNumber}%'");

    if (filter.shippingLine.isNotEmpty)
      filterQueryBuilder.add("${DatabaseHelper.containerColumnShippingLine} = '${filter.shippingLine}'");

    if (filter.exporter.isNotEmpty)
      filterQueryBuilder.add("${DatabaseHelper.containerColumnExporter} = '${filter.exporter}'");

    if (filter.importer.isNotEmpty)
      filterQueryBuilder.add("${DatabaseHelper.containerColumnImporter} = '${filter.importer}'");

    if (filter.size.isNotEmpty)
      filterQueryBuilder.add("${DatabaseHelper.containerColumnSize} = '${filter.size}'");

    if (filter.produce.isNotEmpty)
      filterQueryBuilder.add("${DatabaseHelper.containerColumnProduce} LIKE '%${filter.produce}%'");

    //This date comparison only works if date is stored in format YYYY-MM-DD
    if (filter.shipmentStartDate.isNotEmpty)
      filterQueryBuilder.add("${DatabaseHelper.containerColumnShipmentDate} >= '${filter.shipmentStartDate}'");

    if (filter.shipmentEndDate.isNotEmpty)
      filterQueryBuilder.add("${DatabaseHelper.containerColumnShipmentDate} <= '${filter.shipmentEndDate}'");

    if (filter.fumigationStartDate.isNotEmpty)
      filterQueryBuilder.add("${DatabaseHelper.containerColumnFumigationDate} >= '${filter.fumigationStartDate}'");

    if (filter.fumigationEndDate.isNotEmpty)
      filterQueryBuilder.add("${DatabaseHelper.containerColumnFumigationDate} <= '${filter.fumigationEndDate}'");

    if (filter.departureStartDate.isNotEmpty)
      filterQueryBuilder.add("${DatabaseHelper.containerColumnDepartureDate} >= '${filter.departureStartDate}'");

    if (filter.departureEndDate.isNotEmpty)
      filterQueryBuilder.add("${DatabaseHelper.containerColumnDepartureDate} <= '${filter.departureEndDate}'");

    String queryWhereClause = "";
    if (filterQueryBuilder.length > 0) {
      queryWhereClause = "WHERE ${filterQueryBuilder.join(" AND ")}";
    }

    return queryWhereClause;
  }
}