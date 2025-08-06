import 'dart:typed_data';
import 'package:sunmi_printerx/alarm_lamp_color.dart';
import 'package:sunmi_printerx/align.dart';
import 'package:sunmi_printerx/printer.dart';
import 'package:sunmi_printerx/printerstatus.dart';

import 'sunmi_printerx_platform_interface.dart';

enum SunmiPrinterType {
  generalThermal,
  blackMarkThermal,
  thermalLabel,
  stylus,
  laser,
  unknown,
}

SunmiPrinterType sunmiPrinterTypeFromString(String? type) {
  switch (type) {
    case '0':
      return SunmiPrinterType.generalThermal;
    case '1':
      return SunmiPrinterType.blackMarkThermal;
    case '2':
      return SunmiPrinterType.thermalLabel;
    case '3':
      return SunmiPrinterType.stylus;
    case '4':
      return SunmiPrinterType.laser;
    default:
      return SunmiPrinterType.unknown;
  }
}

class SunmiPrinterX {
  Future<List<Printer>> getPrinters() async {
    return (await SunmiPrinterXPlatform.instance.getPrinters())
        .map((printerData) {
      var id = printerData['id'];
      final printer = Printer(
        name: printerData['name'],
        status: printerStatusFromString(printerData['status']),
        hot: printerData['hot'],
        version: printerData['version'],
        id: id,
        cutter: printerData['cutter'],
        density: printerData['density'],
        distance: printerData['distance'],
        gray: printerData['gray'],
        paper: printerData['paper'],
        type: printerData['type'],
        getStatus: () => _getPrinterStatus(id),
        openCashDrawer: () => _openCashDrawer(id),
        isCashDrawerOpen: () => _isCashDrawerOpen(id),
        printEscPosCommands: (commands) => _printEscPosCommands(id, commands),
        waitForCashDrawerClose: () => _waitForCashDrawerClose(id),
        setAlign: (align) => _setAlign(id, align),
        printText: (text,
                {textWidthRatio = 0,
                textHeightRatio = 0,
                textSpace = 0,
                bold = false,
                underline = false,
                strikethrough = false,
                italic = false,
                align = Align.left}) =>
            printText(id, text,
                textWidthRatio: textWidthRatio,
                textHeightRatio: textHeightRatio,
                textSpace: textSpace,
                bold: bold,
                underline: underline,
                strikethrough: strikethrough,
                italic: italic,
                align: align),
        autoOut: () => autoOut(id),
        printQrCode: (data, {dot = 3, align = Align.center}) =>
            printQrCode(id, data, dot: dot, align: align),
        printTexts: (texts,
                {columnWidths = const [], columnAligns = const []}) =>
            printTexts(id, texts,
                columnWidths: columnWidths, columnAligns: columnAligns),
        addText: (text,
                {textWidthRatio = 0,
                textHeightRatio = 0,
                textSpace = 0,
                bold = false,
                underline = false,
                strikethrough = false,
                italic = false,
                align = Align.left}) =>
            addText(id, text,
                textWidthRatio: textWidthRatio,
                textHeightRatio: textHeightRatio,
                textSpace: textSpace,
                bold: bold,
                underline: underline,
                strikethrough: strikethrough,
                italic: italic,
                align: align),
      );
      return printer;
    }).toList();
  }

  Future<PrinterStatus> _getPrinterStatus(String printerId) async {
    final result =
        await SunmiPrinterXPlatform.instance.getPrinterStatus(printerId);
    return printerStatusFromString(result);
  }

  Future<bool> _openCashDrawer(String printerId) {
    return SunmiPrinterXPlatform.instance.openCashDrawer(printerId);
  }

  Future<bool> _isCashDrawerOpen(String printerId) {
    return SunmiPrinterXPlatform.instance.isCashDrawerOpen(printerId);
  }

  Future<void> _printEscPosCommands(String printerId, Uint8List commands) {
    return SunmiPrinterXPlatform.instance
        .printEscPosCommands(printerId, commands);
  }

  Future<void> _waitForCashDrawerClose(String printerId,
      {Duration pollInterval = const Duration(milliseconds: 300)}) {
    return Future<void>.delayed(pollInterval, () {
      return _isCashDrawerOpen(printerId).then((isOpen) {
        if (isOpen) {
          return _waitForCashDrawerClose(printerId, pollInterval: pollInterval);
        }
      });
    });
  }

