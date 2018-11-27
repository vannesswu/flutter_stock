import 'dart:convert' as JSON;

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stock/big5.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<StockDto>> _getStockList() async {
    var url =
        'http://www.tse.com.tw/announcement/publicForm?response=csv&yy=2018';

    var client = http.Client();

    var res = await client.get(url);

    var responseBytes = res.bodyBytes.toList();
    var convertedByBig5 = big5.decode(responseBytes);

    final csvCodec = new CsvCodec();
    var convertedToString = csvCodec.decoder.convert(convertedByBig5);
    convertedToString.removeRange(0, 2);
    convertedToString.removeRange(
        convertedToString.length - 6, convertedToString.length);

    return StockDto.createStockList(convertedToString)
        .where((it) => it.market != '中央登錄公債')
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _getStockList().then((stockList) {
      return stockList.map((stock) => Text(stock.name));
    });
    // Ads.init('ca-app-pub-3940256099942544', testing: true);
    // Ads.showBannerAd(state: this);
    //Ads.showFullScreenAd(this);
    //Ads.showVideoAd(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FutureBuilder(
          future: _getStockList(),
          builder:
              (BuildContext context, AsyncSnapshot<List<StockDto>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('Press button to start.');
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Text('Awaiting result...');
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                var cells =
                    snapshot.data.map((stock) => buildCell(stock)).toList();
                return SafeArea(child: ListView(children: cells));
            }
            return null; // unreachable
          },
        ));
  }

  Widget buildCell(StockDto stock) {
    return Container(
        height: 100,
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: ListTile(
          leading: Container(
              decoration: BoxDecoration(
                  color: stock.getStatusColor(), shape: BoxShape.circle),
              width: 80,
              height: 80,
              child: Center(child: Text(stock.name))),
          title:
              Text("承銷價 " + stock.actualSellPrice, textAlign: TextAlign.left),
          trailing: FutureBuilder(
              future: Future.delayed(
                      Duration(milliseconds: int.parse(stock.id) * 50))
                  .then((_) => stock.getProfit()),
              builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return Text('fetching...', textAlign: TextAlign.left);
                  case ConnectionState.done:
                    return Container(
                      decoration: BoxDecoration(
                          color: snapshot.data > 0
                              ? Colors.redAccent
                              : Colors.greenAccent),
                      width: 70,
                      child: Text(
                        '價差 ' +
                            (snapshot.data == 0.0
                                ? '-'
                                : snapshot.data.toString()),
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                }
              }),
        ));
  }
}

class StockDto {
  final String id;
  final String drawDate;
  final String name;
  final String number;
  final String market;
  final DateTime purchaseStartDate;
  final DateTime purchaseEndDate;
  final String amountStock;
  final String actualAmountStock;
  final String sellPrice;
  final String actualSellPrice;
  final String deliverDate;
  final String broker;
  final String canBuyNumber;
  final String amountPrice;
  final String amountQualified;

  StockDto(
      this.id,
      this.drawDate,
      this.name,
      this.number,
      this.market,
      this.purchaseStartDate,
      this.purchaseEndDate,
      this.amountStock,
      this.actualAmountStock,
      this.sellPrice,
      this.actualSellPrice,
      this.deliverDate,
      this.broker,
      this.canBuyNumber,
      this.amountPrice,
      this.amountQualified);

  static List<StockDto> createStockList(List<List<dynamic>> list) {
    return list.map((obj) {
      return StockDto(
        obj[0] as String,
        obj[1] as String,
        obj[2] as String,
        obj[3] as String,
        obj[4] as String,
        toDate(obj[5], false),
        toDate(obj[6], true),
        obj[7] as String,
        obj[8] as String,
        obj[9] as String,
        obj[10] as String,
        obj[11] as String,
        obj[12] as String,
        obj[13] as String,
        obj[14] as String,
        obj[15] as String,
      );
    }).toList();
  }

  static DateTime toDate(String str, bool isEndDate) {
    var splitDate = str.split('/');
    var year = int.parse(splitDate[0]) + 1911;
    var ymd = year.toString() +
        splitDate[1] +
        splitDate[2] +
        (isEndDate ? 'T235959' : '');
    return DateTime.parse(ymd);
  }

  StockStatus getStockStatus() {
    if (this.purchaseStartDate.isAfter(DateTime.now())) {
      return StockStatus.notStart;
    }
    if (this.purchaseEndDate.isAfter(DateTime.now()) &&
        this.purchaseStartDate.isBefore(DateTime.now())) {
      return StockStatus.selling;
    }
    return StockStatus.expired;
  }

  Color getStatusColor() {
    switch (this.getStockStatus()) {
      case StockStatus.notStart:
        return Colors.greenAccent;
      case StockStatus.expired:
        return Colors.grey;
      case StockStatus.selling:
        return Colors.deepOrangeAccent;
      default:
        return Colors.black;
    }
  }

  Future<double> getProfit() async {
    var stockCurrentPriceUrl =
        'https://histock.tw/stock/module/stockdata.aspx?no=' + this.number;

    var client = http.Client();

    var res = await client.get(stockCurrentPriceUrl);

    var data = JSON.jsonDecode(res.body)['data'] as String;

    RegExp regExp = new RegExp(
      r",[0-9]+[.0-9]*",
      caseSensitive: false,
      multiLine: false,
    );

    var tt = regExp.allMatches(data).toList().last.group(0).replaceAll(',', '');
    var currentPrice = double.parse(tt);
    var profit = currentPrice - double.parse(this.actualSellPrice);

    if (profit > 1000) {
      return Future.value(0.0);
    }
    return Future.value(double.parse(profit.toStringAsFixed(2)) ?? 0.0);
  }
}

enum StockStatus { notStart, selling, expired }
