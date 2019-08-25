import 'dart:async';

import 'package:cms/models/container.dart';

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
}