import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
}
