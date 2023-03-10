import 'package:flutter/material.dart';

/// 让单元格出现滚动条
class ScrollableDataCell extends StatelessWidget {
  final Widget child;

  const ScrollableDataCell(this.child, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Scrollbar(
        controller: scrollController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: scrollController,
          child: SizedBox(
            child: child,
          ),
        ));
  }
}
