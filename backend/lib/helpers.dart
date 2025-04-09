bool isListEqual<T>(List<T> list1, List<T> list2) {
  if (list1.length != list2.length) return false;

  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) return false;
  }

  return true;
}

bool isNotListEqual<T>(List<T> list1, List<T> list2) {
  return !isListEqual(list1, list2);
}
