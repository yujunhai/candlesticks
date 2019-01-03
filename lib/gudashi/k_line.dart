import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:candlesticks/gudashi/k_base.dart';
import 'package:candlesticks/gudashi/k_painter.dart';
import 'package:candlesticks/gudashi/k_text.dart';
import 'package:candlesticks/gudashi/k_plot.dart';

class KLine {
    static const MethodChannel _channel = const MethodChannel('k_line');

    static Future<String> get platformVersion async {
        final String version = await _channel.invokeMethod(
            'getPlatformVersion');
        return version;
    }
}


class KCharts extends StatefulWidget {

    KCharts({
        Key key,
        this.height = 400,
        this.width = 650,
        @required this.data,
    }) :super(key: key);

    final double height;
    final double width;
    final List data;
    KChartsState myState;

    @override
    KChartsState createState() =>KChartsState(this.data);
        // TODO: implement createState

    static KChartsState of(BuildContext context) {
        return (context.inheritFromWidgetOfExactType(KInherited) as KInherited)
            .data;
    }
}

class KChartsState extends State<KCharts> {

    KChartsState(data): super(){
        this.data = data;
    }

    /// K线数据
    List data = [];

    KStyle kStyle = new KStyle();
    KPoint kPoint = new KPoint();
    KLang kLang = new KLang();
    KPlot kPlot = new KPlot();

    @override
    void initState() {
        // TODO: implement initState
        super.initState();
        init();
        print("initState");
    }

    @override
    void didChangeDependencies() {
        // TODO: implement didChangeDependencies
        super.didChangeDependencies();
        print('didChangeDependencies');
    }

    @override
    void didUpdateWidget(KCharts oldWidget) {
        // TODO: implement didUpdateWidget
        super.didUpdateWidget(oldWidget);
        print('didUpdateWidget');
    }

    @override
    Widget build(BuildContext context) {
        // TODO: implement build
        return new KInherited(
            child: new GestureDetector(
                onHorizontalDragUpdate: onHorizontalDragUpdate,
                onScaleStart: onScaleStart,
                onScaleUpdate: onScaleUpdate,
                onTapUp: onTapUp,
                child: new Container(
                    height: widget.height,
                    width: widget.width,
                    child: new CustomMultiChildLayout(
                        delegate: new KLayoutDelegate(data: this),
                        children: <Widget>[
                            new LayoutId(
                                id: KLayoutDelegate.kChart,
                                child: new CustomPaint(
                                    size: new Size(widget.width, widget.height),
                                    willChange: true,
                                    painter: new KPainter(
                                        kStyle: kStyle,
                                        kPoint: kPoint,
                                        kPlot: kPlot,
                                    ),
                                ),
                            ),
                            new LayoutId(
                                id: KLayoutDelegate.description,
                                child: new KDescription(),
                            ),
                            new LayoutId(
                                id: KLayoutDelegate.plotText,
                                child: new KPlotText(),
                            ),
                        ],
                    ),
                ),
            ),
            data: this,
        );
    }

    /// 全局坐标转局部坐标未处理，宽度不能小于 100%
    void onTapUp(TapUpDetails details) {
        if (kPoint.kPointData.length > 0) {
            int tapIndexData = kPoint.kPointData.length - 1;
            for (int i = 0; i < kPoint.kPointData.length; i++) {
                if (kPoint.kPointData[i]['x1'] - kPoint.kItemGap <=
                    details.globalPosition.dx &&
                    kPoint.kPointData[i]['x2'] + kPoint.kItemGap >=
                        details.globalPosition.dx) {
                    tapIndexData = i;
                    break;
                }
            }
            setState(() {
                kPoint.tapIndexData = tapIndexData;
            });
        }
    }

    void onScaleStart(ScaleStartDetails details) {
//    print('onScaleStart');
        int scaleIndexKPoint = -1;
        setState(() {
            for (int i = 0; i < kPoint.kPointData.length; i++) {
                if (kPoint.kPointData[i]['x1'] <= details.focalPoint.dx &&
                    kPoint.kPointData[i]['x2'] >= details.focalPoint.dx) {
                    scaleIndexKPoint = i;
                    break;
                }
            }
            kPoint.scaleIndexKPoint = scaleIndexKPoint;
            kPoint.scaleIndexKFocalPointDx = details.focalPoint.dx;
            kPoint.kItemWidthRecord = kPoint.kItemWidth;
        });
    }

