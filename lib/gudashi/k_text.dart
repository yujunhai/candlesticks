import 'package:flutter/material.dart';
import 'package:candlesticks/gudashi/k_base.dart';
import 'package:candlesticks/gudashi/k_line.dart';
import 'package:candlesticks/gudashi/k_plot.dart';

/// 选中K线 主指标
class KPlotText extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final KChartsState state = KCharts.of(context);

    KPoint kPoint = state.kPoint;
    KPlot kPlot = state.kPlot;

    if(kPoint.kPointData.length <= 0){
      return new Container(child: null,);
    }

    Map tapData = {};
    if(kPoint.tapIndexData >= 0){
      tapData = kPoint.kPointData[kPoint.tapIndexData];
    }else{
      tapData = kPoint.kPointData.last;
    }

    return new Container(
      child: kPlot.getMainPlot.text(tapData, kPoint)
    );
  }
}


/// 选中K线文本
class KDescription extends StatelessWidget {

  Widget getText (String text, String data, TextStyle textStyle, [TextStyle textStyleColor,]){

    return new Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new Expanded(
          flex : 4,
          child: new Text(text, style: textStyleColor is TextStyle ? textStyleColor : textStyle, textAlign: TextAlign.left,),
        ),
        new Expanded(
          flex: 8,
          child: new Text(data, style: textStyle, textAlign: TextAlign.right,),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final KChartsState state = KCharts.of(context);

    KStyle kStyle = state.kStyle;
    KLang kLang = state.kLang;
    KPoint kPoint = state.kPoint;

    if(kPoint.kPointData.length <= 0){
      return new Container(child: null,);
    }

    Map tapData = {};

    if(kPoint.kPointData.length <= 0){
      return new Offstage(
        offstage: kPoint.tapIndexData < 0,
      );
    }

    if(kPoint.tapIndexData >= 0){
      tapData = kPoint.kPointData[kPoint.tapIndexData];
    }else{
      tapData = kPoint.kPointData.last;
    }

    TextStyle textStyle = new TextStyle(color: kStyle.tapTextFontColor, fontSize: kStyle.tapTextSize, height: kPoint.tapTextHeight,);
    double fluctuate = (tapData['close'] - tapData['open']);
    TextStyle fluctuateColor = new TextStyle(color: fluctuate > 0 ? kStyle.upColor : fluctuate < 0 ? kStyle.downColor : kStyle.tapTextFontColor, fontSize: kStyle.tapTextSize, height: kPoint.tapTextHeight,);

    return new Offstage (
      offstage: kPoint.tapIndexData < 0,
      child: new Container(
        padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 5.0),
        decoration: new BoxDecoration(
          border: new Border.all(
            width: 0.5,
            color: kStyle.tapTextBorderColor,
          ),
          color: kStyle.tapTextBackgroundColor,
        ),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            getText(kLang.date, tapData['date'].toString().split('.')[0].split(' ')[1], textStyle),
            getText(kLang.open, tapData['open'].toStringAsFixed(kPoint.priceFixed), textStyle),
            getText(kLang.close, tapData['close'].toStringAsFixed(kPoint.priceFixed), textStyle),
            getText(kLang.high, tapData['high'].toStringAsFixed(kPoint.priceFixed), textStyle),
            getText(kLang.low, tapData['low'].toStringAsFixed(kPoint.priceFixed), textStyle),
            getText('mb', tapData['mb'].toStringAsFixed(kPoint.priceFixed), textStyle),
            getText('up', tapData['up'].toStringAsFixed(kPoint.priceFixed), textStyle),
            getText('dn', tapData['dn'].toStringAsFixed(kPoint.priceFixed), textStyle),
            getText(kLang.fluctuatePrice, fluctuate.toStringAsFixed(kPoint.priceFixed), fluctuateColor, textStyle),
            getText(kLang.fluctuatePercent, (fluctuate / tapData['open'] * 100).toStringAsFixed(2) + '%', fluctuateColor, textStyle),
            getText(kLang.volume, tapData['volume'].toStringAsFixed(kPoint.volumeFixed), textStyle),
          ],
        ),
      ),
    );
  }
}


/// MultiChildLayoutDelegate
class KLayoutDelegate extends MultiChildLayoutDelegate {

  KLayoutDelegate({@required this.data});

  KChartsState data;

  static const String kChart = 'chart';
  static const String description = 'description';
  static const String plotText = 'plotText';

  @override
  void performLayout(Size size) {
    final BoxConstraints constraints = new BoxConstraints(maxWidth: size.width, minWidth: size.width);

    layoutChild(kChart, constraints);
    layoutChild(description, new BoxConstraints(maxWidth: data.kPoint.tapTextWidth,));
    layoutChild(plotText, constraints);

    positionChild(kChart, new Offset(0.0, 0.0));
    positionChild(plotText, new Offset(data.kPoint.kPlotTextTop, data.kPoint.kPlotTextLeft));
    if(data.kPoint.tapIndexData >= 0){
      if(data.kPoint.kPointData[data.kPoint.tapIndexData]['x1'] < size.width / 2){
        positionChild(description, new Offset(size.width - data.kPoint.tapTextWidth - data.kPoint.tapTextRight, data.kPoint.tapTextTop));
      }else{
        positionChild(description, new Offset(data.kPoint.tapTextLeft, data.kPoint.tapTextTop));
      }
    }else{
      positionChild(description, new Offset(data.kPoint.tapTextLeft, data.kPoint.tapTextTop));
    }
  }

  @override
  bool shouldRelayout(KLayoutDelegate oldDelegate) => false;
}

