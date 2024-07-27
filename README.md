# Sunmi PrinterX Flutter Plugin

A Flutter plugin for interacting with the Sunmi PrinterX SDK.

## Features

-   Discover available printers
-   Retrieve printer status
-   Send print commands
-   Open and check the status of the cash drawer

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
    sunmi_printerx: ^1.0.0
```

Then, run `flutter pub get` to install the new dependency.

## Usage

### Import the Plugin

```dart
import 'package:sunmi_printerx/sunmi_printerx.dart';
```

### Initialize the Plugin

```dart
final sunmiPrinterX = SunmiPrinterX();
```

## API and Examples

### `SunmiPrinterX`

#### Methods

-   `Future<List<Printer>> getPrinters()`

    -   Retrieves a list of available printers.

    **Example:**

    ```dart
    final sunmiPrinterX = SunmiPrinterX();
    List<Printer> printers = await sunmiPrinterX.getPrinters();
    print(printers);
    ```

### `Printer`

#### Methods

-   `Future<PrinterStatus> getStatus()`

    -   Retrieves the status of the printer.

    **Example:**

    ```dart
    PrinterStatus status = await printer.getStatus();
    print(status);
    ```

-   `Future<void> openCashDrawer()`

    -   Opens the cash drawer.

    **Example:**

    ```dart
    await printer.openCashDrawer();
    ```

-   `Future<bool> isCashDrawerOpen()`

    -   Checks if the cash drawer is open.

    **Example:**

    ```dart
    bool isOpen = await printer.isCashDrawerOpen();
    print(isOpen);
    ```

-   `Future<void> printEscPosCommands(Uint8List commands)`

    -   Sends ESC/POS commands to the printer.

    **Example:**

    ```dart
    await printer.printEscPosCommands(commands);
    ```

-   `Future<void> waitForCashDrawerClose()`

    -   Waits for the cash drawer to close.

    **Example:**

    ```dart
    await printer.waitForCashDrawerClose();
    ```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
