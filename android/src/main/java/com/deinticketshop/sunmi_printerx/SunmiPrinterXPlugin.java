package com.deinticketshop.sunmi_printerx;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.sunmi.printerx.PrinterSdk;
import com.sunmi.printerx.SdkException;
import com.sunmi.printerx.api.PrintResult;
import com.sunmi.printerx.enums.Align;
import com.sunmi.printerx.enums.PrinterInfo;
import com.sunmi.printerx.style.BaseStyle;
import com.sunmi.printerx.style.QrStyle;
import com.sunmi.printerx.style.TextStyle;

import com.sunmi.statuslampmanager.IStateLamp;
import com.sunmi.peripheralsdk.Color;
import com.sunmi.peripheralsdk.StatusLightManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class SunmiPrinterXPlugin implements FlutterPlugin, MethodCallHandler {

    private MethodChannel channel;
    private Context context;

    // ── K2 Kiosk alarm lamp (IStateLamp AIDL) ────────────────────────────────

    private IStateLamp mService;
    private final List<Runnable> servicePendingTasks = new ArrayList<>();

    private final ServiceConnection con = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            mService = IStateLamp.Stub.asInterface(service);
            Log.d("SunmiPrinterX", "K2 lamp service connected.");
            drainStatusLightQueue();
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            Log.d("SunmiPrinterX", "K2 lamp service disconnected.");
            mService = null;
        }
    };

    private void connectToLampService() {
        Intent intent = new Intent();
        intent.setPackage("com.sunmi.statuslampmanager");
        intent.setAction("com.sunmi.statuslamp.service");
        context.bindService(intent, con, Context.BIND_AUTO_CREATE);
    }

    // ── Flex 3 status light (StatusLightManager SDK) ─────────────────────────

    private boolean flex3Ready = false;

    private void initFlex3StatusLight() {
        StatusLightManager.INSTANCE.init(context, new kotlin.jvm.functions.Function1<Boolean, kotlin.Unit>() {
            @Override
            public kotlin.Unit invoke(Boolean success) {
                if (success) {
                    try {
                        StatusLightManager.INSTANCE.openDevice();
                        flex3Ready = true;
                        Log.d("SunmiPrinterX", "Flex 3 status light ready.");
                        drainStatusLightQueue();
                    } catch (RemoteException e) {
                        Log.e("SunmiPrinterX", "Flex 3 openDevice failed: " + e.getMessage());
                    }
                }
                return kotlin.Unit.INSTANCE;
            }
        });
    }

    // ── Unified status light queue ────────────────────────────────────────────
    // Tasks contain their own routing logic (flex3Ready / mService check),
    // so whichever service fires first will run them correctly.

    private final List<Runnable> statusLightQueue = new ArrayList<>();

    private void drainStatusLightQueue() {
        synchronized (statusLightQueue) {
            for (Runnable task : statusLightQueue) {
                new Thread(task).start();
            }
            statusLightQueue.clear();
        }
    }

    private void runWithStatusLight(Runnable task) {
        if (flex3Ready || mService != null) {
            new Thread(task).start();
        } else {
            synchronized (statusLightQueue) {
                statusLightQueue.add(task);
            }
        }
    }

    // ── Color helpers ─────────────────────────────────────────────────────────

    private Color flex3ColorFromString(String color) {
        switch (color) {
            case "red":    return Color.Red;
            case "green":  return Color.Green;
            case "blue":   return Color.Blue;
            case "yellow": return Color.Yellow;
            case "purple": return Color.Magenta;
            case "cyan":   return Color.Cyan;
            default:       return Color.White;
        }
    }

    // Led-1=red, Led-2=green, Led-3=blue
    private String[] k2LampsForColor(String color) {
        switch (color) {
            case "red":    return new String[]{"Led-1"};
            case "green":  return new String[]{"Led-2"};
            case "blue":   return new String[]{"Led-3"};
            case "yellow": return new String[]{"Led-1", "Led-2"};
            case "purple": return new String[]{"Led-1", "Led-3"};
            case "cyan":   return new String[]{"Led-2", "Led-3"};
            default:       return new String[]{"Led-1", "Led-2", "Led-3"};
        }
    }

    // ── FlutterPlugin lifecycle ───────────────────────────────────────────────

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "sunmi_printerx");
        channel.setMethodCallHandler(this);
        context = binding.getApplicationContext();
        connectToLampService();
        initFlex3StatusLight();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        try {
            if (mService != null) {
                mService.closeAllLamp();
                context.unbindService(con);
            }
        } catch (RemoteException e) {
            e.printStackTrace();
        }
        if (flex3Ready) {
            StatusLightManager.INSTANCE.destroy(context);
            flex3Ready = false;
        }
    }

    // ── Printer SDK ───────────────────────────────────────────────────────────

    private final HashMap<String, PrinterSdk.Printer> printers = new HashMap<>();

    private PrinterSdk.Printer getPrinter(MethodCall call) {
        return printers.get(call.argument("printerId").toString());
    }

    private static TextStyle getTextStyle(MethodCall call) {
        return TextStyle.getStyle()
                .setTextWidthRatio(Integer.parseInt(call.argument("textWidthRatio").toString()))
                .setTextHeightRatio(Integer.parseInt(call.argument("textHeightRatio").toString()))
                .setTextSize(Integer.parseInt(call.argument("textSize").toString()))
                .setTextSpace(Integer.parseInt(call.argument("textSpace").toString()))
                .enableBold(Boolean.parseBoolean(call.argument("bold").toString()))
                .enableUnderline(Boolean.parseBoolean(call.argument("underline").toString()))
                .enableStrikethrough(Boolean.parseBoolean(call.argument("strikethrough").toString()))
                .enableItalics(Boolean.parseBoolean(call.argument("italics").toString()));
    }

    // ── Method dispatch ───────────────────────────────────────────────────────

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {

            case "getPrinters":
                new Thread(() -> {
                    try {
                        PrinterSdk.getInstance().getPrinter(context, new PrinterSdk.PrinterListen() {
                            @Override public void onDefPrinter(PrinterSdk.Printer p) {}

                            @Override
                            public void onPrinters(List<PrinterSdk.Printer> list) {
                                try {
                                    List<HashMap<String, String>> printerList = new ArrayList<>();
                                    for (PrinterSdk.Printer p : list) {
                                        String id = p.queryApi().getInfo(PrinterInfo.ID);
                                        if (id == null) id = System.currentTimeMillis() + "" + Math.random();
                                        printers.put(id, p);
                                        HashMap<String, String> info = new HashMap<>();
                                        info.put("name",     p.queryApi().getInfo(PrinterInfo.NAME));
                                        info.put("status",   p.queryApi().getStatus().toString());
                                        info.put("hot",      p.queryApi().getInfo(PrinterInfo.HOT));
                                        info.put("version",  p.queryApi().getInfo(PrinterInfo.VERSION));
                                        info.put("id",       id);
                                        info.put("cutter",   p.queryApi().getInfo(PrinterInfo.CUTTER));
                                        info.put("density",  p.queryApi().getInfo(PrinterInfo.DENSITY));
                                        info.put("distance", p.queryApi().getInfo(PrinterInfo.DISTANCE));
                                        info.put("gray",     p.queryApi().getInfo(PrinterInfo.GRAY));
                                        info.put("paper",    p.queryApi().getInfo(PrinterInfo.PAPER));
                                        info.put("type",     p.queryApi().getInfo(PrinterInfo.TYPE));
                                        printerList.add(info);
                                    }
                                    result.success(printerList);
                                } catch (SdkException e) {
                                    result.error("ERROR", e.getMessage(), null);
                                }
                            }
                        });
                    } catch (SdkException e) {
                        result.error("ERROR", e.getMessage(), null);
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
                    result.error("ERROR", e.getMessage(), null);
                }
                break;

            case "isCashDrawerOpen":
                try {
                    result.success(getPrinter(call).cashDrawerApi().isOpen());
                } catch (SdkException e) {
                    result.error("ERROR", e.getMessage(), null);
                }
                break;

            case "getPrinterStatus":
                new Thread(() -> {
                    try {
                        result.success(getPrinter(call).queryApi().getStatus().toString());
                    } catch (SdkException e) {
                        result.error("ERROR", e.getMessage(), null);
                    }
                }).start();
                break;

            case "printEscPosCommands":
                new Thread(() -> {
                    try {
                        byte[] commands = call.argument("commands");
                        getPrinter(call).commandApi().sendEscCommand(commands);
                        result.success(true);
                    } catch (SdkException e) {
                        result.error("ERROR", e.getMessage(), null);
                    }
                }).start();
                break;

            case "setAlign":
                new Thread(() -> {
                    try {
                        getPrinter(call).lineApi().initLine(
                                BaseStyle.getStyle().setAlign(Align.valueOf(call.argument("align").toString())));
                        result.success(true);
                    } catch (SdkException e) {
                        result.error("ERROR", e.getMessage(), null);
                    }
                }).start();
                break;

            case "addText":
                new Thread(() -> {
                    try {
                        getPrinter(call).lineApi().addText(call.argument("text").toString(), getTextStyle(call));
                        result.success(true);
                    } catch (SdkException e) {
                        result.error("ERROR", e.getMessage(), null);
                    }
                }).start();
                break;

            case "printText":
                new Thread(() -> {
                    try {
                        getPrinter(call).lineApi().printText(call.argument("text").toString(), getTextStyle(call));
                        result.success(true);
                    } catch (SdkException e) {
                        result.error("ERROR", e.getMessage(), null);
                    }
                }).start();
                break;

            case "printTexts":
                new Thread(() -> {
                    try {
                        List<String> texts = call.argument("texts");
                        List<Integer> colsWidthArrs = call.argument("colsWidthArrs");
                        List<String> aligns = call.argument("aligns");
                        List<TextStyle> styles = new ArrayList<>();
                        for (int i = 0; i < texts.size(); i++) {
                            styles.add(new TextStyle().setAlign(Align.valueOf(aligns.get(i))));
                        }
                        int[] colsWidthArr = new int[colsWidthArrs.size()];
                        for (int i = 0; i < colsWidthArrs.size(); i++) colsWidthArr[i] = colsWidthArrs.get(i);
                        getPrinter(call).lineApi().printTexts(
                                texts.toArray(new String[0]), colsWidthArr, styles.toArray(new TextStyle[0]));
                        result.success(true);
                    } catch (SdkException e) {
                        result.error("ERROR", e.getMessage(), null);
                    }
                }).start();
                break;

            case "printQrCode":
                new Thread(() -> {
                    try {
                        QrStyle style = QrStyle.getStyle();
                        style.setDot(Integer.parseInt(call.argument("dot").toString()));
                        style.setAlign(Align.valueOf(call.argument("align").toString()));
                        getPrinter(call).lineApi().printQrCode(call.argument("data").toString(), style);
                        result.success(true);
                    } catch (SdkException e) {
                        result.error("ERROR", e.getMessage(), null);
                    }
                }).start();
                break;

            case "autoOut":
                new Thread(() -> {
                    try {
                        getPrinter(call).lineApi().autoOut();
                        result.success(true);
                    } catch (SdkException e) {
                        result.error("ERROR", e.getMessage(), null);
                    }
                }).start();
                break;

            case "getInfo":
                new Thread(() -> {
                    try {
                        PrinterInfo info = PrinterInfo.valueOf(call.<String>argument("infoType"));
                        result.success(getPrinter(call).queryApi().getInfo(info));
                    } catch (Exception e) {
                        result.error("ERROR", e.getMessage(), null);
                    }
                }).start();
                break;

            // ── Unified status light (K2 + Flex 3) ───────────────────────────

            case "setStatusLightColor": {
                String colorStr = call.argument("color");
                runWithStatusLight(() -> {
                    try {
                        if (flex3Ready) {
                            StatusLightManager.INSTANCE.setColor(flex3ColorFromString(colorStr));
                        } else {
                            mService.closeAllLamp();
                            for (String lamp : k2LampsForColor(colorStr)) {
                                mService.controlLamp(0, lamp);
                            }
                        }
                        result.success(true);
                    } catch (Exception e) {
                        result.error("ERROR", e.getMessage(), null);
                    }
                });
                break;
            }

            case "setStatusLightOff": {
                runWithStatusLight(() -> {
                    try {
                        if (flex3Ready) {
                            StatusLightManager.INSTANCE.turnOff();
                        } else {
                            mService.closeAllLamp();
                        }
                        result.success(true);
                    } catch (Exception e) {
                        result.error("ERROR", e.getMessage(), null);
                    }
                });
                break;
            }

            case "setStatusLightFlashing": {
                String colorStr = call.argument("color");
                int onMs  = Integer.parseInt(call.argument("onMs").toString());
                int offMs = Integer.parseInt(call.argument("offMs").toString());
                runWithStatusLight(() -> {
                    try {
                        if (flex3Ready) {
                            StatusLightManager.INSTANCE.setFlashing(flex3ColorFromString(colorStr), onMs, offMs);
                        } else {
                            mService.controlLampForLoops(0, onMs, offMs, k2LampsForColor(colorStr));
                        }
                        result.success(true);
                    } catch (Exception e) {
                        result.error("ERROR", e.getMessage(), null);
                    }
                });
                break;
            }

            case "setStatusLightMultiFlashing": {
                List<String> colorStrs = call.argument("colors");
                List<Integer> onMsList  = call.argument("onMs");
                List<Integer> offMsList = call.argument("offMs");
                runWithStatusLight(() -> {
                    try {
                        if (flex3Ready) {
                            Color[] colors = new Color[colorStrs.size()];
                            int[] onMs  = new int[onMsList.size()];
                            int[] offMs = new int[offMsList.size()];
                            for (int i = 0; i < colorStrs.size(); i++) {
                                colors[i] = flex3ColorFromString(colorStrs.get(i));
                                onMs[i]   = onMsList.get(i);
                                offMs[i]  = offMsList.get(i);
                            }
                            StatusLightManager.INSTANCE.setMultiFlashing(colors, onMs, offMs);
                        } else {
                            // K2 approximation: flash the first color only
                            mService.controlLampForLoops(
                                    0,
                                    onMsList.get(0),
                                    offMsList.get(0),
                                    k2LampsForColor(colorStrs.get(0)));
                        }
                        result.success(true);
                    } catch (Exception e) {
                        result.error("ERROR", e.getMessage(), null);
                    }
                });
                break;
            }

            default:
                result.notImplemented();
        }
    }
}
