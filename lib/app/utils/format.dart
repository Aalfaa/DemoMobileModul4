import 'package:intl/intl.dart';

String formatHarga(int harga) {
  final f = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return f.format(harga);
}
