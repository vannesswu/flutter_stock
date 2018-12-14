import 'package:flutter/material.dart';
import 'package:flutter_stock/PrefsService.dart';
import 'package:flutter_stock/StockDto.dart';
import 'package:intl/intl.dart';

class AppState {
  Map<StockDto, double> priceByStock;
  Map<StockDto, List<double>> dailyPriceByStock;
  List<StockDto> stockList;
  bool isLoading;
  UserSetting userSetting;

  AppState(
      {this.priceByStock = const {},
      this.dailyPriceByStock = const {},
      this.stockList = const [],
      this.isLoading = false,
      this.userSetting = const UserSetting()});

  factory AppState.builder(
      {Map<StockDto, double> priceByStock,
      List<StockDto> stockList,
      Map<StockDto, List<double>> dailyPriceByStock,
      bool isLoading,
      UserSetting userSetting}) {
    return AppState(
      priceByStock: priceByStock ?? {},
      stockList: stockList ?? [],
      dailyPriceByStock: dailyPriceByStock ?? {},
      isLoading: isLoading ?? false,
      userSetting: userSetting ?? const UserSetting(),
    );
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

  List<StockDto> get filterStockList {
    var list = List<StockDto>.from(stockList);

    if ((userSetting.isHiddenExpireStock ?? false)) {
      list = list.where((stock) {
        return stock.getStockStatus() != StockStatus.expired;
      }).toList();
    }

    if (userSetting.sellingPriceLessThan != null) {
      list = list.where((stock) {
        return double.parse(stock.actualSellPrice) <
            userSetting.sellingPriceLessThan;
      }).toList();
    }

    if (userSetting.profitGreatThan != null) {
      list = list.where((stock) {
        final profit = getProfit(stock);

        if (profit == "-") {
          return false;
        } else {
          return double.parse(profit) > userSetting.profitGreatThan;
        }
      }).toList();
    }
    return list;
  }
}
