class Currency {
  Currency({this.currencyAbbreviation, this.rate});
  final String currencyAbbreviation;
  final dynamic rate;

  static Currency fromJson(dynamic json) {
    final consolidated = json['rates'];
  }
}
