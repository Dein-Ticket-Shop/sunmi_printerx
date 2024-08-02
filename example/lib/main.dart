import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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
        cashDrawerOpen =
            Map.fromIterable(ps, key: (e) => e.id, value: (_) => false);
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
          body: Column(
            children: <Widget>[
              for (final printer in printers)
                ListTile(
                  title: Text(
                      "Printer: ${printer.name} (Cash drawer: ${cashDrawerOpen[printer.id] == true ? 'open' : 'closed'})"),
                  subtitle: Text(printer.status.toString()),
                  trailing: Wrap(
                    children: [
                      TextButton(
                          onPressed: () async {
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
                            await printer.addText('Underlined ',
                                underline: true);
                            await printer.addText('Bold ', bold: true);
                            await printer.addText('Striked\n',
                                strikethrough: true);
                            await printer.setAlign(align.Align.left);
                            // https://pub.dev for 20 times
                            await printer.printQrCode(
                                List.filled(20, 'https://pub.dev').join(),
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
                            final profile = await CapabilityProfile.load();
                            final generator =
                                Generator(PaperSize.mm80, profile);
                            List<int> bytes = [];

                            bytes += generator.text(
                                'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
                            bytes += generator.text(
                                'Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
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
                                styles:
                                    const PosStyles(align: PosAlign.center));
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
                            bytes += generator.barcode(Barcode.upcA(barData));

                            bytes += generator.feed(2);
                            bytes += generator.cut();

                            await printer
                                .printEscPosCommands(Uint8List.fromList(bytes));
                          },
                          child: const Text('Print ESC/POS')),
                      TextButton(
                          onPressed: () async {
                            await printer.openCashDrawer();
                            setState(() {
                              cashDrawerOpen[printer.id] = true;
                            });
                            print("Cash drawer opened");
                            await printer.waitForCashDrawerClose();
                            setState(() {
                              cashDrawerOpen[printer.id] = false;
                            });
                            print("Cash drawer closed");
                          },
                          child: const Text('Open cash drawer')),
                      TextButton(
                          onPressed: () async {
                            final status = await printer.getStatus();
                            _messangerKey.currentState?.showSnackBar(
                              SnackBar(
                                content: Text('Status: $status'),
                              ),
                            );
                          },
                          child: const Text('Status')),
                    ],
                  ),
                ),
              TextButton(
                  onPressed: initDefaultPrinter, child: const Text('Refresh')),
            ],
          ),
        ));
  }
}
