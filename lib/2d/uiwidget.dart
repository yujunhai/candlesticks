import 'package:flutter/material.dart';

import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiobject.dart';

class UIWidgetPainter extends CustomPainter {
    UICamera uiCamera;
    UIObject uidata;
    UIOCullingRange range;

    UIWidgetPainter(this.uiCamera, this.uidata, this.range);

    @override
    void paint(Canvas canvas, Size size) {
        uidata.paint(canvas, size, uiCamera, range:this.range);
    }

    @override
    bool shouldRepaint(UIWidgetPainter oldUIPainter) {
        return true;
    }
}

class UIWidget<T> extends StatefulWidget {
    final UICamera uiCamera;
    final UIObject<T> uiPainterData;


    UIWidget({
        Key key,
        @required this.uiCamera,
        @required this.uiPainterData,
    }) : super(key:key);

    @override
    _UIWidgetState createState() => _UIWidgetState(uiCamera, uiPainterData);
}

class _UIWidgetState extends State<UIWidget> {
    UIOCullingRange range;

    _UIWidgetState(uiCamera, uiPainterData);

    @override
    Widget build(BuildContext context) {
        var widget = context.widget as UIWidget;
        if(widget.uiPainterData == null) {
            return Container();
        }

        range = widget.uiPainterData.cullingRange(widget.uiCamera, range : range);
        return CustomPaint(
            painter: UIWidgetPainter(widget.uiCamera, widget.uiPainterData, this.range),
        );
    }

    dispose() {
        super.dispose();
    }
}

