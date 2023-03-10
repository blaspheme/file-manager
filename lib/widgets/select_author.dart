import 'package:file_manager/types/author_vo.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';

class AuthorSelect extends StatefulWidget {
  List<int> authorIdList; // 传参
  Function setAuthorIdList;

  AuthorSelect(this.authorIdList, this.setAuthorIdList, {super.key});

  @override
  State createState() => _AuthorSelectState();
}

class _AuthorSelectState extends State<AuthorSelect> {
  final List<EntityAuthor> _authorsList = <EntityAuthor>[];
  final List<EntityAuthor> _authorsSelectedList = <EntityAuthor>[];
  int _selectedId = 0; //下拉框选择的ID

  @override
  void initState() {
    super.initState();
    getData();
  }

  ///初始化数据
  void getData({bool refreashFlag = false}) {
    var resultList = AuthorsVO.getEntityAuthorList();
    setState(() {
      var tmpSelectedList = _authorsSelectedList.map((e) => e.id);
      // 重新构建下拉框数据
      _authorsList.clear();
      for (var result in resultList) {
        // 手动刷新，增加上级组件传值
        if (!refreashFlag && widget.authorIdList.contains(result.id)) {
          _authorsSelectedList.add(result);
        }
        // 以前的状态过滤
        if (!tmpSelectedList.contains(result.id)) {
          _authorsList.add(result);
        }
      }
    });
  }

  /// 刷新数据
  void doRefresh() async {
    var thisDB = Provider.of<MyDatabase>(context, listen: false);
    await AuthorsVO.init(thisDB);
    getData(refreashFlag: true);
  }

  Iterable<Widget> get actorWidgets {
    return _authorsSelectedList.map((EntityAuthor author) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Chip(
          // avatar: CircleAvatar(child: Text(author.imageUrl)),
          label: Text(author.name),
          onDeleted: () {
            setState(() {
              _authorsSelectedList.removeWhere((EntityAuthor entry) {
                return entry.id == author.id;
              });
              _authorsList.add(author);
              saveAuthorIdList();
            });
          },
        ),
      );
    });
  }

  Iterable<DropDownValueModel> get dropDownList {
    return _authorsList.map((EntityAuthor author) {
      return DropDownValueModel(name: author.name, value: author.id.toString());
    });
  }

  saveAuthorIdList() {
    List<int> newAuthorIdList = _authorsSelectedList.map((e) => e.id!).toList();
    widget.setAuthorIdList(newAuthorIdList);
  }

  @override
  Widget build(BuildContext context) {
    /// 保存按钮
    void save() {
      if (_selectedId < 1) {
        return;
      }
      for (var e in _authorsList) {
        if (e.id == _selectedId) {
          setState(() {
            _authorsSelectedList.add(e);
            _authorsList.removeWhere((EntityAuthor entry) {
              return entry.id == _selectedId;
            });
          });
          break;
        }
      }
      saveAuthorIdList();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropDownTextField(
                controller: SingleValueDropDownController(),
                textFieldDecoration: const InputDecoration(hintText: "作者..."),
                clearOption: true,
                enableSearch: true,
                dropdownColor: Colors.amber[50],
                searchDecoration: const InputDecoration(hintText: "查询作者..."),
                validator: (value) {
                  if (value == null) {
                    return "Required field";
                  } else {
                    return null;
                  }
                },
                dropDownItemCount: 6,
                dropDownList: dropDownList.toList(),
                onChanged: (val) {
                  _selectedId = int.parse(val.value);
                },
              ),
            ),
            TextButton(onPressed: save, child: const Text('增加')),
            TextButton(
                child: const Text('新增作者'),
                onPressed: () {
                  Navigator.pushNamed(context, "author/edit",
                      arguments: <String, int>{'id': 0});
                }),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                doRefresh();
              },
            ),
          ],
        ),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    children: actorWidgets.toList(),
                  ),
                )
              ],
            ),
          ],
        )
      ],
    );
  }
}
