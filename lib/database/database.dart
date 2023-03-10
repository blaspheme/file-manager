import 'dart:io';

import 'package:drift/drift.dart';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../utils/file.dart';

// assuming that your file is called filename.dart. This will give an error at
// first, but it's needed for drift to know about the generated code
part 'database.g.dart';

const _uuid = Uuid();

// 表定义
class EntityItems extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get imageUrl => text().nullable()(); // 图片URL
  TextColumn get isbn10 => text().nullable()();
  TextColumn get isbn13 => text().nullable()();
  TextColumn get publisher => text().nullable()();
  TextColumn get publishDate => text().nullable()();
  IntColumn get rank => integer()(); //评分，10分制
  IntColumn get progress =>
      integer().withDefault(const Constant(0)).nullable()(); // 进度，百分制
  TextColumn get description => text().nullable()(); //描述
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDate)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDate)();
}

class EntityFiles extends Table {
  TextColumn get id => text().nullable().clientDefault(() => _uuid.v4())();
  TextColumn get fileName => text().nullable()(); //文件名
  TextColumn get fileType => text().nullable()(); // 文件类型
  TextColumn get description => text().nullable()(); //描述
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDate)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDate)();

  @override
  Set<Column> get primaryKey => {id};
}

class EntityAuthors extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();
  TextColumn get name => text()(); //人名
  TextColumn get imageUrl => text().nullable()(); // 图片URL
  TextColumn get nationality => text().nullable()(); // 国籍
  TextColumn get birthDate => text().nullable()(); //出生日期
  TextColumn get deathDate => text().nullable()(); //死亡日期
  TextColumn get description => text().nullable()(); //简介
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDate)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDate)();
}

class EntityTags extends Table {
  IntColumn get id => integer().nullable().autoIncrement()();
  TextColumn get tag => text()(); //tag
  TextColumn get description => text().nullable()(); //简介
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDate)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDate)();
}

// 关系表
class RelationItemFiles extends Table {
  IntColumn get itemId => integer().references(EntityItems, #id)();
  TextColumn get fileId => text().references(EntityFiles, #id)();
  IntColumn get fileOrder =>
      integer().withDefault(const Constant(0)).nullable()(); // Item内文件顺序
  TextColumn get description => text().nullable()(); //描述
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDate)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDate)();
  @override
  List<Set<Column>> get uniqueKeys => [
        {itemId, fileId}
      ];
}

class RelationItemAuthors extends Table {
  IntColumn get itemId => integer().references(EntityItems, #id)();
  IntColumn get authorId => integer().references(EntityAuthors, #id)();
  TextColumn get description => text().nullable()(); //描述
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDate)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDate)();
  @override
  List<Set<Column>> get uniqueKeys => [
        {itemId, authorId}
      ];
}

class RelationItemTags extends Table {
  IntColumn get itemId => integer().references(EntityItems, #id)();
  IntColumn get tagId => integer().references(EntityTags, #id)();
  TextColumn get description => text().nullable()(); //描述
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDate)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDate)();
  @override
  List<Set<Column>> get uniqueKeys => [
        {itemId, tagId}
      ];
}

// this annotation tells drift to prepare a database class that uses both of the
// tables we just defined.
@DriftDatabase(tables: [
  EntityFiles,
  EntityFiles,
  EntityAuthors,
  EntityTags,
  RelationItemFiles,
  RelationItemAuthors,
  RelationItemTags
])
class MyDatabase extends _$MyDatabase {
  // we tell the database where to store the data with this constructor
  MyDatabase() : super(_openConnection());

  // you should bump this number whenever you change or add a table definition.
  // Migrations are covered later in the documentation.
  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    var basePath = await getBasePath();
    final file = File(p.join(basePath, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
