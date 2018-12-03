import 'package:flutter/material.dart';

enum StockStatus { expired, notStart, selling }

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
  final String winningRate;

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
      this.amountQualified,
      this.winningRate);

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
        toBoardLot(obj[8] as String),
        obj[9] as String,
        obj[10] as String,
        obj[11] as String,
        obj[12] as String,
        toBoardLot(obj[13] as String),
        obj[14] as String,
        obj[15] as String,
        obj[16] as String,
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

  String get purchaseDateRange {
    return this.purchaseStartDate.month.toString() +
        '/' +
        this.purchaseStartDate.day.toString() +
        '-' +
        this.purchaseEndDate.month.toString() +
        '/' +
        this.purchaseEndDate.day.toString();
  }

  String get drawDateBC {
    return toDate(this.drawDate, false).year.toString() +
        '/' +
        toDate(this.drawDate, false).month.toString() +
        '/' +
        toDate(this.drawDate, false).day.toString();
  }

  static String toBoardLot(String lot) {
    final split = lot.split(",")..removeLast();
    return split.join(",");
  }

  String getROI(double currentPrice) {
    final actualSellPriceNumber = double.parse(actualSellPrice) ?? 0;
    return ((((currentPrice ?? 0) - actualSellPriceNumber) /
                    actualSellPriceNumber) *
                100)
            .toStringAsFixed(2) ??
        "-";
  }

  String convertNA(String content) {
    return content == "0" ? "N/A" : content;
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
        return Colors.amber[800];
      case StockStatus.expired:
        return Colors.grey[600];
      case StockStatus.selling:
        return Colors.blueAccent[400];
      default:
        return Colors.black;
    }
  }

  String getStatusString() {
    switch (this.getStockStatus()) {
      case StockStatus.notStart:
        return "未開始";
      case StockStatus.expired:
        return "已截止";
      case StockStatus.selling:
        return "可申購";
      default:
        return "未開始";
    }
  }
}
