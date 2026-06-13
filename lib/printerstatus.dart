enum PrinterStatus {
  ready,
  offline,
  comm,
  unknown,
  paperOut,
  paperJam,
  paperMismatch,
  printerHot,
  motorHot,
  cover,
  coverIncomplete,
  cutter,
  cartridgeLoss,
  cartridgeMismatch,
  cartridgeEmpty,
  duplexLoss,
  cartonLoss,
  cartonMismatch,
  cartonEmpty,
  drumLoss,
  drumMismatch,
  drumEmpty,
  step,
  warnCartridge,
  warnSpecialPaper,
  warnStandardPaper,
  warnPickPaper,
  warnThermalPaper,
}

PrinterStatus printerStatusFromString(String status) {
  switch (status) {
    case 'READY':
      return PrinterStatus.ready;
    case 'OFFLINE':
      return PrinterStatus.offline;
    case 'COMM':
      return PrinterStatus.comm;
    case 'UNKNOWN':
      return PrinterStatus.unknown;
    case 'ERR_PAPER_OUT':
      return PrinterStatus.paperOut;
    case 'ERR_PAPER_JAM':
      return PrinterStatus.paperJam;
    case 'ERR_PAPER_MISMATCH':
      return PrinterStatus.paperMismatch;
    case 'ERR_PRINTER_HOT':
      return PrinterStatus.printerHot;
    case 'ERR_MOTOR_HOT':
      return PrinterStatus.motorHot;
    case 'ERR_COVER':
      return PrinterStatus.cover;
    case 'ERR_COVER_INCOMPLETE':
      return PrinterStatus.coverIncomplete;
    case 'ERR_CUTTER':
      return PrinterStatus.cutter;
    case 'ERR_CARTRIDGE_LOSS':
      return PrinterStatus.cartridgeLoss;
    case 'ERR_CARTRIDGE_MISMATCH':
      return PrinterStatus.cartridgeMismatch;
    case 'ERR_CARTRIDGE_EMPTY':
      return PrinterStatus.cartridgeEmpty;
    case 'ERR_DUPLEX_LOSS':
      return PrinterStatus.duplexLoss;
    case 'ERR_CARTON_LOSS':
      return PrinterStatus.cartonLoss;
    case 'ERR_CARTON_MISMATCH':
      return PrinterStatus.cartonMismatch;
    case 'ERR_CARTON_EMPTY':
      return PrinterStatus.cartonEmpty;
    case 'ERR_DRUM_LOSS':
      return PrinterStatus.drumLoss;
    case 'ERR_DRUM_MISMATCH':
      return PrinterStatus.drumMismatch;
    case 'ERR_DRUM_EMPTY':
      return PrinterStatus.drumEmpty;
    case 'ERR_STEP':
      return PrinterStatus.step;
    case 'WARN_CARTRIDGE':
      return PrinterStatus.warnCartridge;
    case 'WARN_SPECIAL_PAPER':
      return PrinterStatus.warnSpecialPaper;
    case 'WARN_STANDARD_PAPER':
      return PrinterStatus.warnStandardPaper;
    case 'WARN_PICK_PAPER':
      return PrinterStatus.warnPickPaper;
    case 'WARN_THERMAL_PAPER':
      return PrinterStatus.warnThermalPaper;
    default:
      return PrinterStatus.unknown;
  }
}
