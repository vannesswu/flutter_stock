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
}
