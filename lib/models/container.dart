import 'package:intl/intl.dart';

class ShippingContainer {
  final int id;
  final String containerNumber;
  final String shippingLine;
  final String exporter;
  final String importer;
  final int size;
  final String produce;
  final String destination;
  final String shipmentPort;
  final DateTime dateOfShipment;
  final DateTime dateOfFumigation;
  final DateTime dateOfDeparture;

  ShippingContainer({ this.id,
    this.containerNumber,
    this.shippingLine,
    this.exporter,
    this.importer,
    this.size,
    this.produce,
    this.destination,
    this.shipmentPort,
    this.dateOfShipment,
    this.dateOfFumigation,
    this.dateOfDeparture
  });

  factory ShippingContainer.fromJson(Map<String, dynamic> json) {
    final dateFormatter = new DateFormat('yyyy-MM-dd');
    return ShippingContainer(
      id: json['id'],
      containerNumber: json['container_no'],
      shippingLine: json['shipping_line'],
      exporter: json['exporter'],
      importer: json['importer'],
      size: json['size'],
      produce: json['produce'],
      destination: json['destination'],
      shipmentPort: json['shipment_port'],
      dateOfShipment: json['date_shipment'] == null ? null : dateFormatter.parse(json['date_shipment']),
      dateOfFumigation: json['date_fumigation'] == null ? null : dateFormatter.parse(json['date_fumigation']),
      dateOfDeparture: json['date_departure'] == null ? null : dateFormatter.parse(json['date_departure'])
    );
  }

  Map<String, dynamic> toJson() {
    final dateFormatter = new DateFormat('yyyy-MM-dd');
    return {
      'id': this.id,
      'container_no': this.containerNumber,
      'shipping_line': this.shippingLine,
      'exporter': this.exporter,
      'importer': this.importer,
      'size': this.size,
      'produce': this.produce,
      'destination': this.destination,
      'shipment_port': this.shipmentPort,
      'date_shipment': dateOfShipment == null ? null : dateFormatter.format(this.dateOfShipment),
      'date_fumigation': dateOfFumigation == null ? null : dateFormatter.format(this.dateOfFumigation),
      'date_departure': dateOfDeparture == null ? null : dateFormatter.format(this.dateOfDeparture)
    };
  }
}