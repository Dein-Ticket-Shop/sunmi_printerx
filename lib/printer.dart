import 'dart:typed_data';

import 'package:sunmi_printerx/printerstatus.dart';

import 'align.dart';

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
  final Future<void> Function(Align align) setAlign;
  final Future<void> Function(String text,
      {int textWidthRatio,
      int textHeightRatio,
      int textSpace,
      bool bold,
      bool underline,
      bool strikethrough,
      bool italic,
      Align align}) printText;
  final Future<void> Function() autoOut;
  final Future<void> Function(String data, {int dot, Align align}) printQrCode;
  final Future<void> Function(List<String> texts,
      {List<int> columnWidths, List<Align> columnAligns}) printTexts;
  final Future<void> Function(String text,
      {int textWidthRatio,
      int textHeightRatio,
      int textSpace,
      bool bold,
      bool underline,
      bool strikethrough,
      bool italic,
      Align align}) addText;

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
    required this.setAlign,
    required this.printText,
    required this.autoOut,
    required this.printQrCode,
    required this.printTexts,
    required this.addText,
  });
}