    void onScaleUpdate(ScaleUpdateDetails details) {
        Size size = context.size;
//    print('onScaleUpdate');
        double s = details.scale - 1;
//    print('focalPoint: ${details.focalPoint}  rotation:${details.rotation}  scale:${details.scale}              s:${s.toString()}');
        if (s != 0 && kPoint.scaleIndexKPoint >= 0) {
            setState(() {
                kPoint.kItemWidth =
                    kPoint.kItemWidthRecord + (s * kPoint.scale);
                kPoint.kItemWidth = kPoint.kItemWidth < kPoint.kItemWidthMin
                    ? kPoint.kItemWidthMin
                    : kPoint.kItemWidth > kPoint.kItemWidthMax ? kPoint
                    .kItemWidthMax : kPoint.kItemWidth;
                kPoint.atKNum = (size.width / kPoint.kItemWidth).ceil();

                int dataLen = kPoint.kPointData.length;
                var gapX = size.width -
                    (dataLen - kPoint.scaleIndexKPoint) * kPoint.kItemWidth;
                gapX = (size.width - kPoint.scaleIndexKFocalPointDx) - gapX;
                kPoint.atDataIndex = [-1, -1];

                for (int i = 0; i < dataLen; i++) {
                    double x1 = 50.0;
                    double x2 = 60.0;
                    x1 = size.width - (dataLen - i) * kPoint.kItemWidth + gapX;
                    x2 = x1 + kPoint.kItemWidth - 1;
                    x1 += 1;
                    kPoint.kPointData[i]['x1'] = x1;
                    kPoint.kPointData[i]['x2'] = x2;
                }
                setAtDataIndex();
            });
        }
    }

    void onHorizontalDragUpdate(DragUpdateDetails details) {
        if (kPoint.initState) return;
        try {
            Size size = context.size;
            double firstX1 = kPoint.kPointData.first['x1'] +
                details.primaryDelta;
            double lastX2 = kPoint.kPointData.last['x2'] + details.primaryDelta;
            if (kPoint.kPointData.length > kPoint.atKNum &&
                lastX2 < (size.width - kPoint.kPaddingR) &&
                details.primaryDelta < 0) {
                return;
            }
            if (kPoint.kPointData.length > kPoint.atKNum && firstX1 > 0 &&
                details.primaryDelta > 0) {
                return;
            }
            setState(() {
                for (int i = 0; i < kPoint.kPointData.length; i++) {
                    kPoint.kPointData[i]['x1'] += details.primaryDelta;
                    kPoint.kPointData[i]['x2'] += details.primaryDelta;
                }
                setAtDataIndex();
            });
        } catch (e) {
            print(e);
        }
    }

    void initSize() {
        Size size = new Size(widget.width, widget.height);

        kPoint.yTotal = (size.height * kPoint.kHScale) - kPoint.kPaddingT;
        kPoint.yMin = kPoint.yTotal + kPoint.kPaddingT;
        kPoint.yMax = kPoint.kPaddingT;

        kPoint.vTotal = (size.height * kPoint.vHScale) - kPoint.vPaddingT;
        kPoint.vMin = kPoint.yMin + kPoint.vTotal + kPoint.vPaddingT;
        kPoint.vMax = kPoint.yMin + kPoint.vPaddingT;

        kPoint.iTotal = (size.height * kPoint.iHScale) - kPoint.iPaddingT -
            kPoint.iPaddingB;
        kPoint.iMin = kPoint.vMin + kPoint.iTotal + kPoint.iPaddingT;
        kPoint.iMax = kPoint.iMin - kPoint.iTotal;
        kPoint.atKNum = (size.width / kPoint.kItemWidth).ceil();
    }

