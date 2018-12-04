import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_stock/StockDto.dart';
import 'package:flutter_stock/StockService.dart';
import 'package:flutter_stock/appState.dart';
import 'package:flutter_stock/state_container.dart';

class StockBottomSheet extends StatelessWidget {
  StockBottomSheet({Key key, this.stock}) : super(key: key);
  final StockDto stock;
  static var instance;
  final stockService = StockService.instance;
  static const aspect = "StockBottomSheet";
  AppState appState;

  StateContainerState container;

  factory StockBottomSheet.builder(StockDto stock) {
    if (StockBottomSheet.instance == null ||
        (StockBottomSheet.instance as StockBottomSheet).stock != stock) {
      StockBottomSheet.instance = StockBottomSheet(stock: stock);
      return StockBottomSheet.instance;
    } else {
      return StockBottomSheet.instance;
    }
  }

  @override
  Widget build(BuildContext context) {
    container = StateContainer.of(
        context, Aspect(name: StockBottomSheet.aspect, stockDto: stock));
    appState = container.state;
    return _buildBottomSheet(stock);
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
            _buildTrendRow(stock),
            Table(
              children: [
                TableRow(children: [
                  _buildBottomSheetTableCell(
                      title: '獲利',
                      content: appState.totalGain(stock),
                      style: TextStyle(
                          color: appState.getPriceBackgroundColor(stock),
                          fontSize: 24,
                          letterSpacing: 0.02,
                          fontWeight: FontWeight.w800),
                      topPadding: 0),
                  _buildBottomSheetTableCell(
                      title: '承銷價',
                      content: stock.actualSellPrice,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          letterSpacing: 0.02,
                          fontWeight: FontWeight.w800),
                      topPadding: 0),
                  _buildBottomSheetTableCell(
                      title: '市價',
                      content: appState.getPriceOfStock(stock),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          letterSpacing: 0.02,
                          fontWeight: FontWeight.w800),
                      topPadding: 0),
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
          fontWeight: FontWeight.w600),
      double topPadding = 20}) {
    return TableCell(
        child: Padding(
      padding: EdgeInsets.only(top: topPadding),
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

  Widget _buildTrendRow(StockDto stock) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "股價趨勢",
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    letterSpacing: 0.01,
                    fontWeight: FontWeight.normal),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: _buildTrendCharts(stock),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTrendCharts(StockDto stock) {
    return FutureBuilder(
        future: container.getStockDailyPrice(stock),
        builder: ((context, AsyncSnapshot<List<double>> priceList) {
          switch (priceList.connectionState) {
            case ConnectionState.active:
              return Text(
                'active',
                style: TextStyle(color: Colors.white),
              );
            case ConnectionState.waiting:
              return Text('waiting', style: TextStyle(color: Colors.white));
            case ConnectionState.none:
              return Text('none', style: TextStyle(color: Colors.white));
            case ConnectionState.done:
              var data = PriceOfDay.convertToPriceOfDay(priceList.data ?? [],
                  appState.getPriceBackgroundColor(stock));

              var series = [
                charts.Series(
                  id: 'test',
                  domainFn: (PriceOfDay dayPrice, _) => dayPrice.day,
                  measureFn: (PriceOfDay dayPrice, _) => dayPrice.price,
                  colorFn: (PriceOfDay dayPrice, _) => dayPrice.color,
                  data: data,
                )
              ];

              var chart = charts.LineChart(
                series,
                animate: true,
                primaryMeasureAxis: charts.NumericAxisSpec(
                  tickProviderSpec:
                      charts.BasicNumericTickProviderSpec(zeroBound: false),
                ),
                domainAxis: new charts.NumericAxisSpec(
                  showAxisLine: false,
                  renderSpec: new charts.NoneRenderSpec(),
                ),
              );

              return Container(height: 80, child: chart);
          }
        }));
  }
}

class PriceOfDay {
  final int day;
  final double price;
  final charts.Color color;
  static int counter = 0;

  PriceOfDay({this.day, this.price, Color color})
      : this.color = charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);

  factory PriceOfDay.builder(double price, Color color) {
    return PriceOfDay(day: counter++, price: price, color: color);
  }

  static List<PriceOfDay> convertToPriceOfDay(
      List<double> priceList, Color color) {
    var priceOfDayList =
        priceList.map((price) => PriceOfDay.builder(price, color)).toList();
    PriceOfDay.resetCounter();
    return priceOfDayList;
  }

  static void resetCounter() {
    counter = 0;
  }
}
