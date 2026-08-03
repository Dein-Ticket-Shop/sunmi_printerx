/// A standalone Sunmi Cash Drawer Trigger (USB or Bluetooth dongle) that
/// opens a cash drawer (RJ12) directly, independent of any printer.
class CashDrawerTrigger {
  final String id;

  final Future<bool> Function({int openTimeMs, int closeTimeMs}) open;
  final Future<bool> Function() isOpen;
  final Future<String> Function() getSerialNo;

  CashDrawerTrigger({
    required this.id,
    required this.open,
    required this.isOpen,
    required this.getSerialNo,
  });
}
