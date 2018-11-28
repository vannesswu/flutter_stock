import 'package:flutter/material.dart';
import 'package:flutter_stock/StockDto.dart';
import 'package:flutter_stock/StockService.dart';
import 'package:flutter_stock/appState.dart';
import 'package:flutter_stock/state_container.dart';

class MainScreen extends StatelessWidget {
  MainScreen({Key key, this.title}) : super(key: key);
  final String title;
  final stockService = StockService.instance;
  AppState appState;

  @override
  Widget build(BuildContext context) {
    appState = StateContainer.of(context).state;
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: SafeArea(
            child: ListView(
                children: appState.stockList
                    .map((stock) => buildCell(stock))
                    .toList())));
  }

  Widget buildCell(StockDto stock) {
    return Container(
        height: 100,
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: Container(
            child: ListTile(
                leading: Container(
                    decoration: BoxDecoration(
                        color: stock.getStatusColor(), shape: BoxShape.circle),
                    width: 80,
                    height: 80,
                    child: Center(child: Text(stock.name))),
                title: Text("承銷價 " + stock.actualSellPrice,
                    textAlign: TextAlign.left),
                subtitle: Text(
                    "現價 " + ((appState.priceByStock[stock] == null)
                        ? "fetching"
                        : appState.priceByStock[stock].toString()),
                    textAlign: TextAlign.left),
                trailing: Container(
                  decoration: BoxDecoration(
                      color: (appState.priceByStock[stock] ??
                                  0.0 -
                                      (double.parse(stock.actualSellPrice) ??
                                          0.0)) >
                              0
                          ? Colors.redAccent
                          : Colors.greenAccent),
                  width: 80,
                  height: 30,
                  child: Center(
                    child: Text(
                      '價差 ' +
                          (appState.priceByStock[stock] == 0.0
                              ? '-'
                              : ((appState.priceByStock[stock] ?? 0.0) -
                                      double.parse(stock.actualSellPrice))
                                  .toStringAsFixed(2)),
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ))));
  }
}
