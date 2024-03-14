import 'package:binance_websocket_flutter/utils.dart';
import 'package:flutter/material.dart';

class TickerPrice extends StatelessWidget {
  final String symbol;
  final double price;
  final double circulationSupply;

  const TickerPrice({
    Key? key,
    required this.symbol,
    required this.price,
    required this.circulationSupply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      MarketCapUtil.formatMarketCap(price * circulationSupply),
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
