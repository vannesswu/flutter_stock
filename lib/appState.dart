import 'package:flutter/material.dart';
import 'package:flutter_stock/StockDto.dart';

class AppState {
  Map<StockDto, double> priceByStock;
  List<StockDto> stockList;
  bool isLoading;

  AppState({
    this.priceByStock = const {},
    this.stockList = const [],
    this.isLoading = false,
  });

  factory AppState.builder(
      {Map<StockDto, double> priceByStock,
      List<StockDto> stockList,
      bool isLoading}) {
    return AppState(
        priceByStock: priceByStock ?? {},
        stockList: stockList ?? [],
        isLoading: isLoading ?? false);
  }

  String getPriceOfStock(StockDto stock) {
    return ((priceByStock[stock] == null)
        ? "fetching"
        : priceByStock[stock].toString());
  }

  Color getPriceBackgroundColor(StockDto stock) {
    return (priceByStock[stock] ??
        0.0 - (double.parse(stock.actualSellPrice) ?? 0.0)) >
        0
        ? Colors.red[700]
        : Colors.green[600];
  }
}


