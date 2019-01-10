import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/aabb/aabb_range.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';

class GraticulePainter extends CustomPainter {

  final UICamera uiCamera;
  final double paddingY;
  final CandlesticksStyle candlesticksStyle;

  GraticulePainter({
    this.uiCamera,
    this.paddingY,
    this.candlesticksStyle,
  });

  void paintX(Canvas canvas, Size size, double x, Paint painter) {
    var point = uiCamera.viewPortToWorldPoint(
        uiCamera.screenToViewPortPoint(size, Offset(x, 0)));
    var worldX = point.x;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), painter);


    var time = new DateTime.fromMillisecondsSinceEpoch(point.x.toInt()).toLocal();
    String timeStr ="${time.month.toString().padLeft(2,'0')}-${time.day.toString().padLeft(2,'0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

    TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        maxLines: 1,
        textAlign: TextAlign.end,
        text: TextSpan(
          text: timeStr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 8.0,
          ),
        )
    );

    textPainter.layout();
//    if((x - textPainter.width / 2 >= 0) && (x + textPainter.width / 2 <= size.width)) {
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - textPainter.height));
//    }
  }

  void paintY(Canvas canvas, Size size, double y, Paint painter) {
    var point = uiCamera.viewPortToWorldPoint(
        uiCamera.screenToViewPortPoint(size, Offset(0, y)));
    var worldY = point.y;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), painter);
    var priceStr = worldY.toStringAsFixed(this.candlesticksStyle.fractionDigits);

    TextPainter textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        maxLines: 1,
        textAlign: TextAlign.end,
        text: TextSpan(
          text: priceStr,
          style: TextStyle(
            color: Colors.white.withOpacity(0.2),
            fontSize: 10.0,
          ),
        )
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - textPainter.width, y));

  }

  @override
  void paint(Canvas canvas, Size size) {
    //五条线。
    // 绘制代码
    var beginY = size.height * paddingY;
    var endY = size.height * (1 - paddingY);
    var painter = Paint()
      ..style = PaintingStyle.stroke
      ..color = candlesticksStyle.lineColor;
    int n = this.candlesticksStyle.nY;
    double height = (endY - beginY) / n;

    paintY(canvas, size, beginY, painter);
    for (var i = 1; i < n; i ++) {
      paintY(canvas, size, beginY + height * i, painter);
    }
    paintY(canvas, size, endY, painter);

    double width = size.width / this.candlesticksStyle.nX;
    for(var i = 0; i <= this.candlesticksStyle.nX; i++) {
      paintX(canvas, size, width * i, painter);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class GraticuleWidget extends StatelessWidget {
  GraticuleWidget({
    Key key,
    this.candlesticksStyle,
    this.paddingY,
  }) : super(key: key);

  final double paddingY;
  final CandlesticksStyle candlesticksStyle;

  @override
  Widget build(BuildContext context) {
    var aabbContext = AABBContext.of(context);
    var uiCamera = aabbContext.uiCamera;
    if (uiCamera == null) {
      return Container();
    }

    return CustomPaint(
        painter: GraticulePainter(
          uiCamera: uiCamera,
          paddingY: paddingY,
          candlesticksStyle: this.candlesticksStyle,
        ),
        size: Size.infinite
    );
  }
}
