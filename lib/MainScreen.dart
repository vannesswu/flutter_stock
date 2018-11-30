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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    appState = StateContainer.of(context).state;

    return Container(
      margin: EdgeInsets.only(top: 60),
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
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
                    _buildTitleFieldWidget(flex: 12, title: "股票代號"),
                    _buildTitleFieldWidget(title: "承銷價"),
                    _buildTitleFieldWidget(title: "參考市價"),
                    _buildTitleFieldWidget(title: "溢價差"),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: appState.stockList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildStockCard(appState.stockList[index]);
                  },
                ),
              ),
            ],
          ))),
    );
  }

  Widget _buildTitleFieldWidget({int flex = 10, String title}) {
    return Expanded(
      flex: flex,
      child: Text(title,
          style: TextStyle(
              color: Colors.grey[400], fontSize: 13, letterSpacing: 0.01)),
    );
  }

  Widget _buildStockCard(StockDto stock) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            context: _scaffoldKey.currentState.context,
            builder: (builder) {
              return _buildBottomSheet(stock);
            });
      },
      child: Container(
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
      ),
    );
  }

  Widget _buildBottomSheet(StockDto stock) {
    return Container(
      color: Color(0xff191919),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: <Widget>[
            _buildIndicator(),
            _buildBottomSheetStockBar(stock),
            Table(
              children: [
                TableRow(children: [
                  _buildBottomSheetTableCell(
                      title: '溢價差',
                      content: appState.getProfit(stock),
                      style: TextStyle(
                          color: appState.getPriceBackgroundColor(stock),
                          fontSize: 24,
                          letterSpacing: 0.02,
                          fontWeight: FontWeight.w800)),
                  _buildBottomSheetTableCell(
                      title: '承銷價',
                      content: stock.actualSellPrice,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          letterSpacing: 0.02,
                          fontWeight: FontWeight.w800)),
                  _buildBottomSheetTableCell(
                      title: '市價',
                      content: appState.getPriceOfStock(stock),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          letterSpacing: 0.02,
                          fontWeight: FontWeight.w800)),
                ]),
                TableRow(children: [
                  _buildBottomSheetTableCell(
                      title: '發行市場', content: stock.market),
                  _buildBottomSheetTableCell(
                      title: '申購期間', content: stock.purchaseDateRange),
                  _buildBottomSheetTableCell(
                      title: '抽籤日', content: stock.drawDateBC),
                ]),
                TableRow(children: [
                  _buildBottomSheetTableCell(
                      title: '報酬率(%)',
                      content: stock.getROI(appState.priceByStock[stock])),
                  _buildBottomSheetTableCell(
                      title: '撥券日', content: stock.deliverDate),
                  _buildBottomSheetTableCell(
                      title: '申購張數', content: stock.canBuyNumber),
                ]),
                TableRow(children: [
                  _buildBottomSheetTableCell(
                      title: '承銷張數', content: stock.actualAmountStock),
                  _buildBottomSheetTableCell(
                      title: '總合格件',
                      content: stock.convertNA(stock.amountQualified)),
                  _buildBottomSheetTableCell(
                      title: '中籤率(%)',
                      content: stock.convertNA(stock.winningRate)),
                ])
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableCell _buildBottomSheetTableCell(
      {String title,
      String content,
      TextStyle style = const TextStyle(
          color: Colors.white,
          fontSize: 18,
          letterSpacing: 0.02,
          fontWeight: FontWeight.w600)}) {
    return TableCell(
        child: Padding(
      padding: const EdgeInsets.only(top: 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                letterSpacing: 0.01,
                fontWeight: FontWeight.normal),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(content, style: style),
          ),
        ],
      ),
    ));
  }

  Container _buildBottomSheetStockBar(StockDto stock) {
    return Container(
      padding: EdgeInsets.only(top: 21, bottom: 13),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[900]))),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
        title: Text(
          stock.number,
          style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.03),
        ),
        subtitle: Text(stock.name,
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.normal,
                letterSpacing: 0.01)),
        trailing: Container(
            padding: EdgeInsets.fromLTRB(21, 12, 21, 12),
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: stock.getStatusColor())),
            child: Text(stock.getStatusString(),
                style: TextStyle(
                    color: stock.getStatusColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0.02))),
      ),
    );
  }

  Container _buildIndicator() {
    return Container(
      margin: EdgeInsets.only(top: 18),
      height: 6,
      width: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.grey[700],
          shape: BoxShape.rectangle),
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
