import 'package:flutter/material.dart';

import 'package:candlesticks/2d/uiobjects/uio_rect.dart';
import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiobjects/uio_candle.dart';
import 'package:candlesticks/2d/uiobject.dart';

class UIOCandles extends UIObjects<UIOCandle, UIOCandles> implements UIObjectsAccesser<UIOCandle>, UIObject<UIOCandles> {
    final int index;
    final List<UIOCandle> uiObjects;
    final Paint painter;

    UIOCandles(this.uiObjects, {this.painter, this.index}) : super();

    UIOCandles clone() {
        var uiObjects =
        List<UIOCandle>.from(this.uiObjects)?.map((o) => o.clone())?.toList();
        return UIOCandles(uiObjects, painter: painter);
    }

    void paint(Canvas canvas, Size size, UICamera uiCamera, {UIOCullingRange range}) {
        if(range == null) {
            return;
        }
        for(var i = range.minIndex; i < range.maxIndex; i++) {
            uiObjects[i].paint(canvas, size, uiCamera);
        }
    }
    UIORect aabb() {
        return null;
    }
}

