// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stock/StockDto.dart';
import 'package:flutter_stock/StockService.dart';
import 'package:flutter_stock/appState.dart';

class StateContainer extends StatefulWidget {
  final AppState state;
  final StockService service;
  final Widget child;

  StateContainer(
      {@required this.child, this.service = const StockService(), this.state});

  static StateContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer)
        .data;
  }

  @override
  State<StatefulWidget> createState() {
    return StateContainerState();
  }
}

class StateContainerState extends State<StateContainer> {
  AppState state;

  @override
  void initState() {
    if (widget.state != null) {
      state = widget.state;
    } else {
      state = AppState.builder(isLoading: true);
    }

    getPurchasableStockList();

    super.initState();
  }

  void getPurchasableStockList() {
    StockService.instance.getPurchasableStockList().then((stockList) {
      setState(() {
        state.stockList = stockList..sort((aStock, bStock){
          var aStockStatus = aStock.getStockStatus();
          var bStockStatus = bStock.getStockStatus();

          return bStockStatus.index.compareTo(aStockStatus.index);
        });
        state.isLoading = false;
      });
      stockList.forEach(refreshStockPrice);
    }).catchError((err) {
      setState(() {
        state.isLoading = false;
      });
    });
  }

  void refreshStockPrice(StockDto stock) {
    Future.delayed(Duration(milliseconds: 50 * int.parse(stock.id))).then((it) {
      StockService.instance.getStockPrice(stock).then((price) {
        setState(() => state.priceByStock[stock] = price);
      });
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final StateContainerState data;

  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  // Note: we could get fancy here and compare whether the old AppState is
  // different than the current AppState. However, since we know this is the
  // root Widget, when we make changes we also know we want to rebuild Widgets
  // that depend on the StateContainer.
  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}
