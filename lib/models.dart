class Ticker {
  final String symbol;
  final String? baseSymbol;
  String? name;
  String? quote;
  double price;
  double? circulationSupply;
  bool priceIncreased;

  Ticker({
    required this.symbol,
    this.name = '',
    required this.price,
    this.circulationSupply,
    this.priceIncreased = false,
    this.quote,
    this.baseSymbol,
  });

  Ticker copyWith({
    String? symbol,
    String? name,
    double? price,
    double? circulationSupply,
    bool? priceIncreased,
    String? quote,
    String? baseSymbol,
  }) {
    return Ticker(
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      price: price ?? this.price,
      circulationSupply: circulationSupply ?? this.circulationSupply,
      priceIncreased: priceIncreased ?? this.priceIncreased,
      quote: quote ?? this.quote,
      baseSymbol: baseSymbol ?? this.baseSymbol,
    );
  }
}
