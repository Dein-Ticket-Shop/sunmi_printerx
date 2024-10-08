import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sunmi_printerx/align.dart';

import 'sunmi_printerx_platform_interface.dart';

/// An implementation of [SunmiPrinterXPlatform] that uses method channels.
class MethodChannelSunmiPrinterX extends SunmiPrinterXPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sunmi_printerx');

  @override
  Future<List<Map<String, dynamic>>> getPrinters() async {
    final result = await methodChannel.invokeListMethod('getPrinters');
    if (result == null) {
      throw PlatformException(
        code: 'UNKNOWN',
        message: 'Unable to find printer.',
      );
    }
    return List<Map<String, dynamic>>.from(
        result.map((e) => Map<String, dynamic>.from(e)));
  }

  @override
  Future<bool> openCashDrawer(String printerId) async {
    final result = await methodChannel.invokeMethod<bool>(
        'openCashDrawer', <String, dynamic>{'printerId': printerId});
    if (result == null) {
      throw PlatformException(
        code: 'UNKNOWN',
        message: 'Unable to open cash drawer.',
      );
    }
    return result;
  }

  @override
  Future<String> getPrinterStatus(String printerId) async {
    final result = await methodChannel.invokeMethod<String>(
      'getPrinterStatus',
      <String, dynamic>{'printerId': printerId},
    );
    if (result == null) {
      throw PlatformException(
        code: 'UNKNOWN',
        message: 'Unable to get printer status.',
      );
    }
    return result;
  }

  @override
  Future<bool> isCashDrawerOpen(String printerId) async {
    final result = await methodChannel.invokeMethod<bool>(
        'isCashDrawerOpen', <String, dynamic>{'printerId': printerId});
    if (result == null) {
      throw PlatformException(
        code: 'UNKNOWN',
        message: 'Unable to determine if cash drawer is open.',
      );
    }
    return result;
  }

  @override
  Future<void> printEscPosCommands(String printerId, Uint8List commands) async {
    await methodChannel
        .invokeMethod<void>('printEscPosCommands', <String, dynamic>{
      'printerId': printerId,
      'commands': commands,
    });
  }

  @override
  Future<void> setAlign(String printerId, Align align) async {
    await methodChannel.invokeMethod<void>('setAlign', <String, dynamic>{
      'printerId': printerId,
      'align': alignToString(align),
    });
  }

  @override
  Future<void> autoOut(String printerId) async {
    await methodChannel.invokeMethod<void>('autoOut', <String, dynamic>{
      'printerId': printerId,
    });
  }

  @override
  Future<void> printText(String printerId, String text,
      {required int textWidthRatio,
      required int textHeightRatio,
      required int textSpace,
      required bool bold,
      required bool underline,
      required bool strikethrough,
      required bool italic,
      required Align align}) async {
    await methodChannel.invokeMethod<void>('printText', <String, dynamic>{
      'printerId': printerId,
      'text': text,
      'textWidthRatio': textWidthRatio,
      'textHeightRatio': textHeightRatio,
      'textSpace': textSpace,
      'bold': bold,
      'underline': underline,
      'strikethrough': strikethrough,
      'italics': italic,
      'align': alignToString(align),
    });
  }

  @override
  Future<void> printQrCode(String printerId, String data,
      {required int dot, required Align align}) async {
    await methodChannel.invokeMethod<void>('printQrCode', <String, dynamic>{
      'printerId': printerId,
      'data': data,
      'dot': dot,
      'align': alignToString(align),
    });
  }

  @override
  Future<void> printTexts(String printerId, List<String> texts,
      {required List<int> columnWidths,
      required List<Align> columnAligns}) async {
    await methodChannel.invokeMethod<void>('printTexts', <String, dynamic>{
      'printerId': printerId,
      'texts': texts,
      'colsWidthArrs': columnWidths,
      'aligns': columnAligns.map(alignToString).toList(),
    });
  }

  @override
  Future<void> addText(String printerId, String text,
      {required int textWidthRatio,
      required int textHeightRatio,
      required int textSpace,
      required bool bold,
      required bool underline,
      required bool strikethrough,
      required bool italic,
      required Align align}) async {
    await methodChannel.invokeMethod<void>('addText', <String, dynamic>{
      'printerId': printerId,
      'text': text,
      'textWidthRatio': textWidthRatio,
      'textHeightRatio': textHeightRatio,
      'textSpace': textSpace,
      'bold': bold,
      'underline': underline,
      'strikethrough': strikethrough,
      'italics': italic,
      'align': alignToString(align),
    });
  }
}
