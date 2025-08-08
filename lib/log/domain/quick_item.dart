class QuickItem {
  QuickItem({required this.name, required this.calories, this.pinned = false});

  final String name;
  final int calories;
  final bool pinned;

  QuickItem copyWith({String? name, int? calories, bool? pinned}) => QuickItem(
    name: name ?? this.name,
    calories: calories ?? this.calories,
    pinned: pinned ?? this.pinned,
  );
}
