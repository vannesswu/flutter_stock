import 'dart:convert' as JSON;

import 'package:flutter_stock/StockDto.dart';
import 'package:http/http.dart' as http;

class StockService {
  static final instance = StockService();

  const StockService();

  final fetchPurchasableStockListUrl =
      'http://www.tse.com.tw/announcement/publicForm?response=json';

  Future<List<StockDto>> getPurchasableStockList() async {
    final client = http.Client();

    final res = await client.get(fetchPurchasableStockListUrl);

    final data = JSON.jsonDecode(res.body)['data'] as List<dynamic>;
    final formattedData = data.map((it) {
      return it as List<dynamic>;
    }).toList();

    return StockDto.createStockList(formattedData)
        .where((it) => it.market != '中央登錄公債')
        .toList();
  }

  final stockCurrentPriceUrl =
      'https://histock.tw/stock/module/stockdata.aspx?no=';

  Future<double> getStockPrice(StockDto stock) async {
    final client = http.Client();

    final res = await client.get(stockCurrentPriceUrl + stock.number);

    final data = JSON.jsonDecode(res.body)['data'] as String;
    final formattedData = data.substring(0, data.length - 2) + "]";
    final array = JSON.jsonDecode(formattedData) as List<dynamic>;
    final currentPrice = array.last[1] as num ?? 0.0;

    final fixedPrice = double.parse(currentPrice.toStringAsFixed(2)) ?? 0.0;

    return fixedPrice > 3000 ? 0.0 : fixedPrice;
  }

  final stockDailyPriceUrl =
      'http://www.tse.com.tw/exchangeReport/STOCK_DAY_AVG';

  Future<List<double>> getStockDailyPrice(StockDto stock) async {
    var date = DateTime.now();
    final preYear = ((date.month - 1) < 1) ? date.year - 1 : date.year;

    final preMonth = ((date.month - 1) < 1)
        ? 12
        : (date.month - 1).toString().padLeft(2, '0');

    final previousYMD = '$preYear${preMonth}01';
    final currentYMD = '${date.year}${date.month.toString().padLeft(2, '0')}01';

    final preQueryString =
        '?response=json&date=$previousYMD&stockNo=${stock.number}&_=${date.millisecondsSinceEpoch}';
    final currentQueryString =
        '?response=json&date=$currentYMD&stockNo=${stock.number}&_=${date.millisecondsSinceEpoch}';

    final preMonthPriceList = await _getStockMonthPriceList(preQueryString);
    await Future.delayed(Duration(milliseconds: 200));
    final curMonthPriceList = await _getStockMonthPriceList(currentQueryString);

    return (preMonthPriceList + curMonthPriceList)
        .reversed
        .take(20)
        .toList()
        .reversed
        .toList();
  }

  Future<List<double>> _getStockMonthPriceList(String query) async {
    final client = http.Client();

    final response = await client.get(stockDailyPriceUrl + query);

    final data = JSON.jsonDecode(response.body)['data'] as List<dynamic> ?? [];

    var dailyPrice = data
        .map((it) => double.parse((it as List<dynamic>)[1]))
        .toList()
          ..removeLast();

    return dailyPrice;
  }
}
