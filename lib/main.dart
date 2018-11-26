import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stock/big5.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class StockDto {
  final String id;
  final String drawDate;
  final String name;
  final String number;
  final String market;
  final String purchaseStartDate;
  final String purchaseEndDate;
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
        obj[5] as String,
        obj[6] as String,
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
}

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
    convertedToString.removeRange(0, 1);
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
                var tt =
                    snapshot.data.map((stock) => buildCell(stock)).toList();
                return ListView(children: tt);
            }
            return null; // unreachable
          },
        ));
  }

  Widget buildCell(StockDto stock) {
    var isTitle = stock.name == '證券名稱';

    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, right: 15, left: 15),
            child: Row(
              children: <Widget>[
                Container(
                    color: isTitle ? Colors.deepOrangeAccent: Colors.greenAccent,
                    width: 100,
                    child: Center(child: Text(stock.name))),
                Text(stock.actualSellPrice),
              ],
            ),
          ),
          Row(),
          Row(),
        ],
      ),
    );
  }
}
