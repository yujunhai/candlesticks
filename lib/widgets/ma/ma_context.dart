import 'package:flutter/material.dart';

class MaContext extends InheritedWidget {
  final Function(int count, double value, double currentValue) onMaChange;

  MaContext({
    Key key,
    @required Widget child,
    @required this.onMaChange,
  }) : super(key: key, child: child);

  static MaContext of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(MaContext);
  }

  //是否重建widget就取决于数据是否相同
  @override
  bool updateShouldNotify(MaContext oldWidget) {
    return onMaChange != oldWidget.onMaChange;
  }
}