    void init() {
        Size size = new Size(widget.width, widget.height);

        if (data.length <= 0) return;
//        setState(() {
            if (kPoint.initState) {
                kPoint.initState = false;

                initSize();

                int dataLen = data.length;
                List kPointData = [];
                for (int i = 0; i < dataLen; i++) {
                    double x1 = 50.0;
                    double y1 = 50.0;
                    double x2 = 60.0;
                    double y2 = 60.0;
                    double highY = 60.0;
                    double lowY = 50.0;

                    x1 = size.width - (dataLen - i) * kPoint.kItemWidth -
                        kPoint.kPaddingR;
                    x2 = x1 + kPoint.kItemWidth - kPoint.kItemGap;
                    x1 += kPoint.kItemGap;

                    Paint kPaintColor = new Paint();
                    if (data[i]["open"] >= data[i]["close"]) {
                        kPaintColor..color = kStyle.downColor;
                    } else {
                        kPaintColor..color = kStyle.upColor;
                    }

                    Map kItemData = {};
                    kItemData['x1'] = x1;
                    kItemData['y1'] = y1;
                    kItemData['x2'] = x2;
                    kItemData['y2'] = y2;
                    kItemData['highY'] = highY;
                    kItemData['lowY'] = lowY;
                    kItemData['close'] = data[i]['close'];
                    kItemData['open'] = data[i]['open'];
                    kItemData['high'] = data[i]['high'];
                    kItemData['highPrice'] = data[i]['high'];
                    kItemData['low'] = data[i]['low'];
                    kItemData['lowPrice'] = data[i]['low'];
                    kItemData['volume'] = data[i]['volume'];
                    kItemData['time'] = data[i]['time'];
                    kItemData['color'] = kPaintColor;
                    kItemData['date'] =
                        DateTime.fromMillisecondsSinceEpoch(kItemData['time']);
                    kPointData.add(kItemData);
                }
                kPlot.setPlot(kPointData);
                kPoint.kPointData = kPointData;
                kPlot.getMainPlot.showPlot(kPoint.kPointData);
                print(kPoint.kPointData.last);
            }
            setAtDataIndex(size:size);
//        });
    }

    void setAtDataIndex({Size size}) {
        if(size == null) {
            size = context.size;
        }
        kPoint.atDataIndex = [-1, -1];
        for (int i = 0; i < kPoint.kPointData.length; i++) {
            if (kPoint.atDataIndex[0] < 0 && kPoint.kPointData[i]['x2'] >= 0) {
                kPoint.atDataIndex[0] = i;
            }
            if (kPoint.atDataIndex[1] < 0 &&
                kPoint.kPointData[i]['x1'] > size.width) {
                kPoint.atDataIndex[1] = i > 0 ? i - 1 : 0;
            }
        }
        kPoint.atDataIndex[0] =
        kPoint.atDataIndex[0] < 0 ? 0 : kPoint.atDataIndex[0];
        kPoint.atDataIndex[1] =
        kPoint.atDataIndex[1] < 0 ? kPoint.kPointData.length - 1 : kPoint
            .atDataIndex[1];

        kPoint.tapIndexData = -1;

        priceChange();
        setKYPrice();
    }

    void setKYPrice() {
        for (int i = 0; i < kPoint.kPointData.length; i++) {
            if (i >= kPoint.atDataIndex[0] && i <= kPoint.atDataIndex[1]) {
                double y1 = 50.0;
                double y2 = 60.0;
                double vY1 = 50.0;
                double vY2 = 60.0;
                double highY = 60.0;
                double lowY = 50.0;
                y1 = getY(kPoint.kPointData[i]["open"]);
                y2 = getY(kPoint.kPointData[i]["close"]);
                highY = getY(kPoint.kPointData[i]["high"]);
                lowY = getY(kPoint.kPointData[i]["low"]);

//        vY1 = kPoint.vMin - kPoint.kPointData[i]["volume"] / kPoint.vMaxNum * kPoint.vTotal;
                vY1 = getY(kPoint.kPointData[i]["volume"], 2);
                vY2 = kPoint.vMin;

                if ((y1 - y2).abs() <= 1) {
                    y2 = y1 + 0.5;
                }

                if ((vY1 - vY2).abs() <= 1) {
                    vY2 = vY1 + 0.5;
                }

                kPoint.kPointData[i]['y1'] = y1;
                kPoint.kPointData[i]['y2'] = y2;
                kPoint.kPointData[i]['highY'] = highY;
                kPoint.kPointData[i]['lowY'] = lowY;
                kPoint.kPointData[i]['vY1'] = vY1;
                kPoint.kPointData[i]['vY2'] = vY2;

                if (kPlot.mainActive >= 0) {
                    kPlot.getMainNameList.forEach((name) {
                        if (kPoint.kPointData[i][name] is double) {
                            kPoint.kPointData[i][name + 'Y'] =
                                getY(kPoint.kPointData[i][name]);
                        }
                    });
                }
                if (kPlot.viceActive >= 0) {
                    kPlot.getViceNameList.forEach((name) {
                        if (kPoint.kPointData[i][name] is double) {
                            if (name == 'macd') {
                                kPoint.kPointData[i][name + 'Y1'] = getY(0, 3);
                            }
                            kPoint.kPointData[i][name + 'Y'] =
                                getY(kPoint.kPointData[i][name], 3);
                        }
                    });
                }

                double klineX = (kPoint.kPointData[i]['x2'] -
                    kPoint.kPointData[i]['x1']) / 2 +
                    kPoint.kPointData[i]['x1'];
                kPoint.kPointData[i]['klineX'] = klineX;
            }
        }
    }

