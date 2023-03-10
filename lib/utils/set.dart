/// 2个List通过集合做差集
///
/// return: 只在[oldList] 中存在的数据 oldList - newList
List<int> makeDifferenceBySet(oldList, newList) {
  Set<int> oldSet = Set<int>.from(oldList);
  Set<int> newSet = Set<int>.from(newList);
  return oldSet.difference(newSet).toList();
}
