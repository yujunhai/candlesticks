import 'package:flutter/material.dart';

import 'package:candlesticks/2d/uiobjects/uio_point.dart';
import 'package:candlesticks/2d/uiobjects/uio_rect.dart';

class UICamera {
    final UIORect viewPort;//世界坐标系

    UICamera(this.viewPort);

    UICamera clone() {
        return UICamera(this.viewPort.clone());
    }

    //world <=> viewport
    double worldToViewPortDY(double dy) {
        return dy / viewPort.height;
    }

    double viewPortToWorldDY(double dy) {
        return dy * viewPort.height;
    }

    double worldToViewPortDX(double dx) {
        return dx / viewPort.width;
    }

    double viewPortToWorldDX(double dx) {
        return dx * viewPort.width;
    }

    UIOPoint worldToViewPortPoint(UIOPoint point) {
        double x = viewPort.min.x;
        if(viewPort.width > 0) {
            x = (point.x - viewPort.min.x) / viewPort.width;
        }

        double y = viewPort.min.y;
        if(viewPort.height > 0) {
            y = (point.y - viewPort.min.y) / viewPort.height;
        }
        return UIOPoint(x, y);
    }

    UIOPoint viewPortToWorldPoint(UIOPoint point) {
        return UIOPoint(point.x * viewPort.width + viewPort.min.x, point.y * viewPort.height + viewPort.min.y);
    }

    //viewport <=> screen
    Offset viewPortToScreenPoint(Size size, UIOPoint point) {
        return Offset(
            size.width * point.x, size.height - size.height * point.y);
    }

    UIOPoint screenToViewPortPoint(Size size, Offset point) {
        return UIOPoint(
            point.dx / size.width, (size.height - point.dy) / size.height);
    }

    double viewPortToScreenDx(Size size, double dx) {
        return dx * size.width;
    }

    double viewPortToScreenDy(Size size, double dy) {
        return dy * size.height;
    }

    double screenToViewPortDx(Size size, double dx) {
        return dx / size.width;
    }

    double screenToViewPortDy(Size size, double dy) {
        return dy / size.height;
    }


    UICamera operator +(UICamera other) {
        var b = other;
        if(b == null) {
            b = UICamera(UIORect(UIOPoint(0, 0), UIOPoint(0, 0)));
        }
        return UICamera(UIORect(viewPort.min + b.viewPort.min, viewPort.max + b.viewPort.max));
    }
    UICamera operator -(UICamera other) {
        var b = other;
        if(b == null) {
            b = UICamera(UIORect(UIOPoint(0, 0), UIOPoint(0, 0)));
        }
        if(viewPort.min == null) {
            return null;
        }
        return UICamera(UIORect(viewPort.min - b.viewPort.min, viewPort.max - b.viewPort.max));
    }

    UICamera operator *(double process) {
        UIORect viewPort = this.viewPort.clone();
        viewPort *= process;
        return UICamera(viewPort);
    }
}
