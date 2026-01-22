import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.currency(symbol: '\$');
final _dateFormat = DateFormat('MMM d, h:mm a');

String formatCurrency(num value) => _currencyFormat.format(value);

String formatTimestamp(DateTime time) => _dateFormat.format(time);
