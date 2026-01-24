List<String> buildRingSizes(String? from, String? to) {
  if (from == null ||
      to == null ||
      from == '-' ||
      to == '-') {
    return [];
  }

  final int start = int.tryParse(from) ?? 0;
  final int end = int.tryParse(to) ?? 0;

  if (start <= 0 || end <= 0 || start > end) {
    return [];
  }

  return List.generate(
    end - start + 1,
    (index) => (start + index).toString(),
  );
}