    double getY(double num, [int type = 1]) {
        double y = 0.0;
        if (num is double) {
            if (type == 2) {
                y = kPoint.vMin - num / kPoint.vMaxNum * kPoint.vTotal;
            } else if (type == 3) {
                y = kPoint.iMin -
                    (num - kPoint.iMinNum) / kPoint.iGapNum * kPoint.iTotal;
            } else {
                y = kPoint.yMin -
                    (num - kPoint.lowPrice) / kPoint.gapPrice * kPoint.yTotal;
            }
        }
        return y;
    }

    void yTextPointDataChange() {
        List yText = [];
        List vText = [];
        yText.add({
            "text": kPoint.lowPrice.toStringAsFixed(kPoint.priceFixed)
                .toString(),
            "y": kPoint.yMin,
        });
        var yMean = kPoint.gapPrice / kPoint.yTextNum;
        for (var yPrice = 1; yPrice <= kPoint.yTextNum; yPrice ++) {
            yText.add({
                "text": (yMean * yPrice + kPoint.lowPrice).toStringAsFixed(
                    kPoint.priceFixed),
                "y": (kPoint.yTextNum - yPrice) *
                    (kPoint.yTotal / kPoint.yTextNum) + kPoint.kPaddingT,
            });
        }

        vText.add({
            "text": kPoint.vMaxNum.toStringAsFixed(kPoint.volumeFixed)
                .toString(),
            "y": kPoint.vMax,
        });

        kPoint.yTextPointData = yText;
        kPoint.yTextVData = vText;
    }

    void priceChange() {
        kPoint.highPrice = 0.0;
        kPoint.lowPrice = 0.0;
        kPoint.vMaxNum = 0.0;
        kPoint.iMaxNum = 0.0;
        kPoint.iMinNum = 0.0;

        kPoint.kMaxPriceIndex = -1;
        kPoint.kMinPriceIndex = -1;

        for (int i = kPoint.atDataIndex[0]; i <= kPoint.atDataIndex[1]; i++) {
            double l = kPoint.kPointData[i]["lowPrice"];
            double h = kPoint.kPointData[i]["highPrice"];
            double v = kPoint.kPointData[i]["volume"];

            if (kPoint.lowPrice == 0 || l < kPoint.lowPrice) {
                kPoint.lowPrice = l;
                kPoint.kMinPriceIndex = i;
            }

            if (h > kPoint.highPrice) {
                kPoint.highPrice = h;
                kPoint.kMaxPriceIndex = i;
            }

            if (v > kPoint.vMaxNum) {
                kPoint.vMaxNum = v;
            }

            kPlot.getViceNameList.forEach((name) {
                if (kPoint.kPointData[i][name] > kPoint.iMaxNum) {
                    kPoint.iMaxNum = kPoint.kPointData[i][name];
                }
                if (kPoint.kPointData[i][name] < kPoint.iMinNum) {
                    kPoint.iMinNum = kPoint.kPointData[i][name];
                }
            });
        }
        kPoint.lowPrice -= kPoint.lowPrice * 0.002;
        kPoint.highPrice += kPoint.highPrice * 0.002;
        kPoint.gapPrice = kPoint.highPrice - kPoint.lowPrice;
        kPoint.iGapNum = kPoint.iMaxNum - kPoint.iMinNum;
        yTextPointDataChange();
    }
}
