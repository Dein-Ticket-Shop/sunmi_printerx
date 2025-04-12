enum AlarmLampColor {
  red,
  green,
  blue,
  white,
  yellow,
  purple,
  cyan,
}

List<String> alarmLampColorToLEDs(AlarmLampColor color) {
  // Led-1 is red, Led-2 is green, Led-3 is blue
  switch (color) {
    case AlarmLampColor.red:
      return ["Led-1"];
    case AlarmLampColor.green:
      return ["Led-2"];
    case AlarmLampColor.blue:
      return ["Led-3"];
    case AlarmLampColor.yellow:
      return ["Led-1", "Led-2"];
    case AlarmLampColor.purple:
      return ["Led-1", "Led-3"];
    case AlarmLampColor.cyan:
      return ["Led-2", "Led-3"];
    case AlarmLampColor.white:
      return ["Led-1", "Led-2", "Led-3"];
  }
}
