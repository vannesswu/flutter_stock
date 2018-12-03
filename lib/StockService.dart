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
      'http://www.tse.com.tw/exchangeReport/STOCK_DAY';

  Future<List<double>> getStockDailyPrice(StockDto stock) async {
    final preYear = ((DateTime.now().month - 1) < 1)
        ? DateTime.now().year - 1
        : DateTime.now().year;
    
    final preMonth = ((DateTime.now().month - 1) < 1)
        ? 12
        : (DateTime.now().month - 1).toString().padLeft(2, '0');

    final previousYMD = '$preYear${preMonth}01';
    final currentYMD =
        '${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}01';

    final client = http.Client();

    final preQueryString = '?response=json&date=$previousYMD&stockNo=${stock.number}';
    final currentQueryString = '?response=json&date=$currentYMD&stockNo=${stock.number}';

    final preRes = client.get(stockDailyPriceUrl + preQueryString);
    final curRes = client.get(stockDailyPriceUrl + currentQueryString);

    final futures = await Future.wait([
      preRes,
      curRes
    ]);

    final preData = JSON.jsonDecode(futures[0].body)['data'] as List<dynamic>;
    final curData = JSON.jsonDecode(futures[1].body)['data'] as List<dynamic> ?? [];

    var preDailyPrice = preData.map((it)=> double.parse((it as List<dynamic>)[6])).toList();
    var curDailyPrice = curData.map((it)=> double.parse((it as List<dynamic>)[6])).toList();
    return (preDailyPrice + curDailyPrice).reversed.take(20).toList().reversed.toList();
  }
}