  Future<void> _setAlign(String printerId, Align align) {
    return SunmiPrinterXPlatform.instance.setAlign(printerId, align);
  }

  Future<void> printText(String printerId, String text,
      {int textWidthRatio = 0,
      int textHeightRatio = 0,
      int textSpace = 0,
      bool bold = false,
      bool underline = false,
      bool strikethrough = false,
      bool italic = false,
      Align align = Align.left}) {
    return SunmiPrinterXPlatform.instance.printText(
      printerId,
      text,
      textWidthRatio: textWidthRatio,
      textHeightRatio: textHeightRatio,
      textSpace: textSpace,
      bold: bold,
      underline: underline,
      strikethrough: strikethrough,
      italic: italic,
      align: align,
    );
  }

  Future<void> autoOut(String printerId) {
    return SunmiPrinterXPlatform.instance.autoOut(printerId);
  }

  Future<void> printQrCode(String printerId, String data,
      {int dot = 3, Align align = Align.center}) {
    return SunmiPrinterXPlatform.instance
        .printQrCode(printerId, data, dot: dot, align: align);
  }

  Future<void> printTexts(String printerId, List<String> texts,
      {List<int> columnWidths = const [],
      List<Align> columnAligns = const []}) {
    return SunmiPrinterXPlatform.instance.printTexts(printerId, texts,
        columnWidths: columnWidths, columnAligns: columnAligns);
  }

  Future<void> addText(String printerId, String text,
      {int textWidthRatio = 0,
      int textHeightRatio = 0,
      int textSpace = 0,
      bool bold = false,
      bool underline = false,
      bool strikethrough = false,
      bool italic = false,
      Align align = Align.left}) {
    return SunmiPrinterXPlatform.instance.addText(printerId, text,
        textWidthRatio: textWidthRatio,
        textHeightRatio: textHeightRatio,
        textSpace: textSpace,
        bold: bold,
        underline: underline,
        strikethrough: strikethrough,
        italic: italic,
        align: align);
  }

  Future<void> _setAlarmLampStatic(String lamp, bool on) async {
    await SunmiPrinterXPlatform.instance.controlLamp(on ? 0 : 1, lamp);
  }

  Future<void> setAlarmLampColorStatic(AlarmLampColor color) async {
    await setAlarmLampsOff();
    for (String lamp in alarmLampColorToLEDs(color)) {
      await _setAlarmLampStatic(lamp, true);
    }
  }

  Future<void> _setAlarmLampsBlinking(
      int status, int onTime, int offTime, List<String> lamps) {
    return SunmiPrinterXPlatform.instance
        .controlLampForLoops(status, onTime, offTime, lamps);
  }

  Future<void> setAlarmLampColorBlinking(
      AlarmLampColor color, int onTime, int offTime) async {
    await setAlarmLampsOff();
    await _setAlarmLampsBlinking(
        0, onTime, offTime, alarmLampColorToLEDs(color));
  }

  Future<void> setAlarmLampsOff() async {
    await SunmiPrinterXPlatform.instance.lampsOff();
  }

  Future<String> getPrinterId(String printerId) =>
      SunmiPrinterXPlatform.instance.getInfo(printerId, 'ID');
  Future<String> getPrinterVersion(String printerId) =>
      SunmiPrinterXPlatform.instance.getInfo(printerId, 'VERSION');
  Future<SunmiPrinterType> getPrinterType(String printerId) async {
    final typeStr =
        await SunmiPrinterXPlatform.instance.getInfo(printerId, 'TYPE');
    return sunmiPrinterTypeFromString(typeStr);
  }

  Future<int> getCutterNumber(String printerId) async {
    final value =
        await SunmiPrinterXPlatform.instance.getInfo(printerId, 'CUTTER');
    return int.tryParse(value) ?? 0;
  }

  Future<int> getPrintedDistance(String printerId) async {
    final value =
        await SunmiPrinterXPlatform.instance.getInfo(printerId, 'DISTANCE');
    return int.tryParse(value) ?? 0;
  }

  Future<int> getPrinterHotTimes(String printerId) async {
    final value =
        await SunmiPrinterXPlatform.instance.getInfo(printerId, 'HOT');
    return int.tryParse(value) ?? 0;
  }

  Future<int> getPrinterDensity(String printerId) async {
    final value =
        await SunmiPrinterXPlatform.instance.getInfo(printerId, 'DENSITY');
    return int.tryParse(value) ?? 0;
  }
}
