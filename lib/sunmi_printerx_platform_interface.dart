import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sunmi_printerx/align.dart';

import 'sunmi_printerx_method_channel.dart';

abstract class SunmiPrinterXPlatform extends PlatformInterface {
  SunmiPrinterXPlatform() : super(token: _token);

  static final Object _token = Object();

  static SunmiPrinterXPlatform _instance = MethodChannelSunmiPrinterX();

  static SunmiPrinterXPlatform get instance => _instance;

  static set instance(SunmiPrinterXPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<Map<String, dynamic>>> getPrinters() {
    throw UnimplementedError('getPrinters() has not been implemented.');
  }

  Future<String> getPrinterStatus(String printerId) {
    throw UnimplementedError('getPrinterStatus() has not been implemented.');
  }

  Future<bool> openCashDrawer(String printerId) {
    throw UnimplementedError('openCashDrawer() has not been implemented.');
  }

  Future<bool> isCashDrawerOpen(String printerId) {
    throw UnimplementedError('isCashDrawerOpen() has not been implemented.');
  }

  // ── Cash Drawer Trigger (standalone USB/BLE dongle) ────────────────────────

  Future<String> getCashDrawerTriggerUsb() {
    throw UnimplementedError(
        'getCashDrawerTriggerUsb() has not been implemented.');
  }

  Future<List<String>> scanCashDrawerTriggerBle() {
    throw UnimplementedError(
        'scanCashDrawerTriggerBle() has not been implemented.');
  }

  Future<String> connectCashDrawerTriggerBle(String name) {
    throw UnimplementedError(
        'connectCashDrawerTriggerBle() has not been implemented.');
  }

  Future<bool> openCashDrawerTrigger(String triggerId,
      {required int openTimeMs, required int closeTimeMs}) {
    throw UnimplementedError(
        'openCashDrawerTrigger() has not been implemented.');
  }

  Future<bool> isCashDrawerTriggerOpen(String triggerId) {
    throw UnimplementedError(
        'isCashDrawerTriggerOpen() has not been implemented.');
  }

  Future<String> getCashDrawerTriggerSerialNo(String triggerId) {
    throw UnimplementedError(
        'getCashDrawerTriggerSerialNo() has not been implemented.');
  }

  Future<void> printEscPosCommands(String printerId, Uint8List commands) {
    throw UnimplementedError('printEscPosCommands() has not been implemented.');
  }

  Future<void> setAlign(String printerId, Align align) {
    throw UnimplementedError('setAlign() has not been implemented.');
  }

  Future<void> autoOut(String printerId) {
    throw UnimplementedError('autoOut() has not been implemented.');
  }

  Future<void> printText(String printerId, String text,
      {required int textWidthRatio,
      required int textHeightRatio,
      required int textSize,
      required int textSpace,
      required bool bold,
      required bool underline,
      required bool strikethrough,
      required bool italic,
      required Align align}) {
    throw UnimplementedError('printText() has not been implemented.');
  }

  Future<void> printQrCode(String printerId, String data,
      {required int dot, required Align align}) {
    throw UnimplementedError('printQrCode() has not been implemented.');
  }

  Future<void> printTexts(String printerId, List<String> texts,
      {required List<int> columnWidths, required List<Align> columnAligns}) {
    throw UnimplementedError('printTexts() has not been implemented.');
  }

  Future<void> addText(String printerId, String text,
      {required int textWidthRatio,
      required int textHeightRatio,
      required int textSize,
      required int textSpace,
      required bool bold,
      required bool underline,
      required bool strikethrough,
      required bool italic,
      required Align align}) {
    throw UnimplementedError('addText() has not been implemented.');
  }

  Future<String> getInfo(String printerId, String infoType) {
    throw UnimplementedError('getInfo() has not been implemented.');
  }

  // ── Unified status light (K2 Kiosk + Flex 3) ──────────────────────────────

  Future<void> setStatusLightColor(String color) {
    throw UnimplementedError('setStatusLightColor() has not been implemented.');
  }

  Future<void> setStatusLightOff() {
    throw UnimplementedError('setStatusLightOff() has not been implemented.');
  }

  Future<void> setStatusLightFlashing(String color, int onMs, int offMs) {
    throw UnimplementedError(
        'setStatusLightFlashing() has not been implemented.');
  }

  Future<void> setStatusLightMultiFlashing(
      List<String> colors, List<int> onMs, List<int> offMs) {
    throw UnimplementedError(
        'setStatusLightMultiFlashing() has not been implemented.');
  }
}
