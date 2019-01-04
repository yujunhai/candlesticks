import 'package:flutter/material.dart';

import 'package:candlesticks/2d/uicamera.dart';
import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/uiobjects/uio_rect.dart';
import 'package:candlesticks/2d/uiobject.dart';
import 'package:candlesticks/2d/uiobjects/uio_path.dart';
import 'package:candlesticks/2d/candle_data.dart';

class UIOCandle implements UIAnimatedObject<UIOCandle> {
    final int index;
    final UIOPoint origin;
    final UIOPoint r;
    final Paint painter;

    final double top;
    final double bottom;
    final double marginX;

    UIOCandle(this.origin, this.r, this.top, this.bottom, this.marginX, {this.painter, this.index});

    UIOCandle.fromData(ExtCandleData data, this.marginX, this.painter, {this.index})
        :
            origin = new UIOPoint(data.timeMs.toDouble(), data.open, painter: painter),
            r = UIOPoint(data.durationMs.toDouble(), data.close - data.open, painter: painter),
            top = (data.high - data.open),
            bottom = (data.open - data.low);

    //clone
    UIOCandle clone() {
        var origin = this.origin.clone();
        var r = this.r.clone();
        var top = this.top;
        var bottom = this.bottom;
        return UIOCandle(origin, r, top, bottom, marginX, painter: this.painter, index:index);
    }

    //culling
    UIORect aabb() {
        var s = origin;
        var e = origin + r;

        return UIORect(UIOPoint(s.x, s.y - bottom), UIOPoint(e.x, s.y + top));
    }

    //render
    UIOCandle worldToViewPortPoint(UICamera camera) {
        var center = camera.worldToViewPortPoint(this.origin);
        var r = UIOPoint(camera.worldToViewPortDX(this.r.x),
            camera.worldToViewPortDY(this.r.y), painter: painter);

        var top = camera.worldToViewPortDY(this.top);
        var bottom = camera.worldToViewPortDY(this.bottom);

        return UIOCandle(center, r, top, bottom, marginX, painter: painter);
    }
    UIOCullingRange cullingRange(UICamera uiCamera, {UIOCullingRange range}) {
        return null;
    }
    void paint(Canvas canvas, Size size, UICamera uiCamera, {UIOCullingRange range}) {
        var dx = uiCamera.viewPortToWorldDX(uiCamera.screenToViewPortDx(size, marginX));

        var rect = UIORect(this.origin, this.origin + this.r, painter: painter);
        rect = UIORect(UIOPoint(rect.min.x + dx, rect.min.y), UIOPoint(rect.max.x - dx, rect.max.y), painter: painter);
        rect.paint(canvas, size, uiCamera);

        var basePath = UIOPath(<UIOPoint>[this.origin + UIOPoint(dx, 0), this.origin + this.r - UIOPoint(dx, 0)], painter: painter);
        basePath.paint(canvas, size, uiCamera, range: UIOCullingRange(0, 2));

        var path = UIOPath(<UIOPoint>[this.origin + UIOPoint(this.r.x / 2, -this.bottom), this.origin + UIOPoint(this.r.x / 2, this.top)], painter: painter);
        path.paint(canvas, size, uiCamera, range: UIOCullingRange(0, 2));
    }

    //lerp
    UIOCandle operator +(UIOCandle other) {
        UIOCandle a = this.clone();
        var b = other;
        if (b == null) {
            b = UIOCandle(UIOPoint(0, 0), UIOPoint(0, 0), 0, 0, marginX, painter: painter);
        }

        return UIOCandle(
            a.origin + b.origin, a.r + b.r, a.top + b.top, a.bottom + b.bottom, marginX, painter: painter);
    }

    UIOCandle operator -(UIOCandle other) {
        UIOCandle a = this.clone();
        var b = other;
        if (b == null) {
            b = UIOCandle(UIOPoint(0, 0), UIOPoint(0, 0), 0, 0, marginX, painter: painter);
        }

        return UIOCandle(
            a.origin - b.origin, a.r - b.r, a.top - b.top, a.bottom - b.bottom, marginX, painter: painter);
    }

    UIOCandle operator *(double process) {
        if (this == null) {
            return UIOCandle(UIOPoint(0, 0), UIOPoint(0, 0), 0, 0, marginX, painter: painter);
        }
        var origin = this.origin * process;
        var r = this.r * process;
        var top = this.top * process;
        var bottom = this.bottom * process;
        return UIOCandle(origin, r, top, bottom, marginX, painter: painter);
    }
}
