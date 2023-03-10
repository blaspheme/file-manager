import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../utils/file.dart';

/// Screen that shows an example of openFiles
class OpenFilePage extends StatefulWidget {
  Function setFileURL; // 设置文件URL和后缀
  String dirPath; // 保存的路径（文件夹）名称
  String buttonName = "上传"; // 按钮名称
  String customFileName = ""; //自定义文件名

  OpenFilePage(
      this.setFileURL, this.dirPath, this.buttonName, this.customFileName,
      {super.key});

  @override
  State<StatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<OpenFilePage> {
  String _path = "";

  Future<void> _openImageFile(BuildContext context) async {
    // #docregion SingleOpen
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['*'],
    );
    final XFile? file =
        await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    // #enddocregion SingleOpen
    if (file == null) {
      // Operation was canceled by the user.
      return;
    }
    String fileName = file.name;
    final String filePath = file.path;
    final String ext = fileName.split('.').last.toLowerCase();

    if (widget.customFileName.isNotEmpty) {
      // 传入自定义名称，则修改名称
      fileName = "${widget.customFileName}.$ext";
    }

    var newPath = await moveFile(filePath, fileName, widget.dirPath);
    setState(() {
      _path = newPath;
    });
    widget.setFileURL(newPath, ext);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            // ignore: deprecated_member_use
            primary: Colors.blue,
            // ignore: deprecated_member_use
            onPrimary: Colors.white,
          ),
          child: Text(widget.buttonName),
          onPressed: () => _openImageFile(context),
        ),
        Text(_path),
      ],
    );
  }
}
