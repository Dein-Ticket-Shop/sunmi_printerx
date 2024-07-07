import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sunmi_printerx_method_channel.dart';

abstract class SunmiPrinterXPlatform extends PlatformInterface {
  /// Constructs a SunmiPrinterXPlatform.
  SunmiPrinterXPlatform() : super(token: _token);

  static final Object _token = Object();

  static SunmiPrinterXPlatform _instance = MethodChannelSunmiPrinterX();

  /// The default instance of [SunmiPrinterXPlatform] to use.
  ///
  /// Defaults to [MethodChannelSunmiPrinterX].
  static SunmiPrinterXPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SunmiPrinterXPlatform] when
  /// they register themselves.
  static set instance(SunmiPrinterXPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
