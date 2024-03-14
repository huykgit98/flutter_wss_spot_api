import 'package:intl/intl.dart';

class MarketCapUtil {
  static String formatMarketCap(double marketCap) {
    if (marketCap >= 1e9) {
      // Convert to billion (B)
      return '${_addCommas((marketCap / 1e9).toStringAsFixed(2))}B';
    } else if (marketCap >= 1e6) {
      // Convert to million (M)
      return '${_addCommas((marketCap / 1e6).toStringAsFixed(2))}M';
    } else if (marketCap >= 1e3) {
      // Convert to thousand (K)
      return '${_addCommas((marketCap / 1e3).toStringAsFixed(2))}K';
    } else {
      // No conversion needed
      return _addCommas(marketCap.toStringAsFixed(2));
    }
  }

  static String _addCommas(String value) {
    return value.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  static String customPriceFormatter(double price) {
    if (price < 1) {
      return price.toStringAsFixed(8);
    } else {
      final priceFormatter = NumberFormat("#,##0.00", "en_US");
      return priceFormatter.format(price);
    }
  }
}
