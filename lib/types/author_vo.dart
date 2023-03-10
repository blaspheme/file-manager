import '../database/database.dart';
import 'package:drift/drift.dart' as drift;

/// 所有 Items 视图层对象
class AuthorsVO {
  /// 唯一键，对应数据库ID
  final int id;

  final EntityAuthor entityAuthor;

  /// 当前对象缓存
  static final Map<int, AuthorsVO> _cache = <int, AuthorsVO>{};

  factory AuthorsVO(int id, EntityAuthor entityAuthor) {
    var _ = _cache.putIfAbsent(id, () => AuthorsVO._internal(id, entityAuthor));
    return _;
  }

  AuthorsVO._internal(this.id, this.entityAuthor);

  /// 通过ID获取值
  static AuthorsVO getItemVO(int id) {
    return _cache[id]!;
  }

  /// 初始化数据
  static Future<void> init(MyDatabase thisDB) async {
    clear();

    /// 开始初始化
    var resultEntityItems = await (thisDB.select(thisDB.entityAuthors)).get();

    for (var row in resultEntityItems) {
      AuthorsVO(row.id!, row);
    }
  }

  /// 默认获取所有的List
  static Iterable<AuthorsVO> getAuthorsVOList() {
    return _cache.values;
  }

  static List<EntityAuthor> getEntityAuthorList() {
    return _cache.values.map((e) => e.entityAuthor).toList();
  }

  /// 清除缓存
  static void clear() {
    _cache.clear();
  }
}
