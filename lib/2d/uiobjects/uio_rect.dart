import 'package:flutter/material.dart';

import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/uiobject.dart';
import 'package:candlesticks/2d/uicamera.dart';

class UIORect implements UIAnimatedObject<UIORect> {
    final UIOPoint min;
    final UIOPoint max;
    final Paint painter;

    UIORect(this.min, this.max, {this.painter});

    double get height => this.max.y - this.min.y;

    double get width => this.max.x - this.min.x;


    UIORect clone() {
        var min = this.min.clone();
        var max = this.max.clone();
        return UIORect(min, max, painter: painter);
    }

    paint(Canvas canvas, Size size, UICamera uiCamera, {UIOCullingRange range}) {
        var viewPortMin = uiCamera.worldToViewPortPoint(min);
        var viewPortMax = uiCamera.worldToViewPortPoint(max);
        var screenMin = uiCamera.viewPortToScreenPoint(size, viewPortMin);
        var screenMax = uiCamera.viewPortToScreenPoint(size, viewPortMax);

        canvas.drawRect(Rect.fromPoints(screenMin, screenMax), painter);
    }
    UIOCullingRange cullingRange(UICamera uiCamera, {UIOCullingRange range}) {
        return null;
    }

    UIORect aabb() {
        return UIORect(min, max, painter: painter);
    }

    UIORect operator +(UIORect other) {
        return UIORect(this.min + other.min, this.max + other.max, painter: painter);
    }

    UIORect operator -(UIORect other) {
        return UIORect(this.min - other.min, this.max - other.max, painter: painter);
    }

    UIORect operator *(double process) {
        return UIORect(this.min * process, this.max * process, painter: painter);
    }

    bool cross(UIORect other) {
        if(other.max.x < this.min.x) {
            return false;
        }

        if(other.min.x > this.max.x) {
            return false;
        }

        if(other.max.y < this.min.y) {
            return false;
        }

        if(other.min.y > this.max.y) {
            return false;
        }
        return true;
    }

}
