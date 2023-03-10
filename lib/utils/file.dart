import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// 获得项目的基本路径
///
/// 参数：
/// * [projectPath]:项目路径
Future<String> getBasePath({String? projectPath = 'file_manager'}) async {
  final dbFolder = await getApplicationDocumentsDirectory();
  Directory destDir = Directory(p.join(dbFolder.path, projectPath));
  if (!await destDir.exists()) {
    await destDir.create(recursive: true);
  }
  return destDir.path;
}

/// 移动文件路径
///
/// 参数：
/// * [sourcePath]: 源文件绝对路径
/// * [fileName]: 文件名
/// * [folderPath]: 待移动文件夹名字
Future<String> moveFile(
    String sourcePath, String fileName, String folderPath) async {
  var dbFolder = await getBasePath();
  var file = p.join(dbFolder, folderPath);
  var destPath = file;
  Directory destDir = Directory(destPath);
  if (!await destDir.exists()) {
    await destDir.create(recursive: true);
  }
  await File(sourcePath).rename(p.join(destPath, fileName)); // 移动
  return p.join(folderPath, fileName); // 但会相对路径
}

Future<String> getAbsolutePath(String relativePath) async {
  String basePath = await getBasePath();
  return p.join(basePath, relativePath);
}

Future<void> copyFile(
    String folderPath, String uuidFile, String fileName) async {
  String basePath = await getBasePath();
  String currentPath = p.join(basePath, folderPath, uuidFile);
}
