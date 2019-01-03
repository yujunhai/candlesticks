import 'package:flutter/material.dart';
import 'dart:core';
import 'package:candlesticks/gudashi/k_base.dart';
import 'package:candlesticks/gudashi/k_plot.dart';

import 'dart:ui' as ui;

class KPainter extends CustomPainter {

  KPainter({
    Key key,
    @required this.kStyle,
    @required this.kPoint,
    @required this.kPlot,
  });

  KStyle kStyle;
  KPoint kPoint;
  KPlot kPlot;

  @override
  void paint (Canvas canvas, Size size){
    print(size);
    bg(canvas, size);
    axisLine(canvas, size);
    kLine(canvas, size);
    plot(canvas, size);
    axisText(canvas, size);
    kPriceMaxMin(canvas, size);
    tapIndexLine(canvas, size);
  }


  void plot (Canvas canvas, Size size){
    if(kPlot.mainActive >= 0 && kPlot.mainPlot.length > 0 && kPlot.getMainPlot is PlotAbstract && kPoint.kPointData.length > 0){
      for(int m = 0; m < kPlot.getMainNameList.length; m++){
        String nameY = kPlot.getMainNameList[m] + 'Y';
        Paint maPaint = new Paint();
        maPaint..color = kPlot.getMainColorList[m];
        if(kPlot.getMainPlot.type == 'line'){
          for(int i = kPoint.atDataIndex[0]; i <= kPoint.atDataIndex[1]; i++){
            if(i >= 1 && kPoint.kPointData[i - 1] is Map && kPoint.kPointData[i][nameY] is double && kPoint.kPointData[i - 1][nameY]  is double){
              canvas.drawLine(new Offset(kPoint.kPointData[i - 1]['klineX'], kPoint.kPointData[i - 1][nameY]), new Offset(kPoint.kPointData[i]['klineX'], kPoint.kPointData[i][nameY]), maPaint);
            }
          }
        }
      }
      for(int iv = 0; iv < kPlot.getViceNameList.length; iv++){
        String nameY = kPlot.getViceNameList[iv] + 'Y';
        print(nameY);
        print(kPoint.kPointData[kPoint.atDataIndex[0]]);
        Paint maPaint = new Paint();
        maPaint..color = kPlot.getViceColorList[iv];
        if(kPlot.getViceNameList[iv] == 'macd'){
          for(int i = kPoint.atDataIndex[0]; i <= kPoint.atDataIndex[1]; i++){
            if(i >= 1 && kPoint.kPointData[i] is Map && kPoint.kPointData[i][nameY] is double && kPoint.kPointData[i][nameY]  is double){
              canvas.drawLine(new Offset(kPoint.kPointData[i]['klineX'], kPoint.kPointData[i][nameY + '1']), new Offset(kPoint.kPointData[i]['klineX'], kPoint.kPointData[i][nameY]), maPaint);
            }
          }
        }else{
          for(int i = kPoint.atDataIndex[0]; i <= kPoint.atDataIndex[1]; i++){
            if(i >= 1 && kPoint.kPointData[i - 1] is Map && kPoint.kPointData[i][nameY] is double && kPoint.kPointData[i - 1][nameY]  is double){
              canvas.drawLine(new Offset(kPoint.kPointData[i - 1]['klineX'], kPoint.kPointData[i - 1][nameY]), new Offset(kPoint.kPointData[i]['klineX'], kPoint.kPointData[i][nameY]), maPaint);
            }
          }
        }
      }
    }
  }


  void tapIndexLine (Canvas canvas, Size size){
    if(kPoint.tapIndexData >= 0){
      Map tapData = kPoint.kPointData[kPoint.tapIndexData];
      Paint maxCircle = new Paint();
      maxCircle..shader = new ui.Gradient.radial(
          new Offset(tapData['x1'] + (tapData['x2'] - tapData['x1']) / 2, size.height / 2),
          size.height,
          kStyle.tapRadialColor,
          kStyle.tapRadialColorStops,
          TileMode.clamp
      );
      canvas.drawRect(new Rect.fromLTRB(tapData['x1'], 0, tapData['x2'], size.height), maxCircle);
    }
  }

