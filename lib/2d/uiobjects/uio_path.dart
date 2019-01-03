import 'package:flutter/material.dart';
import 'dart:math';

import 'package:candlesticks/2d/uiobject.dart';
import 'package:candlesticks/2d/uiobjects/uio_rect.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/uicamera.dart';

class UIOPath extends UIObjects<UIOPoint, UIOPath> implements UIObjectsAccesser<UIOPoint>, UIObject<UIOPath> {
    final int index;
    final List<UIOPoint> uiObjects;
    final Paint painter;

    UIOPath(this.uiObjects, {this.painter, this.index}) : super();

    UIOPath clone() {
        var uiObjects =
            List<UIOPoint>.from(this.uiObjects)?.map((o) => o.clone())?.toList();
        return UIOPath(uiObjects, painter: painter);
    }

    void paint(Canvas canvas, Size size, UICamera uiCamera, {UIOCullingRange range}) {
        if(range == null) {
            return;
        }
        List<Offset> points = <Offset>[];

        var minIndex = range.minIndex;
        if(minIndex > 0) {
            minIndex--;
        }
        var maxIndex = range.maxIndex;
        if(maxIndex + 1 < uiObjects.length) {
            maxIndex++;
        }

        for(var i = minIndex; i < maxIndex; i++) {
            var currentPoint = uiCamera.viewPortToScreenPoint(size, uiCamera.worldToViewPortPoint(uiObjects[i]));
            points.add(currentPoint);
        }

        if(points.length < 2) {
            return;
        }else if(points.length == 2) {
            canvas.drawLine(points[0], points[1], painter);
        }else {
            Path path = new Path();
            path.addPolygon(points, false);
            canvas.drawPath(path, painter);
        }
    }

    UIORect aabb() {
        var minX = double.infinity;
        var minY = double.infinity;
        var maxX = double.negativeInfinity;
        var maxY = double.negativeInfinity;

        uiObjects.forEach((p) {
            minX = min(minX, p.x);
            minY = min(minY, p.y);

            maxX = max(maxX, p.x);
            maxY = max(maxY, p.y);
        });

        return UIORect(UIOPoint(minX, minY), UIOPoint(maxX, maxY));
    }
}

