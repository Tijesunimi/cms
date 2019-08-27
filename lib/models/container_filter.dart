class ShippingContainerFilter {
  final String containerNumber;
  final String shippingLine;
  final String exporter;
  final String importer;
  final String size;
  final String produce;
  final String shipmentPort;
  final String destination;
  final String shipmentStartDate;
  final String shipmentEndDate;
  final String fumigationStartDate;
  final String fumigationEndDate;
  final String departureStartDate;
  final String departureEndDate;

  ShippingContainerFilter({this.containerNumber,
    this.shippingLine,
    this.exporter,
    this.importer,
    this.size,
    this.produce,
    this.shipmentPort,
    this.destination,
    this.shipmentStartDate,
    this.shipmentEndDate,
    this.fumigationStartDate,
    this.fumigationEndDate,
    this.departureStartDate,
    this.departureEndDate
  });
}