import 'package:flutter/material.dart';
import 'package:flutter_stock/MainScreen.dart';
import 'package:flutter_stock/customTheme.dart';
import 'package:flutter_stock/state_container.dart';

void main() {
  runApp(StateContainer(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '股票申購',
      theme: ThemeData(
        primarySwatch: CustomTheme.black,
      ),
      home: MainScreen(title: '股票申購'),
    );
  }
}
