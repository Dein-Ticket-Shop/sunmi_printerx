import 'package:flutter/material.dart';
import 'dart:async';

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
  String _lastBroadcastEvent = '';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messangerKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
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
                                title: Text(
                                    "Printer: ${printer.name} (Cash drawer: ${cashDrawerOpen[printer.id] == true ? 'open' : 'closed'})"),
                                subtitle: Text(printer.status.toString()),
                                trailing: Wrap(
                                  spacing: 8,
                                  children: [
                                    TextButton(
                                        onPressed: () async {
                                          await printer
                                              .setAlign(align.Align.left);
                                          await printer.printText(
                                              '!"§\$%&/()=? EUR €€€€€€ !',
                                              bold: true);
                                          await printer
                                              .setAlign(align.Align.center);
                                          await printer.printText('ÄÖÜäöüß');
                                          await printer
                                              .setAlign(align.Align.right);
                                          await printer.printText(
                                              'Text Width Ratio 1!',
                                              underline: true,
                                              textWidthRatio: 1);
                                          await printer
                                              .setAlign(align.Align.left);
                                          await printer.printText(
                                              'Text Height Ratio 1!',
                                              underline: true,
                                              textWidthRatio: 1);
                                          await printer.printText(
                                              'Both Height Ratio 1!',
                                              textWidthRatio: 1,
                                              textHeightRatio: 1);
                                          await printer.printText('Spacing 3!',
                                              textSpace: 3);
                                          await printer.addText('Underlined ',
                                              underline: true);
                                          await printer.addText('Bold ',
                                              bold: true);
                                          await printer.addText('Striked\n',
                                              strikethrough: true);
                                          await printer
                                              .setAlign(align.Align.left);
                                          // https://pub.dev for 20 times
                                          await printer.printQrCode(
                                              List.filled(20, 'https://pub.dev')
                                                  .join(),
                                              dot: 5);

                                          await printer.printTexts([
                                            'col1',
                                            'col2',
                                            'col3',
                                          ], columnWidths: [
                                            3,
                                            6,
                                            3
                                          ], columnAligns: [
                                            align.Align.left,
                                            align.Align.center,
                                            align.Align.right
                                          ]);

                                          await printer.autoOut();
                                        },
                                        child: const Text('Print SDK')),
                                    TextButton(
                                        onPressed: () async {
                                          final profile =
                                              await CapabilityProfile.load();
                                          final generator = Generator(
                                              PaperSize.mm80, profile);
                                          List<int> bytes = [];

                                          bytes += generator.text(
                                              'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
                                          bytes += generator.text(
                                              'Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
                                              styles: const PosStyles(
                                                  codeTable: 'CP1252'));
                                          bytes += generator.text(
                                              'Special 2: blåbærgrød',
                                              styles: const PosStyles(
                                                  codeTable: 'CP1252'));

                                          bytes += generator.text('Bold text',
                                              styles:
                                                  const PosStyles(bold: true));
                                          bytes += generator.text(
                                              'Reverse text',
                                              styles: const PosStyles(
                                                  reverse: true));
                                          bytes += generator.text(
                                              'Underlined text',
                                              styles: const PosStyles(
                                                  underline: true),
                                              linesAfter: 1);
                                          bytes += generator.text('Align left',
                                              styles: const PosStyles(
                                                  align: PosAlign.left));
                                          bytes += generator.text(
                                              'Align center',
                                              styles: const PosStyles(
                                                  align: PosAlign.center));
                                          bytes += generator.text('Align right',
                                              styles: const PosStyles(
                                                  align: PosAlign.right),
                                              linesAfter: 1);

                                          bytes += generator.row([
                                            PosColumn(
                                              text: 'col3',
                                              width: 3,
                                              styles: const PosStyles(
                                                  align: PosAlign.center,
                                                  underline: true),
                                            ),
                                            PosColumn(
                                              text: 'col6',
                                              width: 6,
                                              styles: const PosStyles(
                                                  align: PosAlign.center,
                                                  underline: true),
                                            ),
                                            PosColumn(
                                              text: 'col3',
                                              width: 3,
                                              styles: const PosStyles(
                                                  align: PosAlign.center,
                                                  underline: true),
                                            ),
                                          ]);

                                          bytes +=
                                              generator.text('Text size 200%',
                                                  styles: const PosStyles(
                                                    height: PosTextSize.size2,
                                                    width: PosTextSize.size2,
                                                  ));

                                          // Print barcode
                                          final List<int> barData = [
                                            1,
                                            2,
                                            3,
                                            4,
                                            5,
                                            6,
                                            7,
                                            8,
                                            9,
                                            0,
                                            4
                                          ];
                                          bytes += generator
                                              .barcode(Barcode.upcA(barData));

                                          bytes += generator.feed(2);
                                          bytes += generator.cut();

                                          await printer.printEscPosCommands(
                                              Uint8List.fromList(bytes));
                                        },
                                        child: const Text('Print ESC/POS')),
                                    TextButton(
                                        onPressed: () async {
                                          await printer.openCashDrawer();
                                          setState(() {
                                            cashDrawerOpen[printer.id] = true;
                                          });
                                          _showSnackBar("Cash drawer opened");
                                          await printer
                                              .waitForCashDrawerClose();
                                          setState(() {
                                            cashDrawerOpen[printer.id] = false;
                                          });
                                          _showSnackBar("Cash drawer closed");
                                        },
                                        child: const Text('Open cash drawer')),
                                    TextButton(
                                        onPressed: () async {
                                          final status =
                                              await printer.getStatus();
                                          _showSnackBar('Status: $status');
                                        },
                                        child: const Text('Status')),
                                  ],
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
                  // Info & Broadcasts
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Printer Info & Broadcasts',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              TextButton(
                                  onPressed: () async {
                                    if (printers.isEmpty) return;
                                    final printer = printers.first;
                                    final id = await _sunmiPrinterXPlugin
                                        .getPrinterId(printer.id);
                                    _showSnackBar('Printer ID: $id');
                                  },
                                  child: const Text('Show Printer ID')),
                              TextButton(
                                  onPressed: () async {
                                    if (printers.isEmpty) return;
                                    final printer = printers.first;
                                    final version = await _sunmiPrinterXPlugin
                                        .getPrinterVersion(printer.id);
                                    _showSnackBar('Printer Version: $version');
                                  },
                                  child: const Text('Show Printer Version')),
                              TextButton(
                                  onPressed: () async {
                                    if (printers.isEmpty) return;
                                    final printer = printers.first;
                                    final type = await _sunmiPrinterXPlugin
                                        .getPrinterType(printer.id);
                                    _showSnackBar('Printer Type: $type');
                                  },
                                  child: const Text('Show Printer Type')),
                              TextButton(
                                  onPressed: () async {
                                    if (printers.isEmpty) return;
                                    final printer = printers.first;
                                    final cutter = await _sunmiPrinterXPlugin
                                        .getCutterNumber(printer.id);
                                    _showSnackBar('Cutter Number: $cutter');
                                  },
                                  child: const Text('Show Cutter Number')),
                              TextButton(
                                  onPressed: () async {
                                    if (printers.isEmpty) return;
                                    final printer = printers.first;
                                    final distance = await _sunmiPrinterXPlugin
                                        .getPrintedDistance(printer.id);
                                    _showSnackBar(
                                        'Printed Distance: $distance');
                                  },
                                  child: const Text('Show Printed Distance')),
                              TextButton(
                                  onPressed: () async {
                                    if (printers.isEmpty) return;
                                    final printer = printers.first;
                                    final hot = await _sunmiPrinterXPlugin
                                        .getPrinterHotTimes(printer.id);
                                    _showSnackBar('Printer Hot Times: $hot');
                                  },
                                  child: const Text('Show Printer Hot Times')),
                              TextButton(
                                  onPressed: () async {
                                    if (printers.isEmpty) return;
                                    final printer = printers.first;
                                    final density = await _sunmiPrinterXPlugin
                                        .getPrinterDensity(printer.id);
                                    _showSnackBar('Printer Density: $density');
                                  },
                                  child: const Text('Show Printer Density')),
                              TextButton(
                                  onPressed: () async {
                                    // Subscribe to printer status broadcasts
                                    _broadcastSubscription?.cancel();
                                    _broadcastSubscription =
                                        _sunmiPrinterXPlugin
                                            .subscribeToPrinterStatusBroadcasts(
                                                (action, data) {
                                      setState(() {
                                        _lastBroadcastEvent = 'Action: '
                                            '$action Data: ${data?.toString() ?? ''}';
                                      });
                                      _showSnackBar(_lastBroadcastEvent);
                                    });
                                  },
                                  child: const Text(
                                      'Subscribe to Printer Status Broadcasts')),
                              TextButton(
                                  onPressed: () async {
                                    // Cancel broadcast subscription
                                    await _broadcastSubscription?.cancel();
                                    setState(() {
                                      _lastBroadcastEvent =
                                          'Subscription cancelled.';
                                    });
                                    _showSnackBar(_lastBroadcastEvent);
                                  },
                                  child: const Text(
                                      'Cancel Broadcast Subscription')),
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
