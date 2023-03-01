import 'package:flutter/material.dart';

class ItemEdit extends StatelessWidget {
  const ItemEdit({super.key});

  @override
  Widget build(BuildContext context) {
    //获取路由参数
    var args = ModalRoute.of(context)!.settings.arguments;
    print(args);
    return Scaffold(
        appBar: AppBar(
          title: Text("Item Edit"),
        ),
        body: Center(
            child: TextButton(
                child: Text("ccc"),
                onPressed: () {
                  Navigator.pop(context);
                })));
  }
}