  void kPriceMaxMin (Canvas canvas, Size size){
    if(kPoint.kMaxPriceIndex >= 0 && kPoint.kMaxPriceIndex < kPoint.kPointData.length){
      Map maxData = kPoint.kPointData[kPoint.kMaxPriceIndex];
      TextPainter textMax = getTextPainter(maxData['high'].toString(), 1);
      textMax.layout();

      var maxX = maxData['klineX'];
      var maxBorderX1 = maxData['klineX'];
      var maxBorderX2 = maxData['klineX'] + kPoint.kPriceBorderW;
      if(maxX > size.width / 2){
        maxBorderX2 = maxBorderX1 - kPoint.kPriceBorderW;
        maxX = maxBorderX2 - 2 - textMax.width;
      }else{
        maxBorderX2 = maxBorderX1 + kPoint.kPriceBorderW;
        maxX = maxBorderX2 + 2;
      }
      var maxY = maxData['highY'] - (textMax.height / 2);
      textMax.paint(canvas, new Offset(maxX, maxY));
      canvas.drawLine(new Offset(maxBorderX1, maxData['highY']), new Offset(maxBorderX2, maxData['highY']), new Paint()..color = kStyle.priceMinMaxFontColor.withOpacity(0.5));
      Paint maxCircle = new Paint();
//      maxCircle..color = kStyle.priceMinMaxFontColor.withOpacity(0.3);
      maxCircle..shader = new ui.Gradient.radial(new Offset(maxBorderX1, maxData['highY']), kPoint.kMinMaxPriceCircle, [
        kStyle.priceMinMaxFontColor.withOpacity(0.8),
        kStyle.priceMinMaxFontColor.withOpacity(0.1),
      ], [0.0, 1.0], TileMode.clamp);
      canvas.drawCircle(new Offset(maxBorderX1, maxData['highY']), kPoint.kMinMaxPriceCircle, maxCircle);
    }

    if(kPoint.kMinPriceIndex >= 0 && kPoint.kMinPriceIndex <= kPoint.kPointData.length){
      var minData = kPoint.kPointData[kPoint.kMinPriceIndex];
      TextPainter textMin = getTextPainter(minData['low'].toString(), 1);
      textMin.layout();

      var minX = minData['klineX'];
      var minBorderX1 = minData['klineX'];
      var minBorderX2 = minData['klineX'] + kPoint.kPriceBorderW;
      if(minX > size.width / 2){
        minBorderX2 = minBorderX1 - kPoint.kPriceBorderW;
        minX = minBorderX2 - 2 - textMin.width;
      }else{
        minBorderX2 = minBorderX1 + kPoint.kPriceBorderW;
        minX = minBorderX2 + 2;
      }
      var minY = minData['lowY'] - (textMin.height / 2);

      textMin.paint(canvas, new Offset(minX, minY));
      canvas.drawLine(new Offset(minBorderX1, minData['lowY']), new Offset(minBorderX2, minData['lowY']), new Paint()..color = kStyle.priceMinMaxFontColor.withOpacity(0.5));
      Paint minCircle = new Paint();
//      minCircle..color = kStyle.priceMinMaxFontColor.withOpacity(0.3);
      minCircle..shader = new ui.Gradient.radial(new Offset(minBorderX1, minData['lowY']), kPoint.kMinMaxPriceCircle, [
        kStyle.priceMinMaxFontColor.withOpacity(0.8),
        kStyle.priceMinMaxFontColor.withOpacity(0.1),
      ], [0.0, 1.0], TileMode.clamp);
      canvas.drawCircle(new Offset(minBorderX1, minData['lowY']), kPoint.kMinMaxPriceCircle, minCircle);
    }
  }

  void kLine (Canvas canvas, Size size){
    if(kPoint.kPointData.length > 0){
      for(int i = kPoint.atDataIndex[0]; i <= kPoint.atDataIndex[1]; i++){
        Map item = kPoint.kPointData[i];
        canvas.drawRect(new Rect.fromLTRB(item['x1'], item['y1'], item['x2'], item['y2']), item['color']);
        if(kPoint.vHScale > 0 && item['vY1'] is double && item['vY2'] is double){
          canvas.drawRect(new Rect.fromLTRB(item['x1'], item['vY1'], item['x2'], item['vY2']), item['color']);
        }
        var klineX = (item['x2'] - item['x1']) / 2 + item['x1'];
        canvas.drawLine(new Offset(klineX, item['highY']), new Offset(klineX, item['lowY']), item['color']);
      }
    }
  }

  void bg(Canvas canvas, Size size){
    canvas.drawRect(new Rect.fromLTRB(0, 0, size.width, size.height), new Paint()..color = kStyle.bgColor);
  }

  void axisLine (Canvas canvas, Size size){
    var xItemW = size.width / (kPoint.xAxisNum + 1);
    Paint linePaint = new Paint()..color = kStyle.borderColor;
    for(int i = 1; i <= kPoint.xAxisNum; i++){
      var w = xItemW * i;
      canvas.drawLine(new Offset(w, 0), new Offset(w, size.height), linePaint);
    }
    for(int i = 0; i < kPoint.yTextPointData.length; i++){
      var y = kPoint.yTextPointData[i]['y'];
      canvas.drawLine(new Offset(0, y), new Offset(size.width, y), linePaint);
    }
    canvas.drawLine(new Offset(0, kPoint.vMin), new Offset(size.width, kPoint.vMin), linePaint);
  }

  void axisText (Canvas canvas, Size size){
    for(int i = 0; i < kPoint.yTextPointData.length; i++){
      TextPainter text = getTextPainter(kPoint.yTextPointData[i]['text']);
      text.layout();
      var y = kPoint.yTextPointData[i]['y'];
      text.paint(canvas, new Offset(size.width - text.width - kPoint.yTextPadding, y - text.height));
    }
    for(int i = 0; i < kPoint.yTextVData.length; i++){
      TextPainter text = getTextPainter(kPoint.yTextVData[i]['text']);
      text.layout();
      var y = kPoint.yTextVData[i]['y'];
      text.paint(canvas, new Offset(size.width - text.width - kPoint.yTextPadding, y));
    }
  }

  TextPainter getTextPainter (String text, [int type = 0,]){
    return new TextPainter(
      text: new TextSpan(
        text: text,
        style: new TextStyle(
          color: type == 1 ? kStyle.priceMinMaxFontColor : kStyle.fontColor,
          fontSize: type == 1 ? kStyle.priceMinMaxFontSize : kStyle.fontSize,
          fontWeight: type == 1 ? kStyle.priceMinMaxFontWeight : kStyle.fontWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.end,
    );
  }

  @override
  bool shouldRepaint(KPainter oldDelegate) {
    // TODO: implement shouldRepaint
    print('shouldRepaint');
    return true;
  }

  @override
  bool shouldRebuildSemantics(KPainter oldDelegate) {
    // TODO: implement shouldRebuildSemantics
    print('shouldRebuildSemantics');
    return false;
  }

}