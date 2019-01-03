import 'package:flutter/material.dart';

import 'package:candlesticks/2d/uiobjects/uio_rect.dart';
import 'package:candlesticks/2d/uicamera.dart';

class UIOCullingRange {
    int minIndex;
    int maxIndex;

    UIOCullingRange(this.minIndex, this.maxIndex);
}

abstract class UIObject<T> {
    Paint get painter;
    T clone();
    void paint(Canvas canvas, Size size, UICamera uiCamera, {UIOCullingRange range});
    UIORect aabb();
    UIOCullingRange cullingRange(UICamera uiCamera, {UIOCullingRange range});
}

abstract class UIAnimatedObject<T> implements UIObject<T> {
    T operator -(T other);
    T operator +(T other);
    T operator *(double process);
}

abstract class UIObjectsAccesser<T> {
    List<T> get uiObjects;
}

abstract class UIObjects<T extends UIAnimatedObject<T>, TT extends UIObjectsAccesser> implements UIObjectsAccesser<T>, UIAnimatedObject<TT> {
    TT clone();

    TT operator -(TT other) {
        var a = this.clone();
        var b = other;

        int maxLength = a.uiObjects.length;
        if (b.uiObjects.length > maxLength) {
            maxLength = b.uiObjects.length;
        }
        for (var i = 0; i < maxLength; i++) {
            var aa;
            if (i < a.uiObjects.length) {
                aa = a.uiObjects[i];
            }

            var bb;
            if (i < b.uiObjects.length) {
                bb = b.uiObjects[i];
            }
            if(aa == null) {
                a.uiObjects.add(-bb.beginUIObject());
            }else {
                if(bb == null) {
                    bb = aa.beginUIObject();
                }
                a.uiObjects[i] = aa - bb;
            }
        }
        return a;
    }

    TT operator +(TT other) {
        var a = this.clone();
        var b = other;

        int maxLength = a.uiObjects.length;
        if (b.uiObjects.length > maxLength) {
            maxLength = b.uiObjects.length;
        }
        for (var i = 0; i < maxLength; i++) {
            var aa;
            if (i < a.uiObjects.length) {
                aa = a.uiObjects[i];
            }

            var bb;
            if (i < b.uiObjects.length) {
                bb = b.uiObjects[i];
            }
            if(aa == null) {
                a.uiObjects.add(bb);
            }else {
                a.uiObjects[i] = aa + bb;
            }
        }
        return a;
    }

    TT operator *(double process) {
        var self = this.clone();
        for(var i = 0; i < self.uiObjects.length; i++) {
            self.uiObjects[i] = self.uiObjects[i] * process;
        }
        return self;
    }

    int _anyCullingIndex(UICamera uiCamera, {UIOCullingRange range}) {
        if ((uiObjects == null) || (uiObjects.length <= 0)) {
            return null;
        }

        int minIndex = 0;
        int maxIndex = uiObjects.length - 1;

        if (range != null) {
            minIndex = range.minIndex;
            if (uiObjects.length - 1 < minIndex) {
                minIndex = uiObjects.length - 1;
            }

            maxIndex = range.maxIndex;
            if (uiObjects.length - 1 < maxIndex) {
                maxIndex = uiObjects.length - 1;
            }
        }

        if (uiObjects[minIndex].aabb().cross(uiCamera.viewPort)) {
            return minIndex;
        }
        if (uiObjects[maxIndex].aabb().cross(uiCamera.viewPort)) {
            return maxIndex;
        }

        int midIndex = (minIndex + maxIndex) ~/ 2;
        if (uiObjects[midIndex].aabb().cross(uiCamera.viewPort)) {
            return midIndex;
        }
        if(uiObjects[0].aabb().max.x < uiCamera.viewPort.min.x) {
            return null;
        }
        if(uiObjects[uiObjects.length - 1].aabb().min.x > uiCamera.viewPort.max.x) {
            return null;
        }
        for (var i = 0; i < uiObjects.length; i++) {
            if (uiObjects[i].aabb().cross(uiCamera.viewPort)) {
                return i;
            }
        }
        return null;
    }

    UIOCullingRange cullingRange(UICamera uiCamera, {UIOCullingRange range}) {
        int anyIndex = this._anyCullingIndex(uiCamera, range : range);
        if (anyIndex == null) {
            return null;
        }
        var minIndex = 0;
        var maxIndex = this.uiObjects.length;

        for (var i = anyIndex; i >= 0; i--) {
            if (uiCamera.viewPort.cross(this.uiObjects[i].aabb())) {
                minIndex = i;
            } else {
                break;
            }
        }

        for (var i = anyIndex; i < uiObjects.length; i++) {
            if (!uiCamera.viewPort.cross(this.uiObjects[i].aabb())) {
                maxIndex = i;
                break;
            }
        }

        return UIOCullingRange(minIndex, maxIndex);
    }
}
