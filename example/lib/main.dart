import 'package:flutter/material.dart';

import 'package:candlesticks/gudashi/k_line.dart';
import 'package:candlesticks/candlesticks.dart';
import 'dataSource.dart';

List<dynamic> data = [];
List<CandleData> candleData = [];

void main() async {
//    candleData = await getCandleData();
    var minute = 1;
    //data = await DataSource.instance.initTZB(minute);
    data = await DataSource.instance.initTZB(minute);

    var count = 100;
    for (var i = data.length - count; i < data.length; i++) {
        var cd = CandleData.fromArray(data[i]['virgin'], 1000 * 60 * minute);
        candleData.add(cd);
    }

    runApp(new MyApp());
}

class MyApp extends StatefulWidget {
    @override
    _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
    @override
    void initState() {
        super.initState();
    }

    GlobalKey<KChartsState> kChartsKey = new GlobalKey<KChartsState>();

    @override
    Widget build(BuildContext context) {
        return new MaterialApp(
            home: new Scaffold(
                appBar: new AppBar(
                    title: const Text('Plugin example app'),
                ),
                body: Column(children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: CandlesticksWidget(
                            initData: candleData,
                            dataStream: DataSource.instance.subject.stream,
                        ),
                    ),
                    Expanded(
                        flex: 1,
                        child: KCharts(
                            key: kChartsKey,
                            data: data,
                        ),
                    ),
                ]
                ),
            ),
        );
    }
}
