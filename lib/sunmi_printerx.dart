import 'dart:typed_data';

import 'package:sunmi_printerx/printer.dart';
import 'package:sunmi_printerx/printerstatus.dart';

import 'sunmi_printerx_platform_interface.dart';

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
}
