import 'package:flutter/material.dart';

import 'package:candlesticks/widgets/aabb/aabb_range.dart';
import 'package:candlesticks/widgets/aabb/aabb_context.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/widgets/candlesticks_style.dart';
import 'package:candlesticks/widgets/ma/ma_style.dart';
import 'package:candlesticks/widgets/ma/ma_context.dart';
import 'package:candlesticks/widgets/ma/ma_value_widget.dart';
import 'package:candlesticks/widgets/ma/ma_value_data.dart';

class CandlesValuePainter extends CustomPainter {

  final UICamera uiCamera;
  final UIOPoint point;

  CandlesValuePainter({
    this.uiCamera,
    this.point,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset p = uiCamera.viewPortToScreenPoint(size, uiCamera.worldToViewPortPoint(point));
    TextPainter currentTextPainter = TextPainter(
        textDirection: TextDirection.ltr,
        maxLines: 1,
        textAlign: TextAlign.end,
        text: TextSpan(
          text: "asdf",
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.0,
          ),
        )
    );
    currentTextPainter.layout();
    currentTextPainter.paint(canvas, p);
  }

  @override
  bool shouldRepaint(CandlesValuePainter oldPainter) {
    return this.point != oldPainter.point || this.uiCamera != oldPainter.uiCamera;
  }
}

class CandlesValueWidget extends StatelessWidget {
  CandlesValueWidget({
    Key key,
    this.point,
  }) : super(key: key);

  final UIOPoint point;

  @override
  Widget build(BuildContext context) {
    var aabbContext = AABBContext.of(context);
    var uiCamera = aabbContext.uiCamera;
    if (uiCamera == null) {
      return Container();
    }

    return CustomPaint(
        painter: CandlesValuePainter(
          uiCamera: uiCamera,
          point: this.point,
        ),
        size: Size.infinite
    );
  }
}
