import 'package:flutter_test/flutter_test.dart';
import 'package:sunmi_printerx/sunmi_printerx.dart';
import 'package:sunmi_printerx/sunmi_printerx_platform_interface.dart';
import 'package:sunmi_printerx/sunmi_printerx_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSunmiPrinterXPlatform
    with MockPlatformInterfaceMixin
    implements SunmiPrinterXPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SunmiPrinterXPlatform initialPlatform = SunmiPrinterXPlatform.instance;

  test('$MethodChannelSunmiPrinterX is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSunmiPrinterX>());
  });

  test('getPlatformVersion', () async {
    SunmiPrinterX sunmiPrinterXPlugin = SunmiPrinterX();
    MockSunmiPrinterXPlatform fakePlatform = MockSunmiPrinterXPlatform();
    SunmiPrinterXPlatform.instance = fakePlatform;

    expect(await sunmiPrinterXPlugin.getPlatformVersion(), '42');
  });
}
