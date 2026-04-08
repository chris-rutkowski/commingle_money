// ignore_for_file: public_member_api_docs

extension ListExtensions<T> on List<T> {
  List<int> allIndexesOf(T value) {
    final result = <int>[];
    for (var i = 0; i < length; i++) {
      if (this[i] == value) {
        result.add(i);
      }
    }

    return result;
  }

  List<int> allIndexesWhere(bool Function(T element) test) {
    final result = <int>[];
    for (var i = 0; i < length; i++) {
      if (test(this[i])) {
        result.add(i);
      }
    }

    return result;
  }

  int? lastIndexWhereOrNull(bool Function(T element) test) {
    for (var i = length - 1; i >= 0; i--) {
      if (test(this[i])) {
        return i;
      }
    }

    return null;
  }

  bool none(bool Function(T element) test) => !any(test);
}
