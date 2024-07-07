import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sunmi_printerx_platform_interface.dart';

/// An implementation of [SunmiPrinterXPlatform] that uses method channels.
class MethodChannelSunmiPrinterX extends SunmiPrinterXPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sunmi_printerx');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
