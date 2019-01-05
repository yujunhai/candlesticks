import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:candlesticks/2d/uiobject.dart';
import 'package:candlesticks/2d/uiobjects/uio_rect.dart';
import 'package:candlesticks/2d/uicamera.dart';

const _ZERO = 0.0000000001;

class UIOPoint extends UIAnimatedObject<UIOPoint> {
    final int index;
    final double x;
    final double y;
    final Paint painter;

    UIOPoint(this.x, this.y, {this.painter, this.index});

    UIOPoint clone() {
        return UIOPoint(x, y, painter : this.painter, index:this.index);
    }

    UIORect aabb() {
        return UIORect(UIOPoint(x, y), UIOPoint(x, y));
    }
    UIOCullingRange cullingRange(UICamera uiCamera, {UIOCullingRange range}) {
        return null;
    }

    void paint(Canvas canvas, Size size, UICamera uiCamera, {UIOCullingRange range}) {
        return;
    }

    UIOPoint operator +(UIOPoint other) {
        var a = this.clone();
        var b = other;
        if(b == null){
            b = UIOPoint(0, 0, painter: painter);
        }

        return UIOPoint(a.x + b.x, a.y + b.y, painter: painter, index:index);
    }

    UIOPoint operator -(UIOPoint other) {
        var a = this.clone();
        var b = other;
        if(b == null){
            b = UIOPoint(0, 0, painter: painter);
        }

        return UIOPoint(a.x - b.x, a.y - b.y, painter: painter, index:index);
    }

    UIOPoint operator *(double process) {
        return UIOPoint(this.x * process, this.y * process, painter: painter, index:index);
    }

    bool equal(other) {
        var dist = math.sqrt(this.x * other.x + this.y * other.y);
        return dist < _ZERO;
    }

    bool operator<(other) {
        if(this.x < other.x) {
            return true;
        }
        if(this.y < other.y) {
            return true;
        }
        return false;
    }
}
