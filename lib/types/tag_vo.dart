import '../database/database.dart';

/// 所有 Items 视图层对象
class TagsVO {
  /// 唯一键，对应数据库ID
  final int id;

  final EntityTag entityTag;

  /// 当前对象缓存
  static final Map<int, TagsVO> _cache = <int, TagsVO>{};

  factory TagsVO(int id, EntityTag entityTag) {
    var _ = _cache.putIfAbsent(id, () => TagsVO._internal(id, entityTag));
    return _;
  }

  TagsVO._internal(this.id, this.entityTag);

  /// 通过ID获取值
  static TagsVO getItemVO(int id) {
    return _cache[id]!;
  }

  static List<EntityTag> getEntityTagList() {
    return _cache.values.map((e) => e.entityTag).toList();
  }

  /// 初始化数据
  static Future<void> init(MyDatabase thisDB) async {
    clear();

    /// 开始初始化
    var resultEntityItems = await (thisDB.select(thisDB.entityTags)).get();

    for (var row in resultEntityItems) {
      TagsVO(row.id!, row);
    }
  }

  /// 清除缓存
  static void clear() {
    _cache.clear();
  }
}
