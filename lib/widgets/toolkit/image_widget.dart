import 'dart:io';

import 'package:flutter/material.dart';

import '../../utils/file.dart';

class LocalFile extends StatefulWidget {
  final String imgPath;

  const LocalFile(this.imgPath, {super.key});

  @override
  State<StatefulWidget> createState() => _LocalFileState();
}

class _LocalFileState extends State<LocalFile> {
  String absolutePath = "";

  @override
  void initState() {
    super.initState();
    setAbsolutePath();
  }

  void setAbsolutePath() async {
    if (widget.imgPath.isNotEmpty) {
      absolutePath = await getAbsolutePath(widget.imgPath);
    } else {
      absolutePath = widget.imgPath;
    }

    setState(() {
      absolutePath = absolutePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return absolutePath.isEmpty
        ? const Icon(Icons.image_not_supported)
        : Image.file(
            File(absolutePath),
            width: 200.0,
            height: 200.0,
          );
  }
}
