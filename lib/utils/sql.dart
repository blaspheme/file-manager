import 'package:drift/drift.dart';
import 'package:file_manager/database/database.dart';
import 'package:file_manager/utils/set.dart';

/// 同步 Item 和 Author 的关系表
Future<void> syncRelationItemAuthors(
    MyDatabase thisDB, int itemId, List<int> newList, List<int> oldList) async {
  List<int> addList = makeDifferenceBySet(newList, oldList);
  List<int> deleteList = makeDifferenceBySet(oldList, newList);

  for (var i in addList) {
    await thisDB.relationItemAuthors
        .insertOne(RelationItemAuthor(itemId: itemId, authorId: i));
  }

  for (var i in deleteList) {
    await thisDB.relationItemAuthors.deleteWhere(
        (tbl) => tbl.itemId.equals(itemId) & tbl.authorId.equals(i));
  }
}

/// 同步 Item 和 Tag 的关系表
Future<void> syncRelationItemTags(
    MyDatabase thisDB, int itemId, List<int> newList, List<int> oldList) async {
  List<int> addList = makeDifferenceBySet(newList, oldList);
  List<int> deleteList = makeDifferenceBySet(oldList, newList);

  for (var i in addList) {
    await thisDB.relationItemTags
        .insertOne(RelationItemTag(itemId: itemId, tagId: i));
  }

  for (var i in deleteList) {
    await thisDB.relationItemTags
        .deleteWhere((tbl) => tbl.itemId.equals(itemId) & tbl.tagId.equals(i));
  }
}
