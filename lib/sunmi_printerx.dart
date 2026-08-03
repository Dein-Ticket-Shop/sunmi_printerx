import 'dart:typed_data';
import 'dart:async';
import 'package:sunmi_printerx/alarm_lamp_color.dart';
import 'package:sunmi_printerx/align.dart';
import 'package:sunmi_printerx/cash_drawer_trigger.dart';
import 'package:sunmi_printerx/printer.dart';
import 'package:sunmi_printerx/printerstatus.dart';
import 'package:flutter_broadcasts/flutter_broadcasts.dart';

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
    case 'thermal printer':
      return SunmiPrinterType.generalThermal;
    case 'black mark thermal printer':
      return SunmiPrinterType.blackMarkThermal;
    case 'thermal label printer':
      return SunmiPrinterType.thermalLabel;
    case 'stylus printer':
      return SunmiPrinterType.stylus;
    case 'laser printer':
      return SunmiPrinterType.laser;
    default:
      return SunmiPrinterType.unknown;
  }
}

/// Enum for all printer status broadcast actions.
enum PrinterStatusAction {
  normal,
  outOfPaper,
  paperError,
  overHeating,
  motorHeating,
  coverOpen,
  coverError,
  knifeError1,
  knifeError2,
  blackLabelNonExistent,
  labelNonExistent,
  error,
  pickPaper,
  lessOfPaper,
  printerNonExistent,
}

/// Maps enum to broadcast action string.
const Map<PrinterStatusAction, String> printerStatusActionToString = {
  PrinterStatusAction.normal: 'woyou.aidlservice.jiuv5.NORMAL_ACTION',
  PrinterStatusAction.outOfPaper: 'woyou.aidlservice.jiuv5.OUT_OF_PAPER_ACTION',
  PrinterStatusAction.paperError: 'woyou.aidlservice.jiuv5.PAPER_ERROR_ACTION',
  PrinterStatusAction.overHeating:
      'woyou.aidlservice.jiuv5.OVER_HEATING_ACTION',
  PrinterStatusAction.motorHeating:
      'woyou.aidlservice.jiuv5.MOTOR_HEATING_ACTION',
  PrinterStatusAction.coverOpen: 'woyou.aidlservice.jiuv5.COVER_OPEN_ACTION',
  PrinterStatusAction.coverError: 'woyou.aidlservice.jiuv5.COVER_ERROR_ACTION',
  PrinterStatusAction.knifeError1:
      'woyou.aidlservice.jiuv5.KNIFE_ERROR_ACTION_1',
  PrinterStatusAction.knifeError2:
      'woyou.aidlservice.jiuv5.KNIFE_ERROR_ACTION_2',
  PrinterStatusAction.blackLabelNonExistent:
      'woyou.aidlservice.jiuv5.BLACKLABEL_NON_EXISTENT_ACTION',
  PrinterStatusAction.labelNonExistent:
      'woyou.aidlservice.jiuv5.LABEL_NON_EXISTENT_ACTION',
  PrinterStatusAction.error: 'woyou.aidlservice.jiuv5.ERROR_ACTION',
  PrinterStatusAction.pickPaper: 'woyou.aidlservice.jiuv5.PICK_PAPER_ACTION',
  PrinterStatusAction.lessOfPaper:
      'woyou.aidlservice.jiuv5.LESS_OF_PAPER_ACTION',
  PrinterStatusAction.printerNonExistent:
      'woyou.aidlservice.jiuv5.PRINTER_NON_EXISTENT_ACTION',
};

/// Maps broadcast action string to enum.
final Map<String, PrinterStatusAction> printerStatusActionFromString =
    printerStatusActionToString.map((k, v) => MapEntry(v, k));

/// Represents a subscription to printer status broadcasts.
/// Call [cancel] to stop listening and [receiver.stop()] for full cleanup.
class PrinterStatusBroadcastSubscription {
  final StreamSubscription subscription;
  final BroadcastReceiver receiver;
  PrinterStatusBroadcastSubscription(this.subscription, this.receiver);
  Future<void> cancel() async {
    await subscription.cancel();
    receiver.stop();
  }
}

class SunmiPrinterX {
  /// List of broadcast actions for printer status events (as enum)
  static const List<PrinterStatusAction> printerStatusActions =
      PrinterStatusAction.values;

  /// List of broadcast action strings for receiver
  static List<String> get _printerStatusActions =>
      printerStatusActions.map((e) => printerStatusActionToString[e]!).toList();

  PrinterStatusAction getPrinterStatusAction(String action) {
    return printerStatusActionFromString[action] ?? PrinterStatusAction.error;
  }

