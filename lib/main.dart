import 'dart:async';
import 'dart:convert';

import 'package:binance_websocket_flutter/ticker_price_widget.dart';
import 'package:binance_websocket_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';

import 'models.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Binance Coins',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, Ticker> allTickers = {};
  bool isLoading = true;
  Map<String, bool> priceChangeFlags = {};

  final channel = IOWebSocketChannel.connect(
      'wss://stream.binance.com:9443/ws/!miniTicker@arr');

  @override
  void initState() {
    super.initState();

    fetchTickers();
    channel.stream.listen((message) {
      final List<dynamic> tickers = jsonDecode(message);
      setState(() {
        updateTickersFromWebSocket(tickers);
      });
    });
  }

  Future<void> fetchTickers() async {
    try {
      final tickersRequest = Uri.https(
          'www.binance.com',
          '/bapi/asset/v2/public/asset-service/product/get-products',
          {'includeEtf': 'true'});

      final response = await http.get(tickersRequest);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> tickersData =
            data['data'].where((ticker) => ticker['q'] == 'USDT').toList();
        setState(() {
          allTickers = Map.fromEntries(tickersData.map((ticker) => MapEntry(
                ticker['s'],
                Ticker(
                  symbol: ticker['s'],
                  price: double.parse(ticker['c'] ?? '0'),
                  circulationSupply: ticker['cs'].toDouble() ?? 0,
                  name: ticker['an'],
                  quote: ticker['q'],
                  baseSymbol: ticker['b'],
                ),
              )));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load ticker data');
      }
    } catch (e) {
      print('Error fetching ticker data: $e');
    }
  }

  void updateTickersFromWebSocket(List<dynamic> tickers) {
    for (var tickerData in tickers) {
      var symbol = tickerData['s'];
      if (allTickers.containsKey(symbol)) {
        var newPrice = double.parse(tickerData['c'] ?? '0');
        var previousPrice = allTickers[symbol]!.price;
        var priceIncreased = newPrice > previousPrice;

        var updatedTicker = allTickers[symbol]!.copyWith(
          price: newPrice,
          priceIncreased: priceIncreased,
        );
        setState(() {
          allTickers[symbol] = updatedTicker;
          // Set a flag to indicate price change
          priceChangeFlags[symbol] = true;
        });

        // Reset flag after a delay
        Timer(Duration(milliseconds: 5000), () {
          setState(() {
            priceChangeFlags[symbol] = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Convert the map to a list of entries
    var entries = allTickers.entries.toList();

    // Sort the entries by market cap in descending order
    entries.sort((a, b) => (b.value.price * (b.value.circulationSupply ?? 0))
        .compareTo(a.value.price * (a.value.circulationSupply ?? 0)));

    return Scaffold(
      appBar: AppBar(
        title: Text('Binance Coins'),
      ),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final tickerEntry = entries[index];
          final ticker = tickerEntry.value;
          final formattedPrice =
              MarketCapUtil.customPriceFormatter(ticker.price);
          var textColor = priceChangeFlags[ticker.symbol] ?? false
              ? ticker.priceIncreased
                  ? Colors.green
                  : Colors.red
              : Colors.black;
          return ListTile(
            title:
                Text('${ticker.name} - ${ticker.baseSymbol} - ${ticker.quote}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price: \$${formattedPrice}',
                  style: TextStyle(color: textColor),
                ),
                Row(
                  children: [
                    Text('Market Cap: \$'),
                    isLoading
                        ? const CircularProgressIndicator()
                        : TickerPrice(
                            symbol: ticker.symbol,
                            price: ticker.price,
                            circulationSupply: ticker.circulationSupply ?? 0,
                          ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
