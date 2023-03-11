import 'package:file_manager/types/tag_vo.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';

class TagSelect extends StatefulWidget {
  List<int> tagIdList; // 传参
  Function setTagIdList;

  TagSelect(this.tagIdList, this.setTagIdList, {super.key});

  @override
  State createState() => _TagSelectState();
}

class _TagSelectState extends State<TagSelect> {
  final List<EntityTag> _tagsList = <EntityTag>[];
  final List<EntityTag> _tagsSelectedList = <EntityTag>[];
  int _selectedId = 0; //下拉框选择的ID

  @override
  void initState() {
    super.initState();
    getData();
  }

  ///初始化数据
  void getData({bool refreashFlag = false}) {
    var resultList = TagsVO.getEntityTagList();
    setState(() {
      var tmpSelectedList = _tagsSelectedList.map((e) => e.id);
      // 重新构建下拉框数据
      _tagsList.clear();
      for (var result in resultList) {
        // 手动刷新，增加上级组件传值
        if (!refreashFlag && widget.tagIdList.contains(result.id)) {
          _tagsSelectedList.add(result);
        }
        // 以前的状态过滤
        if (!tmpSelectedList.contains(result.id)) {
          _tagsList.add(result);
        }
      }
    });
  }

  /// 刷新数据
  void doRefresh() async {
    var thisDB = Provider.of<MyDatabase>(context, listen: false);
    await TagsVO.init(thisDB);
    getData(refreashFlag: true);
  }

  Iterable<Widget> get actorWidgets {
    return _tagsSelectedList.map((EntityTag tag) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Chip(
          // avatar: CircleAvatar(child: Text(author.imageUrl)),
          label: Text(tag.tag),
          onDeleted: () {
            setState(() {
              _tagsSelectedList.removeWhere((EntityTag entry) {
                return entry.id == tag.id;
              });
              _tagsList.add(tag);
              saveAuthorIdList();
            });
          },
        ),
      );
    });
  }

  Iterable<DropDownValueModel> get dropDownList {
    return _tagsList.map((EntityTag tag) {
      return DropDownValueModel(name: tag.tag, value: tag.id.toString());
    });
  }

  saveAuthorIdList() {
    List<int> newAuthorIdList = _tagsSelectedList.map((e) => e.id!).toList();
    widget.setTagIdList(newAuthorIdList);
  }

  @override
  Widget build(BuildContext context) {
    /// 保存按钮
    void save() {
      if (_selectedId < 1) {
        return;
      }
      for (var e in _tagsList) {
        if (e.id == _selectedId) {
          setState(() {
            _tagsSelectedList.add(e);
            _tagsList.removeWhere((EntityTag entry) {
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
                textFieldDecoration: const InputDecoration(hintText: "Tags..."),
                clearOption: true,
                enableSearch: true,
                dropdownColor: Colors.amber[50],
                searchDecoration: const InputDecoration(hintText: "查询 Tags..."),
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
                  save();
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_box),
              onPressed: () {
                Navigator.pushNamed(context, "tag/edit",
                    arguments: <String, int>{'id': 0});
              },
            ),
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
                Wrap(
                  children: actorWidgets.toList(),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
