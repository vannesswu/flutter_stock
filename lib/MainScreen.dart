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

    return Container(
      margin: EdgeInsets.only(top: 60),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            brightness: Brightness.dark,
            centerTitle: false,
            title: Text(
              title,
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
            ),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                    color: Colors.grey[900], shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(Icons.tune),
                  onPressed: () {},
                  //color: Colors.black,
                ),
              )
            ],
          ),
          body: SafeArea(
              child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Colors.grey[900]))),
                padding: EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 12,
                      child: Text("股票代號",
                          style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                              letterSpacing: 0.01)),
                    ),
                    Expanded(
                      flex: 10,
                      child: Text("承銷價",
                          style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                              letterSpacing: 0.01)),
                    ),
                    Expanded(
                      flex: 10,
                      child: Text("參考市價",
                          style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                              letterSpacing: 0.01)),
                    ),
                    Expanded(
                      flex: 10,
                      child: Text("溢價差",
                          style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                              letterSpacing: 0.01)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: appState.stockList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return buildStockCard(appState.stockList[index]);
                  },
                ),
              ),
            ],
          ))),
    );
  }

  Widget buildStockCard(StockDto stock) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[900]))),
      margin: EdgeInsets.only(left: 15, right: 15),
      padding: EdgeInsets.only(top: 15, bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(flex: 12, child: _buildStockNameRowItem(stock)),
          Expanded(
            flex: 10,
            child: Text(
              stock.actualSellPrice,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 0.02,
                  fontWeight: FontWeight.w300),
            ),
          ),
          Expanded(
            flex: 10,
            child: Text(appState.getPriceOfStock(stock),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 0.02,
                    fontWeight: FontWeight.w300)),
          ),
          Expanded(
            flex: 10,
            child: Container(
              width: 68,
              height: 42,
              decoration: BoxDecoration(
                  color: appState.getPriceBackgroundColor(stock),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Center(
                child: Text((appState.getProfit(stock)),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        letterSpacing: 0.02,
                        fontWeight: FontWeight.w400)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStockNameRowItem(StockDto stock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          stock.number,
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 0.02,
              fontWeight: FontWeight.w500),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              stock.name,
              style: TextStyle(
                  color: Colors.grey[600], fontSize: 14, letterSpacing: 0.01),
            ),
            Container(
              margin: EdgeInsets.only(left: 5),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: stock.getStatusColor()),
            )
          ],
        )
      ],
    );
  }
}
