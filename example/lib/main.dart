import 'package:flutter/material.dart';

import 'package:candlesticks/candlesticks.dart';
import 'dataSource.dart';

const minute = 1;

void main() async {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

CandlesticksStyle DefaultCandleStyle = DefaultDarkCandleStyle;

class _MyAppState extends State<MyApp> {
  int count = 0;

  @override
  void initState() {
    super.initState();
    dataStreamFuture = DataSource.instance.initTZB(1);
    style = DefaultCandleStyle;
  }

  Future<Stream<CandleData>> dataStreamFuture;
  CandlesticksStyle style;

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
              child: Row(children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    count++;
                    if (count % 4 == 0) {
                     // dataStreamFuture = DataSource.instance.initTZB(1);
                      //print('切换K线 1');
                    }
                    if (count % 4 == 1) {
                      //dataStreamFuture = DataSource.instance.initTZB(5);
                      //print('切换K线 5');
                    } else if (count % 4 == 2) {
//                      dataStreamFuture = DataSource.instance.initTZB(5);
                      print('切换颜色 红绿');
                      style = DefaultCandleStyle;
                    } else if (count % 4 == 3) {
//                      dataStreamFuture = DataSource.instance.initTZB(5);
                      print('切换颜色 绿红');
                      DefaultCandleStyle.maStyle.shortColor = Colors.white;
                      style = DefaultCandleStyle;
                    }
                    setState(() {

                    });
                  },
                )
              ])),
          Expanded(
            flex: 10,
            child: FutureBuilder<Stream<CandleData>>(
                future: dataStreamFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<Stream<CandleData>> snapshot) {
                  if ((snapshot.connectionState != ConnectionState.done) ||
                      (!snapshot.hasData) || (snapshot.data == null)) {
                    return Container();
                  }
                  return CandlesticksWidget(
                    dataStream: snapshot.data,
                    candlesticksStyle:style,
                  );
                }),
          ),
          /*
                    Expanded(
                        flex: 1,
                        child: KCharts(
                            key: kChartsKey,
                            data: data,
                        ),
                    ),
                    */
        ]
        ),)
      ,
    );
  }
}
