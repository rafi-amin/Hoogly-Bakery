import 'package:esc_pos_utils/esc_pos_utils.dart';

import '../../domain/entities/order.dart';
import '../utils/formatters.dart';

/// Generates ESC/POS ticket bytes for a given order.
class ReceiptBuilder {
  ReceiptBuilder(this._profile);

  final CapabilityProfile _profile;

  Future<List<int>> build(Order order) async {
    final generator = Generator(PaperSize.mm58, _profile);
    final bytes = <int>[];

    bytes.addAll(generator.text(
      'Hoogli Bakery',
      styles: const PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
        align: PosAlign.center,
      ),
      linesAfter: 1,
    ));

    bytes.addAll(generator.text(
      'Order #${order.id ?? '-'}',
      styles: const PosStyles(align: PosAlign.center),
    ));
    bytes.addAll(generator.text(
      formatTimestamp(order.createdAt),
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    ));

    for (final item in order.items) {
      bytes.addAll(generator.row([
        PosColumn(
          text: item.name,
          width: 8,
        ),
        PosColumn(
          text: 'x${item.quantity}',
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: formatCurrency(item.price),
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]));
    }

    bytes.addAll(generator.hr());
    bytes.addAll(generator.row([
      PosColumn(text: 'Subtotal', width: 8),
      PosColumn(
        text: formatCurrency(order.subtotal),
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]));
    bytes.addAll(generator.row([
      PosColumn(text: 'Tax', width: 8),
      PosColumn(
        text: formatCurrency(order.tax),
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]));
    bytes.addAll(generator.row([
      PosColumn(
        text: 'TOTAL',
        width: 8,
        styles: const PosStyles(bold: true, height: PosTextSize.size2),
      ),
      PosColumn(
        text: formatCurrency(order.total),
        width: 4,
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
          height: PosTextSize.size2,
        ),
      ),
    ]));

    bytes.addAll(generator.text(
      'Payment: ${order.paymentMethod}',
      styles: const PosStyles(align: PosAlign.center),
    ));
    bytes.addAll(generator.text(
      'Status: ${order.status}',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    ));

    bytes.addAll(generator.text(
      'Thank you for choosing Hoogli!',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 2,
    ));

    bytes.addAll(generator.cut());
    return bytes;
  }
}
