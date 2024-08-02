enum Align {
  left,
  center,
  right,
}

String alignToString(Align align) {
  switch (align) {
    case Align.left:
      return 'LEFT';
    case Align.center:
      return 'CENTER';
    case Align.right:
      return 'RIGHT';
    default:
      throw Exception('Unknown align: $align');
  }
}

Align alignFromString(String status) {
  switch (status) {
    case 'DEFAULT':
    case 'LEFT':
      return Align.left;
    case 'CENTER':
      return Align.center;
    case 'RIGHT':
      return Align.right;
    default:
      throw Exception('Unknown align: $status');
  }
}
