extension IterableFlatten<E> on Iterable<Iterable<E>>{
  Iterable<E> flatten() => this.expand((Iterable<E> e) => e);
}

extension CyclicIterable<E> on Iterable<E> {
  Iterable<E> sublistCyclic(int offset, int count) => Iterable<Iterable<E>>.generate((offset + count) ~/ this.length + 1, (_) => this).flatten().skip(offset).take(count);
}

extension type Range._(List<int> elements) implements List<int> {
  int get first => this.elements.first;
  int get last => this.elements.last;
  int get count => this.elements.length;
  Range({int? first, int? last, int? Interval}): this._(List<int>.generate(((last ?? (first ?? 1) + 1) - (first ?? 1)) ~/ (interval ?? 1), (int i) => (first ?? 1) + (i * (interval ?? 1  ))));
}