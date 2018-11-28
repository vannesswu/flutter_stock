import 'dart:convert' as JSON;

import 'package:csv/csv.dart';
import 'package:flutter_stock/StockDto.dart';
import 'package:flutter_stock/big5.dart';
import 'package:http/http.dart' as http;

class StockService {
  static final instance = StockService();

  const StockService();

  final fetchPurchasableStockListUrl =
      'http://www.tse.com.tw/announcement/publicForm?response=csv&yy=2018';

  Future<List<StockDto>> getPurchasableStockList() async {
    final client = http.Client();

    final res = await client.get(fetchPurchasableStockListUrl);

    final responseBytes = res.bodyBytes.toList();
    final convertedByBig5 = big5.decode(responseBytes);

    final csvCodec = new CsvCodec();
    final convertedToString = csvCodec.decoder.convert(convertedByBig5);
    convertedToString.removeRange(0, 2);
    convertedToString.removeRange(
        convertedToString.length - 6, convertedToString.length);

    return StockDto.createStockList(convertedToString)
        .where((it) => it.market != '中央登錄公債')
        .toList();
  }

  final stockCurrentPriceUrl =
      'https://histock.tw/stock/module/stockdata.aspx?no=';

  Future<double> getStockPrice(StockDto stock) async {
    final client = http.Client();

    final res = await client.get(stockCurrentPriceUrl + stock.number);

    final data = JSON.jsonDecode(res.body)['data'] as String;
    final formattedData = data.substring(0,data.length -2) +"]";
    final array  = JSON.jsonDecode(formattedData) as List<dynamic>;
    final currentPrice = array.last[1] as num ?? 0.0;

    final fixedPrice = double.parse(currentPrice.toStringAsFixed(2)) ?? 0.0;

    return fixedPrice > 3000 ? 0.0 : fixedPrice;
  }
}
