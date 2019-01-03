import 'package:candlesticks/gudashi/k_base.dart';
import 'package:flutter/material.dart';
import 'dart:math';

abstract class PlotAbstract {
  String name;

  String type = 'line';

  List list;

  List<String> nameList = [];

  void setPlot (List data){}

  List<Color> plotColor = [Colors.amber, Colors.lightGreen, Colors.purple];

  void arithmetic (List data, num){}

  Widget text (Map data, KPoint kPoint){
    return new Row(children: <Widget>[],);
  }

  void showPlot (List data){}

}

class Ma extends PlotAbstract{

  @override
  // TODO: implement name
  String get name => 'ma';

  @override
  // TODO: implement list
  List<int> get list => [5, 10, 30];

  /// 是否加权
  bool maWeighted = false;

  @override
  // TODO: implement plotColor
  List<Color> get plotColor => super.plotColor;

  @override
  void setPlot(List data) {
    // TODO: implement setMa
    nameList = [];
    this.list.forEach((num){
      nameList.add(name + num.toString());
      this.arithmetic(data, num);
    });
  }

  @override
  void arithmetic(List data, num) {
    // TODO: implement arithmetic
    if(data.length <= num) return;
    String maNumName = 'ma' + num.toString();
    for(int i = num; i < data.length; i++){
      double mean = 0.0;
      for(int n = i - num; n < i; n++){
        mean += data[n]['close'];
      }
      data[i][maNumName] = mean / num;
    }
  }

  Widget text (Map data, KPoint kPoint){
    List<Widget> maText = [];
    for(int i = 0; i < nameList.length; i++){
      maText.add(new Text('${nameList[i].toUpperCase()}:${data[nameList[i]].toStringAsFixed(kPoint.priceFixed)}', style: new TextStyle(color: plotColor[i], fontSize: 8.0,),));
      maText.add(new Padding(padding: EdgeInsets.symmetric(horizontal: 8.0)));
    }
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: maText,
    );
  }

  @override
  void showPlot (List data){
    for(int i = 0; i < data.length; i++){
      data[i]['highPrice'] = data[i]['high'];
      data[i]['lowPrice'] = data[i]['low'];
    }
  }
}

class Boll extends PlotAbstract{

  @override
  // TODO: implement name
  String get name => 'boll';

  @override
  // TODO: implement list
  List<String> get list => ['mb', 'up', 'dn'];

  /// boll 范围
  int bollN = 20;

  /// boll 参数
  int k = 2;

  @override
  // TODO: implement plotColor
  List<Color> get plotColor => [Colors.white, Colors.amber, Colors.lightBlue];

  @override
  void setPlot(List data) {
    // TODO: implement setMa
    nameList = [];
    this.list.forEach((num){
      nameList.add(num.toString());
    });
    this.arithmetic(data, null);
  }

  @override
  void arithmetic(List data, bollName) {
    // TODO: implement arithmetic
    if(data.length <= 0) return;
    for(int i = bollN; i < data.length; i++){
      double mean = 0.0;
      for(int n = i - bollN; n < (i - 1); n++){
        mean += data[n]['close'];
      }
      double mb = mean / (bollN - 1);
      data[i]['mb'] = mean / (bollN - 1);

      double md = 0.0;
      for(int d = i - bollN; d < (i - 1); d++){
        md += pow((data[d]['close'] - mb), 2);
      }
      md = sqrt(md / (bollN - 1));
      data[i]['md'] = md;
      data[i]['up'] = data[i]['mb'] + k * md;
      data[i]['dn'] = data[i]['mb'] - k * md;
    }
  }

  @override
  void showPlot (List data){
    for(int i = 0; i < data.length; i++){
      if(data[i]['up'] is double){
        data[i]['highPrice'] = data[i]['up'] > data[i]['highPrice'] ? data[i]['up'] : data[i]['highPrice'];
      }
      if(data[i]['dn'] is double){
        data[i]['lowPrice'] = data[i]['dn'] < data[i]['lowPrice'] ? data[i]['dn'] : data[i]['lowPrice'];
      }
    }
  }
}

class Macd extends PlotAbstract{
  @override
  // TODO: implement name
  String get name => 'MACD';

