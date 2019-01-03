import 'package:flutter/material.dart';
import 'package:candlesticks/gudashi/k_line.dart';


class KStyle {
  KStyle();

  /// 涨K线颜色
  Color upColor = Colors.redAccent;

  /// 跌K线颜色
  Color downColor = Colors.greenAccent;

  /// 背景颜色
  Color bgColor = const Color(0xff21232e);

  /// 边界线颜色
  Color borderColor = const Color(0xff404040);

  /// Y价格字体字体颜色
  Color fontColor = Colors.blueGrey;
  /// 当前屏幕最大最小价格字体颜色
  Color priceMinMaxFontColor = Colors.white;
  /// 当前屏幕最大最小价格线颜色
  Color priceMinMaxBorderColor = Colors.white;
  /// Y价格字体字体大小
  double fontSize = 8.0;
  /// 当前屏幕最大最小价格
  double priceMinMaxFontSize = 8.0;
  /// Y价格字体是否加粗
  FontWeight fontWeight = FontWeight.normal;
  /// 当前屏幕最大最小价格字体是否加粗
  FontWeight priceMinMaxFontWeight = FontWeight.normal;

  /// 选中K线 文本框背景色
  Color tapTextBackgroundColor = const Color(0xff21232e).withOpacity(0.9);
  /// 选中K线 字体颜色
  Color tapTextFontColor = Colors.white.withOpacity(0.5);
  /// 选中K线 文本框边框颜色
  Color tapTextBorderColor = Colors.white.withOpacity(0.4);

  /// 选中K线 active RadialColor
  List<Color> tapRadialColor = [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)];
  /// 选中K线 active ColorStops
  List<double> tapRadialColorStops = [0.0, 0.2];

  /// 选中K线 文本 字体大小
  double tapTextSize = 8.0;
}

class KPoint {
  KPoint();

  /// y轴保留小数位
  int priceFixed = 6;
  int volumeFixed = 6;

  /// y轴主图最小值
  double yMin = 0.0;
  /// y轴主图最大值
  double yMax = 0.0;
  /// y轴主图最大和最小差距
  double yTotal = 0.0;

  /// y轴成交量最小值
  double vMin = 0.0;
  /// y轴成交量最大值
  double vMax = 0.0;
  /// y轴成交量最大和最小差距
  double vTotal = 0.0;

  /// y轴指标最小值
  double iMin = 0.0;
  /// y轴指标最大值
  double iMax = 0.0;
  /// y轴指标最大和最小差距
  double iTotal = 0.0;

  /// K线高度比例
  double kHScale = 0.6;
  /// 成交量高度比例
  double vHScale = 0.2;
  /// 指标高度比例
  double iHScale = 0.2;

  /// K线距离顶部高度
  double kPaddingT = 40.0;
  /// 成交量距离顶部高度
  double vPaddingT = 10.0;
  /// 指标距离顶部高度
  double iPaddingT = 10.0;
  /// 指标距离顶部高度
  double iPaddingB = 3.0;
  /// K线距离右边高度
  double kPaddingR = 80.0;

  /// K线宽度
  double kItemWidth = 10.0;
  /// 记录K线宽度
  double kItemWidthRecord;
  /// 缩放 kItemWidth 速度比例
  double scale = 8.0;
  /// 最小
  double kItemWidthMin = 5.0;
  /// 间距
  double kItemGap = 1.0;

  /// 最大
  double kItemWidthMax = 20.0;
  /// 缩放时当前位置
  int scaleIndexKPoint = -1;
  double scaleIndexKFocalPointDx = 0.0;

  /// 当前最高最低 data index
  int kMaxPriceIndex = -1;
  int kMinPriceIndex = -1;
  double kMinMaxPriceCircle = 3;
  int kPriceBorderW = 20;

  /// K线是否初始化
  bool initState = true;

  /// 当前K线个数
  int atKNum = 0;
  /// 当前K线 data 位置索引
  List<int> atDataIndex = [0, 0];

  /// 最高价格 List
  List highPriceList = [];
  /// 最低价格 List
  List lowPriceList = [];
  /// 最高价格
  double highPrice = 0.0;
  /// 最低价格
  double lowPrice = 0.0;
  /// 价格间隔
  double gapPrice = 0.0;

  /// 最大成交量
  double vMaxNum = 0.0;

  /// 指标最大值
  double iMaxNum = 0.0;
  /// 指标最小值
  double iMinNum = 0.0;
  /// 指标总大小
  double iGapNum = 0.0;

  /// y轴 text
  List yText = [];
  /// y轴个数
  int yTextNum = 3;
  /// y轴 text 边界距离
  double yTextPadding = 3;

  /// x轴线条数
  int xAxisNum = 4;

  /// K线坐标
  List kPointData = [];

  /// y轴 text 坐标
  List yTextPointData = [];
  /// y轴成交量 text 坐标
  List yTextVData = [];

  /// 选中K线 文本 data index
  int tapIndexData = -1;
  /// 选中K线 文本 top
  double tapTextTop = 20.0;
  /// 选中K线 文本 left
  double tapTextLeft = 5.0;
  /// 选中K线 文本 right
  double tapTextRight = 5.0;

  /// 选中K线 文本框宽度
  double tapTextWidth = 120.0;
  /// 选中K线 文本 行高
  double tapTextHeight = 1.4;

  /// 选中K线 主指标文本 top
  double kPlotTextTop = 10.0;
  /// 选中K线 主指标文本 left
  double kPlotTextLeft = 10.0;
}



class KLang {

  KLang({
    this.date = '时间',
    this.open = '开盘价',
    this.close = '收盘价',
    this.high = '最高价',
    this.low = '最底价',
    this.fluctuatePrice = '涨跌额',
    this.fluctuatePercent = '涨跌幅',
    this.volume = '成交量',
  });

  String date;
  String open;
  String close;
  String high;
  String low;
  String volume;
  String fluctuatePercent;
  String fluctuatePrice;
}



/// K线 InheritedWidget
class KInherited extends InheritedWidget {
  KInherited({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  final KChartsState data;

  @override
  bool updateShouldNotify(KInherited oldWidget) {
    return true;
  }
}