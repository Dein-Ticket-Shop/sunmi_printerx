package com.deinticketshop.sunmi_printerx;

import android.content.Context;
import android.os.RemoteException;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.sunmi.printerx.PrinterSdk;
import com.sunmi.printerx.SdkException;
import com.sunmi.printerx.api.PrintResult;
import com.sunmi.printerx.enums.Align;
import com.sunmi.printerx.enums.PrinterInfo;
import com.sunmi.printerx.enums.Status;
import com.sunmi.printerx.style.BaseStyle;
import com.sunmi.printerx.style.QrStyle;
import com.sunmi.printerx.style.TextStyle;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * SunmiPrinterXPlugin
 */
public class SunmiPrinterXPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native
    /// Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine
    /// and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;

    Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "sunmi_printerx");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    HashMap<String, PrinterSdk.Printer> printers = new HashMap<>();

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "getPrinters":
                // run in separate thread, because otherwise we get network on main thread exception
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            PrinterSdk.getInstance().getPrinter(context, new PrinterSdk.PrinterListen() {

                                @Override
                                public void onDefPrinter(PrinterSdk.Printer defaultPrinter) {

                                }

                                @Override
                                public void onPrinters(List<PrinterSdk.Printer> list) {
                                    try {
                                        // find one that is not offline
                                        // build a list of maps with name and status
                                        List<HashMap<String, String>> printerList = new ArrayList<>();
                                        for (PrinterSdk.Printer p : list) {
                                            String id = p.queryApi().getInfo(PrinterInfo.ID);
                                            if (id == null) {
                                                id = String.valueOf(System.currentTimeMillis()) + Math.random();
                                            }
                                            printers.put(id, p);
                                            HashMap<String, String> printer = new HashMap<>();
                                            printer.put("name", p.queryApi().getInfo(PrinterInfo.NAME));
                                            printer.put("status", p.queryApi().getStatus().toString());
                                            printer.put("hot", p.queryApi().getInfo(PrinterInfo.HOT));
                                            printer.put("version", p.queryApi().getInfo(PrinterInfo.VERSION));
                                            printer.put("id", id);
                                            printer.put("cutter", p.queryApi().getInfo(PrinterInfo.CUTTER));
                                            printer.put("density", p.queryApi().getInfo(PrinterInfo.DENSITY));
                                            printer.put("distance", p.queryApi().getInfo(PrinterInfo.DISTANCE));
                                            printer.put("gray", p.queryApi().getInfo(PrinterInfo.GRAY));
                                            printer.put("paper", p.queryApi().getInfo(PrinterInfo.PAPER));
                                            printer.put("type", p.queryApi().getInfo(PrinterInfo.TYPE));
                                            printerList.add(printer);
                                        }
                                        result.success(printerList);
                                    } catch (SdkException e) {
                                        e.printStackTrace();
                                        result.error("ERROR", e.getMessage(), null);
                                    }
                                }
                            });
                        } catch (SdkException e) {
                            e.printStackTrace();
                            result.error("ERROR", e.getMessage(), null);
                        }
                    }

                }).start();

                break;
            case "openCashDrawer":
                try {
                    getPrinter(call).cashDrawerApi().open(new PrintResult() {
                        @Override
                        public void onResult(int i, String s) throws RemoteException {
                            result.success(i == 0);
                        }
                    });
                } catch (SdkException e) {
                    e.printStackTrace();
                    result.error("ERROR", e.getMessage(), null);
                }
                break;
            case "isCashDrawerOpen":
                try {
                    result.success(getPrinter(call).cashDrawerApi().isOpen());
                } catch (SdkException e) {
                    e.printStackTrace();
                    result.error("ERROR", e.getMessage(), null);
                }
                break;
            case "getPrinterStatus":
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            result.success(getPrinter(call).queryApi().getStatus().toString());
                        } catch (SdkException e) {
                            e.printStackTrace();
                            result.error("ERROR", e.getMessage(), null);
                        }
                    }
                }).start();
                break;
            case "printEscPosCommands":
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            byte[] commands = call.argument("commands");
                            getPrinter(call).commandApi().sendEscCommand(commands);
                            result.success(true);
                        } catch (SdkException e) {
                            e.printStackTrace();
                            result.error("ERROR", e.getMessage(), null);
                        }
                    }
                }).start();
                break;
            case "setAlign":
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            getPrinter(call).lineApi().initLine(BaseStyle.getStyle().setAlign(Align.valueOf(call.argument("align").toString())));
                            result.success(true);
                        } catch (SdkException e) {
                            e.printStackTrace();
                            result.error("ERROR", e.getMessage(), null);
                        }
                    }
                }).start();
                break;
            case "addText": {
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            TextStyle style = getTextStyle(call);
                            getPrinter(call).lineApi().addText(call.argument("text").toString(), style);
                            result.success(true);
                        } catch (SdkException e) {
                            e.printStackTrace();
                            result.error("ERROR", e.getMessage(), null);
                        }
                    }
                }).start();
                break;
            }
            case "printText": {
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            TextStyle style = getTextStyle(call);
                            getPrinter(call).lineApi().printText(call.argument("text").toString(), style);
                            result.success(true);
                        } catch (SdkException e) {
                            e.printStackTrace();
                            result.error("ERROR", e.getMessage(), null);
                        }
                    }
                }).start();
                break;
            }
            case "printTexts": {
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            // String[] texts, int[] colsWidthArrs, TextStyle[] styles
                            // style can only be alignment
                            List<String> texts = call.argument("texts");
                            List<Integer> colsWidthArrs = call.argument("colsWidthArrs");
                            List<String> aligns = call.argument("aligns");
                            List<TextStyle> styles = new ArrayList<>();
                            for (int i = 0; i < texts.size(); i++) {
                                styles.add(new TextStyle().setAlign(Align.valueOf(aligns.get(i))));
                            }
                            int[] colsWidthArr = new int[colsWidthArrs.size()];
                            for (int i = 0; i < colsWidthArrs.size(); i++) {
                                colsWidthArr[i] = colsWidthArrs.get(i);
                            }

                            getPrinter(call).lineApi().printTexts(texts.toArray(new String[0]), colsWidthArr, styles.toArray(new TextStyle[0]));
                            result.success(true);
                        } catch (SdkException e) {
                            e.printStackTrace();
                            result.error("ERROR", e.getMessage(), null);
                        }
                    }
                }).start();
                break;
            }
            case "printQrCode": {
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            QrStyle style = QrStyle.getStyle();
                            style.setDot(Integer.parseInt(call.argument("dot").toString()));
                            style.setAlign(Align.valueOf(call.argument("align").toString()));
                            getPrinter(call).lineApi().printQrCode(call.argument("data").toString(), style);
                            result.success(true);
                        } catch (SdkException e) {
                            e.printStackTrace();
                            result.error("ERROR", e.getMessage(), null);
                        }
                    }
                }).start();
                break;
            }
            case "autoOut": {
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            getPrinter(call).lineApi().autoOut();
                            result.success(true);
                        } catch (SdkException e) {
                            e.printStackTrace();
                            result.error("ERROR", e.getMessage(), null);
                        }
                    }
                }).start();
                break;
            }
            default:
                result.notImplemented();
                break;
        }
    }

    private static TextStyle getTextStyle(MethodCall call) {
        return TextStyle.getStyle()
        .setTextWidthRatio(Integer.parseInt(call.argument("textWidthRatio").toString()))
        .setTextHeightRatio(Integer.parseInt(call.argument("textHeightRatio").toString()))
        .setTextSpace(Integer.parseInt(call.argument("textSpace").toString()))
        .enableBold(Boolean.parseBoolean(call.argument("bold").toString()))
        .enableUnderline(Boolean.parseBoolean(call.argument("underline").toString()))
        .enableStrikethrough(Boolean.parseBoolean(call.argument("strikethrough").toString()))
        .enableItalics(Boolean.parseBoolean(call.argument("italics").toString()));
    }

    private PrinterSdk.Printer getPrinter(MethodCall call) {
        return printers.get(call.argument("printerId").toString());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