  @override
  // TODO: implement list
  List get list => ['macd', 'dif', 'dea'];
  List get listType => ['pillar', 'line', 'line'];

  @override
  // TODO: implement plotColor
  List<Color> get plotColor => super.plotColor;

  @override
  void setPlot(List data) {
    // TODO: implement setMa
    nameList = [];
    this.list.forEach((num){
      nameList.add(num.toString());
    });
    this.arithmetic(data, null);
  }

  int short = 11;
  int long = 25;
  String price = 'close';
  int m = 8;

  @override
  void arithmetic(List data, num) {
    // TODO: implement arithmetic
    if(data.length <= long) return;

    double shortA = 2 / (short + 2);
    double longA = 2 / (long + 2);
    double mA = 2 / (m + 2);

    String shortName = 'ema' + (short + 1).toString();
    String longName = 'ema' + (long + 1).toString();

    for(int i = short; i < data.length; i++){
      if(data[i - 1][shortName] is double){
        data[i][shortName] = data[i - 1][shortName] *  (1 - shortA) + data[i][price] * shortA;
      }else{
        double p1 = 0;
        for(int ema1 = i - short; ema1 <= i; ema1++){
          p1 += data[ema1][price];
        }
        data[i][shortName] = p1 / (short + 1);
      }
      if(i >= long){
        if(data[i - 1][longName] is double){
          data[i][longName] = data[i - 1][longName] * (1 - longA) + data[i][price] * longA;
        }else{
          double p2 = 0;
          for(int ema2 = i - long; ema2 <= i; ema2++){
            p2 += data[ema2][price];
          }
          data[i][longName] = p2 / (long + 1);
        }
        data[i]['dif'] = data[i][shortName] - data[i][longName];
      }
      if(i >= long + m && data[i]['dif'] is double){
        if(data[i - 1]['dea'] is double){
          data[i]['dea'] = data[i - 1]['dea'] * (1 - mA) + data[i]['dif'] * mA;
        }else{
          double dea = 0;
          for(int d = i - m; d <= i; d++){
            dea += data[d]['dif'];
          }
          data[i]['dea'] = dea / (m + 1);
        }
        data[i]['macd'] = data[i]['dif'] - data[i]['dea'];
      }
    }
  }

  @override
  Widget text(Map data, KPoint kPoint) {
    // TODO: implement text
    return super.text(data, kPoint);
  }

  @override
  void showPlot(List data) {
    // TODO: implement showPlot
    super.showPlot(data);
  }

}


class KPlot {
  KPlot();

  int mainActive = 0;
  int viceActive = 0;

  List<PlotAbstract> mainPlot = [new Ma(), new Boll()];
  List<PlotAbstract> vicePlot = [new Macd()];

  void setPlot (List data){
    mainActive = 0;
    mainPlot.forEach((PlotAbstract plot){
      plot.setPlot(data);
    });
    vicePlot.forEach((PlotAbstract plot){
      plot.setPlot(data);
    });
  }

  showMainPlot (List data, String name){
    for(int i = 0; i < mainPlot.length; i++){
      if(mainPlot[i].name == name){
        mainActive = i;
        mainPlot[i].showPlot(data);
        break;
      }
    }
    throw("$name 不存在 ${getMainNameList.toString()}");
  }

  showVicePlot (List data, String name){
    for(int i = 0; i < vicePlot.length; i++){
      if(vicePlot[i].name == name){
        viceActive = i;
        vicePlot[i].showPlot(data);
        break;
      }
    }
    throw("$name 不存在 ${getMainNameList.toString()}");
  }

  PlotAbstract get getMainPlot {
    return mainPlot[mainActive];
  }
  PlotAbstract get getVicePlot {
    return vicePlot[viceActive];
  }

  List<String> get getMainNameList {
    return mainActive >= 0 ? mainPlot[mainActive].nameList : [];
  }
  List<String> get getViceNameList {
    return viceActive >= 0 ? vicePlot[viceActive].nameList : [];
  }

  List<Color> get getMainColorList {
    return mainActive >= 0 ? mainPlot[mainActive].plotColor : [];
  }
  List<Color> get getViceColorList {
    return viceActive >= 0 ? vicePlot[viceActive].plotColor : [];
  }
}

