import 'dart:io';

import 'package:drift/drift.dart';

import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

// assuming that your file is called filename.dart. This will give an error at
// first, but it's needed for drift to know about the generated code
part 'database.g.dart';

const _uuid = Uuid();

// 表定义
class EntityItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get isbn10 => text()();
  TextColumn get isbn13 => text()();
  TextColumn get publisher => text()();
  TextColumn get publishDate => text()();
  IntColumn get rank => integer()();
  TextColumn get description => text()(); //描述
  DateTimeColumn get createdAt => dateTime().withDefault(currentDate)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDate)();
}

class EntityFiles extends Table {
  TextColumn get id => text().unique().clientDefault(() => _uuid.v4())();
  TextColumn get fileName => text()(); //文件名
  TextColumn get fileType => text()(); // 文件类型
  TextColumn get description => text()(); //描述
  DateTimeColumn get createdAt => dateTime().withDefault(currentDate)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDate)();
}

class EntityAuthors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); //人名
  TextColumn get nationality => text()(); // 国籍
  TextColumn get birthDate => text()(); //出生日期
  TextColumn get deathDate => text()(); //死亡日期
  TextColumn get description => text()(); //简介
  DateTimeColumn get createdAt => dateTime().withDefault(currentDate)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDate)();
}

class EntityTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tag => text()(); //tag
  TextColumn get description => text()(); //描述
  DateTimeColumn get createdAt => dateTime().withDefault(currentDate)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDate)();
}

// 关系表
class RelationItemFiles extends Table {
  IntColumn get itemId => integer().references(EntityItems, #id)();
  TextColumn get fileId => text().references(EntityFiles, #id)();
  TextColumn get description => text()(); //描述
  DateTimeColumn get createdAt => dateTime().withDefault(currentDate)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDate)();
  @override
  List<Set<Column>> get uniqueKeys => [
        {itemId, fileId}
      ];
}

class RelationItemAuthors extends Table {
  IntColumn get itemId => integer().references(EntityItems, #id)();
  IntColumn get authorId => integer().references(EntityAuthors, #id)();
  TextColumn get description => text()(); //描述
  DateTimeColumn get createdAt => dateTime().withDefault(currentDate)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDate)();
  @override
  List<Set<Column>> get uniqueKeys => [
        {itemId, authorId}
      ];
}

class RelationItemTags extends Table {
  IntColumn get itemId => integer().references(EntityItems, #id)();
  IntColumn get tagId => integer().references(EntityTags, #id)();
  TextColumn get description => text()(); //描述
  DateTimeColumn get createdAt => dateTime().withDefault(currentDate)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDate)();
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

  // Stream<List<Item>> watchAllItems() {
  //   print('................................');
  //   return (select(items)).watch();
  // }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'file_manager', 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
