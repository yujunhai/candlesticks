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

  ReplaySubject<CandleData> subject;

  var channel;

  DataSource._internal();

  Future<Stream<CandleData>> initTZB(int minute) async {
    if(subject != null) {
      subject.close();
      subject = null;
    }
    subject = ReplaySubject<CandleData>();
    var symbol = "eth_usdt";
    if(channel != null) {
      channel.sink.close();
      channel = null;
    }

    channel = IOWebSocketChannel.connect(
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
      int now = DateTime
          .now()
          .millisecond;
      channel.sink.add(
          '{"method":"pull_heart","data":{"time":"${now}"}}');
      if (msg['method'] == 'push_gamble_kline_graph') {
        //print(msg['data']);
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
            //print(e);
          }

          subject.sink.add(CandleData.fromArray(item));
        });
      }
    });
    return subject.stream;
  }

  Future<Stream<CandleData>> initRBTC(int minute) async {
    if(subject != null) {
      subject.close();
    }
    subject = ReplaySubject<CandleData>();

    var symbol = "eth_usdt";

    channel = IOWebSocketChannel.connect(
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
        //print(msg['data']);
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
            //print(e);
          }

          dataK.add(d);
          subject.sink.add(CandleData.fromArray(item));
        });
//        kChartsKey.currentState.data = data;
//                print('pull_kline_graph');
//        kChartsKey.currentState.init();
//                channel.sink.close(5678, "raisin");
      }
    });
    return subject.stream;
  }
}