  /// Starts listening to printer status broadcasts.
  ///
  /// [onEvent] is called with the broadcast action and its data whenever a printer status event occurs.
  /// Returns a [PrinterStatusBroadcastSubscription] so you can cancel and clean up when needed.
  ///
  /// Example:
  /// ```dart
  /// final sub = sunmiPrinterX.subscribeToPrinterStatusBroadcasts((action, data) {
  ///   print('Printer status event: action=$action, data=$data');
  /// });
  /// // To cancel and clean up:
  /// await sub.cancel();
  /// ```
  PrinterStatusBroadcastSubscription subscribeToPrinterStatusBroadcasts(
    void Function(PrinterStatusAction action) onEvent,
  ) {
    final receiver = BroadcastReceiver(names: _printerStatusActions);
    PrinterStatusAction? lastAction;
    final subscription = receiver.messages.listen((event) {
      final newAction = getPrinterStatusAction(event.name);
      if (lastAction != newAction) {
        lastAction = newAction;
        onEvent(newAction);
      }
    });
    receiver.start();
    return PrinterStatusBroadcastSubscription(subscription, receiver);
  }

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
                textSize = 24,
                textSpace = 0,
                bold = false,
                underline = false,
                strikethrough = false,
                italic = false,
                align = Align.left}) =>
            printText(id, text,
                textWidthRatio: textWidthRatio,
                textHeightRatio: textHeightRatio,
                textSize: textSize,
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
                textSize = 24,
                textSpace = 0,
                bold = false,
                underline = false,
                strikethrough = false,
                italic = false,
                align = Align.left}) =>
            addText(id, text,
                textWidthRatio: textWidthRatio,
                textHeightRatio: textHeightRatio,
                textSize: textSize,
                textSpace: textSpace,
                bold: bold,
                underline: underline,
                strikethrough: strikethrough,
                italic: italic,
                align: align),
        getPrinterId: () => getPrinterId(id),
        getPrinterVersion: () => getPrinterVersion(id),
        getPrinterType: () => getPrinterType(id),
        getCutterNumber: () => getCutterNumber(id),
        getPrintedDistance: () => getPrintedDistance(id),
        getPrinterHotTimes: () => getPrinterHotTimes(id),
        getPrinterDensity: () => getPrinterDensity(id),
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
      int textSize = 24,
      int textSpace = 0,
      bool bold = false,
      bool underline = false,
      bool strikethrough = false,
      bool italic = false,
      Align align = Align.left}) {
    // Clamp textSize to supported range [6, 96]
    final int clampedTextSize = textSize.clamp(6, 96);
    return SunmiPrinterXPlatform.instance.printText(
      printerId,
      text,
      textWidthRatio: textWidthRatio,
      textHeightRatio: textHeightRatio,
      textSize: clampedTextSize,
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
      int textSize = 24,
      int textSpace = 0,
      bool bold = false,
      bool underline = false,
      bool strikethrough = false,
      bool italic = false,
      Align align = Align.left}) {
    // Clamp textSize to supported range [6, 96]
    final int clampedTextSize = textSize.clamp(6, 96);
    return SunmiPrinterXPlatform.instance.addText(printerId, text,
        textWidthRatio: textWidthRatio,
        textHeightRatio: textHeightRatio,
        textSize: clampedTextSize,
        textSpace: textSpace,
        bold: bold,
        underline: underline,
        strikethrough: strikethrough,
        italic: italic,
        align: align);
  }

  Future<void> setStatusLightColor(AlarmLampColor color) {
    return SunmiPrinterXPlatform.instance.setStatusLightColor(color.name);
  }

  Future<void> setStatusLightOff() {
    return SunmiPrinterXPlatform.instance.setStatusLightOff();
  }

  Future<void> setStatusLightFlashing(
      AlarmLampColor color, int onMs, int offMs) {
    return SunmiPrinterXPlatform.instance
        .setStatusLightFlashing(color.name, onMs, offMs);
  }

  Future<void> setStatusLightMultiFlashing(
      List<AlarmLampColor> colors, List<int> onMs, List<int> offMs) {
    return SunmiPrinterXPlatform.instance.setStatusLightMultiFlashing(
        colors.map((c) => c.name).toList(), onMs, offMs);
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

  // ── Cash Drawer Trigger (standalone USB/BLE dongle) ────────────────────────
  //
  // A "Cash Drawer Trigger" is a small USB/Bluetooth dongle that opens a cash
  // drawer (RJ12) directly, without going through a printer's own cash
  // drawer port. See: https://docs.sunmi.com/en-US/cdixeghjk491/xmxqeghjk513

  /// Gets the USB cash drawer trigger. There is always exactly one, since the
  /// SDK doesn't differentiate between multiple USB devices connected.
  ///
  /// The USB permission dialog may be shown by the OS the first time.
  Future<CashDrawerTrigger> getCashDrawerTriggerUsb() async {
    final id = await SunmiPrinterXPlatform.instance.getCashDrawerTriggerUsb();
    return _buildCashDrawerTrigger(id);
  }

  /// Scans for nearby Bluetooth cash drawer triggers (named "CashDrawer_xxxxxx")
  /// and returns their names, to let the user pick one to pair with.
  ///
  /// Requires the `bluetoothScan`, `bluetoothConnect` and `locationWhenInUse`
  /// runtime permissions to be granted beforehand.
  Future<List<String>> scanCashDrawerTriggerBle() {
    return SunmiPrinterXPlatform.instance.scanCashDrawerTriggerBle();
  }

  /// Connects directly to the Bluetooth cash drawer trigger with the given
  /// [name] (as returned by [scanCashDrawerTriggerBle]).
  ///
  /// The first time a cash drawer function is used, Android may show a
  /// pairing dialog; the default PIN is the last 6 digits of the device name.
  Future<CashDrawerTrigger> connectCashDrawerTriggerBle(String name) async {
    final id =
        await SunmiPrinterXPlatform.instance.connectCashDrawerTriggerBle(name);
    return _buildCashDrawerTrigger(id);
  }

  CashDrawerTrigger _buildCashDrawerTrigger(String id) {
    return CashDrawerTrigger(
      id: id,
      open: ({int openTimeMs = 200, int closeTimeMs = 200}) =>
          SunmiPrinterXPlatform.instance.openCashDrawerTrigger(id,
              openTimeMs: openTimeMs, closeTimeMs: closeTimeMs),
      isOpen: () => SunmiPrinterXPlatform.instance.isCashDrawerTriggerOpen(id),
      getSerialNo: () =>
          SunmiPrinterXPlatform.instance.getCashDrawerTriggerSerialNo(id),
    );
  }
}
