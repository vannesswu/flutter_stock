import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stock/PrefsService.dart';
import 'package:flutter_stock/appState.dart';
import 'package:flutter_stock/state_container.dart';

class SettingScreen extends StatelessWidget {
  AppState appState;
  StateContainerState container;
  static const aspect = "SettingScreen";
  TextEditingController _sellPriceTextEditingController;
  TextEditingController _profitTextEditingController;

  @override
  Widget build(BuildContext context) {
    container = StateContainer.of(context, Aspect(name: SettingScreen.aspect));
    appState = container.state;
    _sellPriceTextEditingController = TextEditingController(
        text: appState.userSetting.sellingPriceLessThan == null
            ? ""
            : appState.userSetting.sellingPriceLessThan.toString());
    _profitTextEditingController = TextEditingController(
        text: appState.userSetting.profitGreatThan == null
            ? ""
            : appState.userSetting.profitGreatThan.toString());

    ExpireStockSwitch expireStockSwitch = new ExpireStockSwitch(
        onValueChange, appState.userSetting.isHiddenExpireStock ?? false);
    print(appState.userSetting.isHiddenExpireStock);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color(0xFF141414),
        title: Text(
          '設定',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: <Widget>[
          Container(
            child: FlatButton(
                onPressed: () => _resetUserSetting(expireStockSwitch),
                child: Text(
                  '重置',
                  style: TextStyle(color: Colors.red[800], fontSize: 18),
                )),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(left: 15, right: 15, top: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Text(
                '篩選條件',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
            Divider(height: 2, color: Colors.grey[900]),
            ListTile(
              contentPadding: EdgeInsets.only(top: 21, bottom: 21),
              title: Text('承銷價小於',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[400])),
              trailing: Container(
                width: 60,
                child: TextField(
                  keyboardType: TextInputType.numberWithOptions(),
                  decoration: InputDecoration(
                      hintText: "未設定",
                      hintStyle:
                          TextStyle(fontSize: 16, color: Colors.grey[600])),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[400]),
                  controller: _sellPriceTextEditingController,
                ),
              ),
            ),
            Divider(height: 2, color: Colors.grey[900]),
            ListTile(
              contentPadding: EdgeInsets.only(top: 21, bottom: 21),
              title: Text('獲利大於',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[400])),
              trailing: Container(
                width: 60,
                child: TextField(
                  keyboardType: TextInputType.numberWithOptions(),
                  decoration: InputDecoration(
                      hintText: "未設定",
                      hintStyle:
                          TextStyle(fontSize: 16, color: Colors.grey[600])),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[400]),
                  controller: _profitTextEditingController,
                ),
              ),
            ),
            Divider(height: 2, color: Colors.grey[900]),
            ListTile(
              contentPadding: EdgeInsets.only(top: 21, bottom: 21),
              title: Text('隱藏截止申購',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[400])),
              trailing: Container(
                width: 60,
                child: expireStockSwitch,
              ),
            ),
            Expanded(
              child: Container(),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 50),
              height: 52,
              decoration: BoxDecoration(
                  color: Color(0xFF141414),
                  borderRadius: BorderRadius.circular(10)),
              child: FlatButton(
                  onPressed: () {
                    PrefsService.instance
                        .setUserSetting(
                      sellingPriceLessThan:
                          double.tryParse(_sellPriceTextEditingController.text),
                      profitGreatThan:
                          double.tryParse(_profitTextEditingController.text),
                      isHiddenExpireStock: appState.userSetting.isHiddenExpireStock,
                    ).then((it) {
                      return container.getUserSetting();
                    }).then((it) {
                       Navigator.pop(context);
                    });
                  },
                  child: Center(
                    child: Text(
                      '儲存設定',
                      style: TextStyle(
                        color: Colors.amber[800],
                        fontSize: 18,
                      ),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
  _resetUserSetting(ExpireStockSwitch eSwitch){
    eSwitch.setValue(false);
    container.resetUserSetting();
  }
  onValueChange(bool isHidden) {
    print(isHidden);
    container.setSwitch(isHidden);
  }
}

class ExpireStockSwitch extends StatelessWidget {
  final ValueChanged<bool> onChanged;
  bool _isHiddenExpireStock;
  ExpireStockSwitch(this.onChanged, this._isHiddenExpireStock);
  
  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
        value: _isHiddenExpireStock,
        onChanged: (isHidden) {
          setValue(isHidden);
        });
  }
  void setValue(bool value) {
      _isHiddenExpireStock = value;
      onChanged(value);
    }
  }
