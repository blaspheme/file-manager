import '../database/database.dart';

/// 所有 Items 视图层对象
class FilesVO {
  /// 唯一键，对应数据库 id(uuid)
  final String id;

  final EntityFile entityFile;

  /// 当前对象缓存
  static final Map<String, FilesVO> _cache = <String, FilesVO>{};

  factory FilesVO(String id, EntityFile entityFile) {
    var _ = _cache.putIfAbsent(id, () => FilesVO._internal(id, entityFile));
    return _;
  }

  FilesVO._internal(this.id, this.entityFile);

  /// 通过ID获取值
  static FilesVO getItemVO(String id) {
    return _cache[id]!;
  }

  static List<EntityFile> getEntityFileList() {
    return _cache.values.map((e) => e.entityFile).toList();
  }

  /// 初始化数据
  static Future<void> init(MyDatabase thisDB) async {
    clear();

    /// 开始初始化
    var resultEntityItems = await (thisDB.select(thisDB.entityFiles)).get();
    for (var row in resultEntityItems) {
      FilesVO(row.id!, row);
    }
  }

  /// 通过id列表顺序获取数据
  /// 过滤、查询、分组用
  static Iterable<FilesVO> getItemVOListByIds(List<String> ids) {
    return ids.map((id) => getItemVO(id));
  }

  /// 清除缓存
  static void clear() {
    _cache.clear();
  }
}
