enum PrinterStatus {
  ready,
  offline,
  comm,
  paperOut,
  paperJam,
  paperMismatch,
  printerHot,
  motorHot,
  cover,
  coverIncomplete
}

PrinterStatus printerStatusFromString(String status) {
  switch (status) {
    case 'READY':
      return PrinterStatus.ready;
    case 'OFFLINE':
      return PrinterStatus.offline;
    case 'COMM':
      return PrinterStatus.comm;
    case 'PAPER_OUT':
      return PrinterStatus.paperOut;
    case 'PAPER_JAM':
      return PrinterStatus.paperJam;
    case 'PAPER_MISMATCH':
      return PrinterStatus.paperMismatch;
    case 'PRINTER_HOT':
      return PrinterStatus.printerHot;
    case 'MOTOR_HOT':
      return PrinterStatus.motorHot;
    case 'COVER':
      return PrinterStatus.cover;
    case 'COVER_INCOMPLETE':
      return PrinterStatus.coverIncomplete;
    default:
      throw Exception('Unknown printer status: $status');
  }
}
