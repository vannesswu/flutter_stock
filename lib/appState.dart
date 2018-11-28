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
}
