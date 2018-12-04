import 'package:flutter/material.dart';
import 'package:flutter_stock/StockDto.dart';
import 'package:intl/intl.dart';

class AppState {
  Map<StockDto, double> priceByStock;
  Map<StockDto, List<double>> dailyPriceByStock;
  List<StockDto> stockList;
  bool isLoading;

  AppState({
    this.priceByStock = const {},
    this.dailyPriceByStock = const {},
    this.stockList = const [],
    this.isLoading = false,
  });

  factory AppState.builder(
      {Map<StockDto, double> priceByStock,
      List<StockDto> stockList,
      Map<StockDto, List<double>> dailyPriceByStock,
      bool isLoading}) {
    return AppState(
        priceByStock: priceByStock ?? {},
        stockList: stockList ?? [],
        dailyPriceByStock: dailyPriceByStock ?? {},
        isLoading: isLoading ?? false);
  }

  String getPriceOfStock(StockDto stock) {
    return ((priceByStock[stock] == null || priceByStock[stock] == 0)
        ? "-"
        : priceByStock[stock].toString());
  }

  String getProfit(StockDto stock) {
    var price = getPriceOfStock(stock);

    return price == "-"
        ? price
        : (double.parse(price) - double.parse(stock.actualSellPrice))
            .toStringAsFixed(2);
  }

  String totalGain(StockDto stock) {
    var price = getPriceOfStock(stock);
    final formatter = NumberFormat("#,###");
    return price == "-"
        ? price
        : formatter.format(
            (double.parse(price) - double.parse(stock.actualSellPrice)) *
                double.parse(stock.canBuyNumber) *
                1000);
  }

  Color getPriceBackgroundColor(StockDto stock) {
    return (((priceByStock[stock] ?? 0.0) -
                (double.parse(stock.actualSellPrice) ?? 0.0)) >
            0)
        ? Colors.red[700]
        : Colors.green[600];
  }
}
