import 'package:web_socket_channel/io.dart';
import 'dart:async';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:candlesticks/candlesticks.dart';

class DataSource {

    static final DataSource instance = new DataSource
        ._internal();

    factory DataSource() {
        return instance;
    }

    final ReplaySubject<CandleData> subject = ReplaySubject<CandleData>();

    var channel;
    DataSource._internal();

    Future<List> initHuobi(int minute) async {
        var completer = new Completer<List>();
        var symbol = "ethusdt";
        var period = "${minute}min";
        var market = "market.$symbol.kline.$period";

        channel = await IOWebSocketChannel.connect(
            "wss://api.huobi.pro/ws");
        channel.sink.add(
            '{"sub":"${market}","id":"id11"}}');

        channel.stream.listen((request) {
            var msg = json.decode(utf8.decode(request));
            print(msg);
            if (msg['ch'] == market) {
                print(msg['data']);
                List dataK = [];
                msg['data'].forEach((item) {
                    var d = {};
                    try {
                        d['time'] = int.parse(item[0]);
                        d['open'] = double.parse(item[1]);
                        d['high'] = double.parse(item[2]);
                        d['low'] = double.parse(item[3]);
                        d['close'] = double.parse(item[4]);
                        d['volume'] = double.parse(item[5]);
                        d['virgin'] = item;
                    } catch (e) {
                        print(e);
                    }

                    dataK.add(d);
                    if(completer.isCompleted) {
                        subject.sink.add(CandleData.fromArray(item, 1000*60*minute));
                    }
                });
                if(!completer.isCompleted) {
                    completer.complete(dataK);
                }
//        kChartsKey.currentState.data = data;
//                print('pull_kline_graph');
//        kChartsKey.currentState.init();
//                channel.sink.close(5678, "raisin");
            }else if(msg['ping'] != null) {
                int now = DateTime.now().millisecond;
                channel.sink.add(
                    '{"pong":"${now}"}}');

            }
        });

        return completer.future;
    }
    Future<List> initTZB(int minute) async {
        var completer = new Completer<List>();
        var symbol = "eth_usdt";

        channel = await IOWebSocketChannel.connect(
            "wss://ws.tokenbinary.io/sub");
        /*
        channel.sink.add(
            '{"method":"pull_heart","data":{"time":"1541066934853"}}');
            */
        channel.sink.add(
            '{"method":"pull_gamble_user_market","data":{"market":"${symbol}","gamble":true}}');
        channel.sink.add(
            '{"method":"pull_gamble_kline_graph","data":{"market":"${symbol}","k_line_type":"${minute}","k_line_count":"500"}}');

        channel.stream.listen((request) {
            var msg = json.decode(utf8.decode(request));
            int now = DateTime.now().millisecond;
            channel.sink.add(
                '{"method":"pull_heart","data":{"time":"${now}"}}');
            if (msg['method'] == 'push_gamble_kline_graph') {
                print(msg['data']);
                List dataK = [];
                msg['data'].forEach((item) {
                    var d = {};
                    try {
                        d['time'] = int.parse(item[0]);
                        d['open'] = double.parse(item[1]);
                        d['high'] = double.parse(item[2]);
                        d['low'] = double.parse(item[3]);
                        d['close'] = double.parse(item[4]);
                        d['volume'] = double.parse(item[5]);
                        d['virgin'] = item;
                    } catch (e) {
                        print(e);
                    }

                    dataK.add(d);
                    if(completer.isCompleted) {
                        subject.sink.add(CandleData.fromArray(item, 1000*60*minute));
                    }
                });
                if(!completer.isCompleted) {
                    completer.complete(dataK);
                }
//        kChartsKey.currentState.data = data;
//                print('pull_kline_graph');
//        kChartsKey.currentState.init();
//                channel.sink.close(5678, "raisin");
            }
        });

        return completer.future;
    }

    Future<List> initRBTC(int minute) async {
        var completer = new Completer<List>();
        var symbol = "del_pyc";

        channel = await IOWebSocketChannel.connect(
            "wss://market-api.rbtc.io/sub");
        channel.sink.add(
            '{"method":"pull_heart","data":{"time":"1541066934853"}}');
        channel.sink.add(
            '{"method":"pull_user_market","data":{"market":"${symbol}"}}');
        channel.sink.add(
            '{"method":"pull_kline_graph","data":{"market":"${symbol}","k_line_type":"${minute}","k_line_count":"500"}}');

        channel.stream.listen((request) {
            var msg = json.decode(utf8.decode(request));
            if (msg['method'] == 'push_kline_graph') {
                print(msg['data']);
                List dataK = [];
                msg['data'].forEach((item) {
                    var d = {};
                    try {
                        d['time'] = int.parse(item[0]);
                        d['open'] = double.parse(item[1]);
                        d['high'] = double.parse(item[2]);
                        d['low'] = double.parse(item[3]);
                        d['close'] = double.parse(item[4]);
                        d['volume'] = double.parse(item[5]);
                        d['virgin'] = item;
                    } catch (e) {
                        print(e);
                    }

                    dataK.add(d);
                    if(completer.isCompleted) {
                        subject.sink.add(CandleData.fromArray(item, 1000*60*minute));
                    }
                });
                if(!completer.isCompleted) {
                    completer.complete(dataK);
                }
//        kChartsKey.currentState.data = data;
//                print('pull_kline_graph');
//        kChartsKey.currentState.init();
//                channel.sink.close(5678, "raisin");
            }
        });

        return completer.future;
    }
}
