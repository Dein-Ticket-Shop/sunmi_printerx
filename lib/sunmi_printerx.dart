import 'sunmi_printerx_platform_interface.dart';

class SunmiPrinterX {
  Future<String?> getPlatformVersion() {
    return SunmiPrinterXPlatform.instance.getPlatformVersion();
  }
}
