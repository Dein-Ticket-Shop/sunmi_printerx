import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:sunmi_printerx/alarm_lamp_color.dart';
import 'package:sunmi_printerx/printer.dart';
import 'package:sunmi_printerx/sunmi_printerx.dart';
import 'package:sunmi_printerx/align.dart' as align;
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Printer> printers = [];
  Map<String, bool> cashDrawerOpen = {};
  final _sunmiPrinterXPlugin = SunmiPrinterX();
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();
  PrinterStatusBroadcastSubscription? _broadcastSubscription;
  PrinterStatusAction _lastBroadcastEvent = PrinterStatusAction.normal;

  void _showSnackBar(String message) {
    _messangerKey.currentState?.removeCurrentSnackBar();
    _messangerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void initState() {
    super.initState();
    initDefaultPrinter();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initDefaultPrinter() async {
    try {
      final ps = await _sunmiPrinterXPlugin.getPrinters();
      if (!mounted) return;
      setState(() {
        printers = ps;
        cashDrawerOpen = {for (var e in ps) e.id: false};
      });
    } on PlatformException {
      printers = [];
    }
  }

  void _openPrinterActionsBottomSheet(BuildContext context, Printer printer) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.print_outlined),
                  title: const Text('Print SDK'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await printer.setAlign(align.Align.left);
                    await printer.printText('!"§\$%&/()=? EUR €€€€€€ !',
                        bold: true);
                    await printer.setAlign(align.Align.center);
                    await printer.printText('ÄÖÜäöüß');
                    await printer.setAlign(align.Align.right);
                    await printer.printText('Text Width Ratio 1!',
                        underline: true, textWidthRatio: 1);
                    await printer.setAlign(align.Align.left);
                    await printer.printText('Text Height Ratio 1!',
                        underline: true, textWidthRatio: 1);
                    await printer.printText('Both Height Ratio 1!',
                        textWidthRatio: 1, textHeightRatio: 1);
                    await printer.printText('Spacing 3!', textSpace: 3);
                    await printer.addText('Underlined ', underline: true);
                    await printer.addText('Bold ', bold: true);
                    await printer.addText('Striked\n', strikethrough: true);
                    await printer.setAlign(align.Align.left);
                    // https://pub.dev for 20 times
                    await printer.printQrCode(
                        List.filled(20, 'https://pub.dev').join(),
                        dot: 5);
                    await printer.printTexts(
                      ['col1', 'col2', 'col3'],
                      columnWidths: [3, 6, 3],
                      columnAligns: [
                        align.Align.left,
                        align.Align.center,
                        align.Align.right
                      ],
                    );
                    await printer.autoOut();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.text_increase),
                  title: const Text('Special Font Sizes'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await printer.setAlign(align.Align.left);
                    for (int size = 6; size <= 96; size++) {
                      await printer.printText('Font size $size',
                          textSize: size);
                    }
                    await printer.autoOut();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.qr_code_2),
                  title: const Text('Print ESC/POS'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final profile = await CapabilityProfile.load();
                    final generator = Generator(PaperSize.mm80, profile);
                    List<int> bytes = [];

                    bytes += generator.text(
                        'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
                    bytes += generator.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
                        styles: const PosStyles(codeTable: 'CP1252'));
                    bytes += generator.text('Special 2: blåbærgrød',
                        styles: const PosStyles(codeTable: 'CP1252'));

                    bytes += generator.text('Bold text',
                        styles: const PosStyles(bold: true));
                    bytes += generator.text('Reverse text',
                        styles: const PosStyles(reverse: true));
                    bytes += generator.text('Underlined text',
                        styles: const PosStyles(underline: true),
                        linesAfter: 1);
                    bytes += generator.text('Align left',
                        styles: const PosStyles(align: PosAlign.left));
                    bytes += generator.text('Align center',
                        styles: const PosStyles(align: PosAlign.center));
                    bytes += generator.text('Align right',
                        styles: const PosStyles(align: PosAlign.right),
                        linesAfter: 1);

                    bytes += generator.row([
                      PosColumn(
                        text: 'col3',
                        width: 3,
                        styles: const PosStyles(
                            align: PosAlign.center, underline: true),
                      ),
                      PosColumn(
                        text: 'col6',
                        width: 6,
                        styles: const PosStyles(
                            align: PosAlign.center, underline: true),
                      ),
                      PosColumn(
                        text: 'col3',
                        width: 3,
                        styles: const PosStyles(
                            align: PosAlign.center, underline: true),
                      ),
                    ]);

                    bytes += generator.text('Text size 200%',
                        styles: const PosStyles(
                          height: PosTextSize.size2,
                          width: PosTextSize.size2,
                        ));

                    // Print barcode
                    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
                    bytes += generator.barcode(Barcode.upcA(barData));

                    bytes += generator.feed(2);
                    bytes += generator.cut();

                    await printer
                        .printEscPosCommands(Uint8List.fromList(bytes));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.point_of_sale),
                  title: const Text('Open cash drawer'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    try {
                      await printer.openCashDrawer();
                      setState(() {
                        cashDrawerOpen[printer.id] = true;
                      });
                      _showSnackBar('Cash drawer opened');
                      await printer.waitForCashDrawerClose();
                      setState(() {
                        cashDrawerOpen[printer.id] = false;
                      });
                      _showSnackBar('Cash drawer closed');
                    } catch (e) {
                      _showSnackBar('Error: $e');
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Status'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final status = await printer.getStatus();
                    _showSnackBar('Status: $status');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sunmi PrinterX Example App'),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Printer List & Actions
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Printers',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          ...printers.map((printer) => ListTile(
                                title: Text("\"${printer.name}\""),
                                subtitle: Text(
                                    "Status: ${printer.status.toString()}\nCash drawer: ${cashDrawerOpen[printer.id] == true ? 'open' : 'closed'}"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () =>
                                      _openPrinterActionsBottomSheet(
                                          context, printer),
                                  tooltip: 'Actions',
                                ),
                              )),
                          TextButton(
                              onPressed: initDefaultPrinter,
                              child: const Text('Refresh')),
                        ],
                      ),
                    ),
                  ),
                  // Alarm Lamp Controls
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Alarm Lamp Controls',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final color in AlarmLampColor.values)
                                TextButton(
                                  onPressed: () {
                                    _sunmiPrinterXPlugin
                                        .setAlarmLampColorStatic(color);
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: {
                                      AlarmLampColor.red: Colors.red,
                                      AlarmLampColor.green: Colors.green,
                                      AlarmLampColor.blue: Colors.blue,
                                      AlarmLampColor.white: Colors.white,
                                      AlarmLampColor.yellow: Colors.yellow,
                                      AlarmLampColor.purple: Colors.purple,
                                      AlarmLampColor.cyan: Colors.cyan,
                                    }[color],
                                  ),
                                  child: Text('Alarm Lamp ${color.name}'),
                                ),
                              TextButton(
                                  onPressed: () {
                                    _sunmiPrinterXPlugin.setAlarmLampsOff();
                                  },
                                  child: const Text('Alarm Lamps Off')),
                              TextButton(
                                  onPressed: () {
                                    _sunmiPrinterXPlugin
                                        .setAlarmLampColorBlinking(
                                            AlarmLampColor.yellow, 200, 200);
                                  },
                                  child: const Text('Alarm Lamps Blinking')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Info Card
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Printer Info',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.perm_identity),
                                label: const Text('Show Printer ID'),
                                onPressed: () async {
                                  if (printers.isEmpty) return;
                                  final printer = printers.first;
                                  final id = await printer.getPrinterId();
                                  _showSnackBar('Printer ID: $id');
                                },
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.info_outline),
                                label: const Text('Show Printer Version'),
                                onPressed: () async {
                                  if (printers.isEmpty) return;
                                  final printer = printers.first;
                                  final version =
                                      await printer.getPrinterVersion();
                                  _showSnackBar('Printer Version: $version');
                                },
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.print),
                                label: const Text('Show Printer Type'),
                                onPressed: () async {
                                  if (printers.isEmpty) return;
                                  final printer = printers.first;
                                  final type = await printer.getPrinterType();
                                  _showSnackBar('Printer Type: $type');
                                },
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.content_cut),
                                label: const Text('Show Cutter Number'),
                                onPressed: () async {
                                  if (printers.isEmpty) return;
                                  final printer = printers.first;
                                  final cutter =
                                      await printer.getCutterNumber();
                                  _showSnackBar('Cutter Number: $cutter');
                                },
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.straighten),
                                label: const Text('Show Printed Distance'),
                                onPressed: () async {
                                  if (printers.isEmpty) return;
                                  final printer = printers.first;
                                  final distance =
                                      await printer.getPrintedDistance();
                                  _showSnackBar('Printed Distance: $distance');
                                },
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.whatshot),
                                label: const Text('Show Printer Hot Times'),
                                onPressed: () async {
                                  if (printers.isEmpty) return;
                                  final printer = printers.first;
                                  final hot =
                                      await printer.getPrinterHotTimes();
                                  _showSnackBar('Printer Hot Times: $hot');
                                },
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.opacity),
                                label: const Text('Show Printer Density'),
                                onPressed: () async {
                                  if (printers.isEmpty) return;
                                  final printer = printers.first;
                                  final density =
                                      await printer.getPrinterDensity();
                                  _showSnackBar('Printer Density: $density');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Broadcasts Card
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Broadcasts',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              _broadcastSubscription != null
                                  ? const Chip(
                                      label: Text('Subscribed'),
                                      backgroundColor: Colors.green)
                                  : const Chip(
                                      label: Text('Not Subscribed'),
                                      backgroundColor: Colors.red),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.notifications_active),
                                label: const Text(
                                    'Subscribe to Printer Status Broadcasts'),
                                onPressed: _broadcastSubscription == null
                                    ? () async {
                                        _broadcastSubscription?.cancel();
                                        _broadcastSubscription =
                                            _sunmiPrinterXPlugin
                                                .subscribeToPrinterStatusBroadcasts(
                                                    (action) {
                                          setState(() {
                                            _lastBroadcastEvent = action;
                                          });
                                          _showSnackBar(
                                              _lastBroadcastEvent.toString());
                                        });
                                        setState(() {});
                                      }
                                    : null,
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.notifications_off),
                                label:
                                    const Text('Cancel Broadcast Subscription'),
                                onPressed: _broadcastSubscription != null
                                    ? () async {
                                        await _broadcastSubscription?.cancel();
                                        setState(() {
                                          _lastBroadcastEvent =
                                              PrinterStatusAction.normal;
                                          _broadcastSubscription = null;
                                        });
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
