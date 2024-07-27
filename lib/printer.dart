import 'dart:typed_data';

import 'package:sunmi_printerx/printerstatus.dart';

class Printer {
  final String name;
  final PrinterStatus status;
  final String hot;
  final String version;
  final String id;
  final String cutter;
  final String density;
  final String distance;
  final String gray;
  final String paper;
  final String type;

  final Future<PrinterStatus> Function() getStatus;
  final Future<void> Function() openCashDrawer;
  final Future<bool> Function() isCashDrawerOpen;
  final Future<void> Function(Uint8List commands) printEscPosCommands;
  final Future<void> Function() waitForCashDrawerClose;

  Printer({
    required this.name,
    required this.status,
    required this.hot,
    required this.version,
    required this.id,
    required this.cutter,
    required this.density,
    required this.distance,
    required this.gray,
    required this.paper,
    required this.type,
    required this.getStatus,
    required this.openCashDrawer,
    required this.isCashDrawerOpen,
    required this.printEscPosCommands,
    required this.waitForCashDrawerClose,
  });
}
