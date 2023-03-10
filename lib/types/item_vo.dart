import 'package:file_manager/types/tag_vo.dart';

import '../database/database.dart';
import 'package:drift/drift.dart' as drift;

import 'author_vo.dart';

/// 所有 Items 视图层对象
class ItemsVO {
  /// 唯一键，对应数据库ID
  final int id;

  final EntityItem entityItem;
  final List<EntityAuthor> entityAuthorList = [];
  final List<EntityTag> entityTagList = [];

  /// 当前对象缓存
  static final Map<int, ItemsVO> _cache = <int, ItemsVO>{};

  factory ItemsVO(int id, EntityItem entityItem) {
    var _ = _cache.putIfAbsent(id, () => ItemsVO._internal(id, entityItem));
    return _;
  }

  ItemsVO._internal(this.id, this.entityItem);

  /// 新增作者
  static void addAuthor(int id, EntityAuthor entityAuthor) {
    getItemVO(id).entityAuthorList.add(entityAuthor);
  }

  /// 新增作者，通过数据创建 EntityAuthor 对象
  static void addAuthorByCreate(int id, int authorId, String authorName) {
    addAuthor(id, EntityAuthor(id: authorId, name: authorName));
  }

  /// 新增Tag
  static void addTag(int id, EntityTag entityTag) {
    getItemVO(id).entityTagList.add(entityTag);
  }

  /// 新增Tag，通过数据创建 EntityTag 对象
  static void addTagByCreate(int id, int tagId, String tagString) {
    addTag(id, EntityTag(id: tagId, tag: tagString));
  }

  /// 通过ID获取值
  static ItemsVO getItemVO(int id) {
    return _cache[id]!;
  }

  /// Id倒排
  static List<int> getItemVOIds() {
    List<int> tmpList = _cache.keys.toList();
    tmpList.sort((a, b) => b - a); // 倒序排序
    return tmpList;
  }

  /// 通过id列表顺序获取数据
  /// 过滤、查询、分组用
  static Iterable<ItemsVO> getItemVOListByIds(List<int> ids) {
    return ids.map((id) => getItemVO(id));
  }

  /// 默认获取所有的List
  static Iterable<ItemsVO> getItemVOList() {
    return _cache.values;
  }

  /// 初始化数据
  static Future<void> init(MyDatabase thisDB) async {
    clear();

    /// 开始初始化
    var resultEntityItems = await (thisDB.select(thisDB.entityItems).join([
      drift.leftOuterJoin(thisDB.relationItemAuthors,
          thisDB.relationItemAuthors.itemId.equalsExp(thisDB.entityItems.id)),
      drift.leftOuterJoin(thisDB.relationItemTags,
          thisDB.relationItemTags.itemId.equalsExp(thisDB.entityItems.id))
    ])).get();

    for (var row in resultEntityItems) {
      /// 永不为null
      final entry = row.readTable(thisDB.entityItems);
      ItemsVO(entry.id!, entry);
      final authors = row.readTableOrNull(thisDB.relationItemAuthors);
      if (authors != null &&
          !ItemsVO.getItemVO(entry.id!)
              .entityAuthorList
              .map((e) => e.id)
              .toList()
              .contains(authors.authorId)) {
        ItemsVO.addAuthorByCreate(entry.id!, authors.authorId,
            AuthorsVO.getItemVO(authors.authorId).entityAuthor.name);
      }
      final tags = row.readTableOrNull(thisDB.relationItemTags);
      if (tags != null &&
          !ItemsVO.getItemVO(entry.id!)
              .entityTagList
              .map((e) => e.id)
              .toList()
              .contains(tags.tagId)) {
        ItemsVO.addTagByCreate(
            entry.id!, tags.tagId, TagsVO.getItemVO(tags.tagId).entityTag.tag);
      }
    }
  }

  /// 清除缓存
  static void clear() {
    _cache.clear();
  }
}
